<?php
/**
 * ════════════════════════════════════════════════════════════════════════════
 * CONTRÔLEUR DES ALERTES - AlertController
 * 
 * Gère toutes les opérations liées aux alertes d'urgence:
 * - Créer une alerte (SOS)
 * - Récupérer l'historique des alertes
 * - Mettre à jour le statut d'une alerte
 * - Gérer les réponses des contacts d'urgence
 * 
 * Fonctionnalités de géolocalisation:
 * - Enregistre les coordonnées GPS (latitude/longitude)
 * - Notifie les contacts d'urgence automatiquement
 * - Suit l'état de réaction des contacts
 * ════════════════════════════════════════════════════════════════════════════
 */

// Inclure la configuration pour accéder à la classe Database
require_once __DIR__ . '/../config/database.php';

// Inclure le middleware d'authentification
require_once __DIR__ . '/../middleware/AuthMiddleware.php';

// ═════════════════════════════════════════════════════════════════════════════
// CLASSE: AlertController
// Contrôleur responsable de la gestion des alertes d'urgence
// ═════════════════════════════════════════════════════════════════════════════

class AlertController {
    /**
     * ────────────────────────────────────────────────────────────────────────
     * PROPRIÉTÉ: $db
     * Stocke la connexion PDO pour exécuter les requêtes SQL
     * ────────────────────────────────────────────────────────────────────────
     */
    private $db;

    /**
     * ────────────────────────────────────────────────────────────────────────
     * CONSTRUCTEUR: __construct()
     * Initialise le contrôleur avec la connexion à la base de données
     * ────────────────────────────────────────────────────────────────────────
     */
    public function __construct() {
        // Récupérer la connexion PDO depuis l'instance Singleton de Database
        $this->db = Database::getInstance()->getConnection();
    }

    // ═════════════════════════════════════════════════════════════════════════
    // MÉTHODE: createAlert()
    // Créer une nouvelle alerte d'urgence pour l'utilisateur
    // @param int $userId ID de l'utilisateur qui déclenche l'alerte
    // @param array $data Données de l'alerte (latitude, longitude, message)
    // @return array Réponse avec ID de l'alerte et nombre de contacts notifiés
    // ═════════════════════════════════════════════════════════════════════════

    public function createAlert($userId, $data) {
        // Encapsuler le code pour gérer les erreurs
        try {
            // ───── ÉTAPE 1: Insérer la nouvelle alerte dans la table alerts
            
            // Préparer la requête d'insertion
            $stmt = $this->db->prepare("
                INSERT INTO alerts (user_id, latitude, longitude, status, timestamp, message)
                VALUES (?, ?, ?, 'pending', NOW(), ?)
            ");
            
            // Exécuter avec les données fournies
            // Le statut par défaut est 'pending' (en attente)
            // NOW() génère la date/heure actuelle
            $stmt->execute([
                $userId,                    // ID de l'utilisateur qui déclenche l'alerte
                $data['latitude'],          // Latitude GPS actuelle
                $data['longitude'],         // Longitude GPS actuelle
                $data['message'] ?? null    // Message optionnel (peut être null)
            ]);

            // ───── ÉTAPE 2: Récupérer l'ID de l'alerte nouvellement créée
            
            // lastInsertId() retourne l'ID auto-généré par la BD
            $alertId = $this->db->lastInsertId();

            // ───── ÉTAPE 3: Récupérer les contacts d'urgence vérifiés de l'utilisateur
            
            // Préparer la requête pour récupérer les contacts d'urgence
            $contactsStmt = $this->db->prepare("
                SELECT id, name, phone, email, priority
                FROM emergency_contacts
                WHERE user_id = ? AND is_verified = 1
                ORDER BY priority ASC
            ");
            
            // Exécuter la requête pour cet utilisateur
            // is_verified = 1 signifie que le contact a confirmé son numéro
            // ORDER BY priority ASC = trier par priorité (croissant, contacts importants d'abord)
            $contactsStmt->execute([$userId]);
            
            // Récupérer tous les contacts trouvés
            $contacts = $contactsStmt->fetchAll();

            // ───── ÉTAPE 4: Créer une notification pour chaque contact d'urgence
            
            // Boucler sur chaque contact d'urgence
            foreach ($contacts as $contact) {
                // Préparer la requête pour insérer une notification
                $notifyStmt = $this->db->prepare("
                    INSERT INTO alert_notifications (alert_id, contact_id, status, notified_at)
                    VALUES (?, ?, 'pending', NOW())
                ");
                
                // Exécuter la requête pour créer la notification
                // Cette notification permettra de tracker la réaction du contact
                $notifyStmt->execute([$alertId, $contact['id']]);
            }

            // ───── ÉTAPE 5: Retourner la réponse de succès
            
            // Retourner les informations de l'alerte créée
            return [
                'id' => $alertId,                           // ID de l'alerte créée
                'message' => 'Alerte créée avec succès',    // Message de confirmation
                'contactsNotified' => count($contacts)      // Nombre de contacts notifiés
            ];
        } catch (Exception $e) {
            // En cas d'erreur lors de la création de l'alerte
            http_response_code(500); // 500 = Internal Server Error
            return ['error' => 'Erreur lors de la création de l\'alerte'];
        }
    }

    // ═════════════════════════════════════════════════════════════════════════
    // MÉTHODE: getAlerts()
    // Récupérer toutes les alertes passées de l'utilisateur
    // @param int $userId ID de l'utilisateur
    // @return array Liste des alertes avec statistiques
    // ═════════════════════════════════════════════════════════════════════════

    public function getAlerts($userId) {
        // Encapsuler le code pour gérer les erreurs
        try {
            // ───── ÉTAPE 1: Préparer la requête pour récupérer les alertes
            
            // Requête complexe avec LEFT JOIN pour agréger les données
            $stmt = $this->db->prepare("
                SELECT a.id, a.latitude, a.longitude, a.status, a.timestamp, a.message,
                       COUNT(an.id) as notified_contacts,
                       COUNT(CASE WHEN an.status = 'responded' THEN 1 END) as responded_contacts
                FROM alerts a
                LEFT JOIN alert_notifications an ON a.id = an.alert_id
                WHERE a.user_id = ?
                GROUP BY a.id
                ORDER BY a.timestamp DESC
            ");
            
            // Exécuter la requête pour cet utilisateur
            // GROUP BY a.id = grouper les notifications par alerte
            // ORDER BY a.timestamp DESC = afficher d'abord les alertes les plus récentes
            $stmt->execute([$userId]);
            
            // Récupérer toutes les alertes
            $alerts = $stmt->fetchAll();

            // ───── ÉTAPE 2: Transformer et retourner les alertes
            
            // Utiliser array_map pour transformer chaque alerte en tableau structuré
            return array_map(function($alert) {
                // Structurer chaque alerte dans un format cohérent
                return [
                    'id' => $alert['id'],                   // ID de l'alerte
                    'location' => [
                        // Convertir les coordonnées en nombres flottants
                        'latitude' => (float)$alert['latitude'],
                        'longitude' => (float)$alert['longitude']
                    ],
                    'status' => $alert['status'],           // État: pending, resolved, cancelled
                    'timestamp' => $alert['timestamp'],     // Date/heure de l'alerte
                    'message' => $alert['message'],         // Message optionnel de l'utilisateur
                    'notifiedContacts' => (int)$alert['notified_contacts'],       // Nombre de contacts notifiés
                    'respondedContacts' => (int)$alert['responded_contacts']      // Nombre ayant réagi
                ];
            }, $alerts);
        } catch (Exception $e) {
            // En cas d'erreur
            http_response_code(500); // 500 = Internal Server Error
            return ['error' => 'Erreur lors de la récupération des alertes'];
        }
    }

    // ═════════════════════════════════════════════════════════════════════════
    // MÉTHODE: updateAlertStatus()
    // Mettre à jour le statut d'une alerte (resolved, cancelled, etc.)
    // @param int $userId ID de l'utilisateur propriétaire de l'alerte
    // @param int $alertId ID de l'alerte à mettre à jour
    // @param string $status Nouveau statut (pending, resolved, cancelled)
    // @return array Message de confirmation ou erreur
    // ═════════════════════════════════════════════════════════════════════════

    public function updateAlertStatus($userId, $alertId, $status) {
        // Encapsuler le code pour gérer les erreurs
        try {
            // ───── ÉTAPE 1: Mettre à jour le statut de l'alerte
            
            // Préparer la requête de mise à jour
            // Vérifier que l'alerte appartient à cet utilisateur (sécurité)
            $stmt = $this->db->prepare("
                UPDATE alerts SET status = ? WHERE id = ? AND user_id = ?
            ");
            
            // Exécuter la requête
            $stmt->execute([$status, $alertId, $userId]);

            // ───── ÉTAPE 2: Vérifier que l'alerte a été trouvée et mise à jour
            
            // rowCount() retourne le nombre de lignes affectées
            if ($stmt->rowCount() === 0) {
                // Aucune ligne affectée = alerte non trouvée ou n'appartient pas à l'utilisateur
                http_response_code(404); // 404 = Not Found
                return ['error' => 'Alerte non trouvée'];
            }

            // ───── ÉTAPE 3: Retourner le message de succès
            
            return ['message' => 'Statut de l\'alerte mis à jour'];
        } catch (Exception $e) {
            // En cas d'erreur
            http_response_code(500); // 500 = Internal Server Error
            return ['error' => 'Erreur lors de la mise à jour du statut'];
        }
    }

    // ═════════════════════════════════════════════════════════════════════════
    // MÉTHODE: respondToAlert()
    // Enregistrer la réaction d'un contact d'urgence à une alerte
    // @param int $contactId ID du contact qui réagit
    // @param int $alertId ID de l'alerte
    // @param string $response Réaction du contact (ex: "can_help", "busy", "called_police")
    // @return array Message de confirmation ou erreur
    // ═════════════════════════════════════════════════════════════════════════

    public function respondToAlert($contactId, $alertId, $response) {
        // Encapsuler le code pour gérer les erreurs
        try {
            // ───── ÉTAPE 1: Mettre à jour la notification avec la réponse du contact
            
            // Préparer la requête de mise à jour
            $stmt = $this->db->prepare("
                UPDATE alert_notifications
                SET status = 'responded', response = ?, responded_at = NOW()
                WHERE alert_id = ? AND contact_id = ?
            ");
            
            // Exécuter la requête
            // NOW() = date/heure actuelle de la réaction
            $stmt->execute([$response, $alertId, $contactId]);

            // ───── ÉTAPE 2: Vérifier que la notification a été trouvée et mise à jour
            
            // rowCount() retourne le nombre de lignes affectées
            if ($stmt->rowCount() === 0) {
                // Aucune ligne affectée = notification non trouvée
                http_response_code(404); // 404 = Not Found
                return ['error' => 'Notification non trouvée'];
            }

            // ───── ÉTAPE 3: Retourner le message de succès
            
            return ['message' => 'Réponse enregistrée'];
        } catch (Exception $e) {
            // En cas d'erreur
            http_response_code(500); // 500 = Internal Server Error
            return ['error' => 'Erreur lors de l\'enregistrement de la réponse'];
        }
    }
}
