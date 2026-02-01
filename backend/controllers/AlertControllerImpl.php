<?php

/**
 * ════════════════════════════════════════════════════════════════════════════
 * AlertController - CRUD pour les alertes
 * ════════════════════════════════════════════════════════════════════════════
 */

require_once __DIR__ . '/../utils/Validator.php';
require_once __DIR__ . '/../utils/ResponseHandler.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../middleware/AuthMiddleware.php';
require_once __DIR__ . '/AlertController.php';

class AlertControllerImpl extends AlertController
{
    private $db;

    public function __construct()
    {
        $this->db = Database::getInstance()->getConnection();
    }

    /**
     * Créer une nouvelle alerte
     */
    public function createAlert($userId, $data)
    {
        try {
            // Validation
            $title = $data['title'] ?? '';
            $description = $data['description'] ?? '';
            $type = $data['type'] ?? 'info';
            $status = $data['status'] ?? 'active';
            $latitude = $data['latitude'] ?? null;
            $longitude = $data['longitude'] ?? null;

            if (empty($title) || strlen($title) < 3) {
                return [
                    'success' => false,
                    'error' => 'Au minimum 3 caractères'
                ];
            }

            if (!empty($latitude) && !empty($longitude)) {
                $coordsValid = Validator::validateCoordinates($latitude, $longitude);
                if (!$coordsValid['valid']) {
                    return [
                        'success' => false,
                        'error' => $coordsValid['message']
                    ];
                }
            }

            // Créer alerte
            $stmt = $this->db->prepare(
                'INSERT INTO alerts (user_id, title, description, type, status, latitude, longitude, created_at) 
                VALUES (?, ?, ?, ?, ?, ?, ?, NOW())'
            );
            $stmt->execute([$userId, $title, $description, $type, $status, $latitude, $longitude]);

            $alertId = $this->db->lastInsertId();

            return [
                'success' => true,
                'message' => 'Alerte créée',
                'data' => ['alert_id' => $alertId]
            ];
        } catch (Exception $e) {
            return [
                'success' => false,
                'error' => 'Erreur: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Récupérer les alertes de l'utilisateur
     */
    public function getAlerts($userId)
    {
        try {
            $stmt = $this->db->prepare(
                'SELECT id, title, description, type, status, latitude, longitude, created_at 
                FROM alerts WHERE user_id = ? ORDER BY created_at DESC LIMIT 100'
            );
            $stmt->execute([$userId]);
            $alerts = $stmt->fetchAll(PDO::FETCH_ASSOC);

            return [
                'success' => true,
                'message' => 'Alertes récupérées',
                'data' => $alerts
            ];
        } catch (Exception $e) {
            return [
                'success' => false,
                'error' => 'Erreur: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Récupérer une alerte spécifique
     */
    public function getAlert($id)
    {
        try {
            $user = AuthMiddleware::verifyToken();

            $stmt = $this->db->prepare(
                'SELECT * FROM alerts WHERE id = ? AND user_id = ?'
            );
            $stmt->execute([$id, $user->id]);
            $alert = $stmt->fetch(PDO::FETCH_ASSOC);

            if (!$alert) {
                ResponseHandler::notFound('Alerte non trouvée');
            }

            ResponseHandler::success('Alerte récupérée', ['alert' => $alert]);
        } catch (Exception $e) {
            ResponseHandler::internalError('Erreur: ' . $e->getMessage());
        }
    }

    /**
     * Mettre à jour le statut d'une alerte
     */
    public function updateAlertStatus($userId, $alertId, $status)
    {
        try {
            // Vérifier que l'alerte appartient à l'utilisateur
            $stmt = $this->db->prepare('SELECT id FROM alerts WHERE id = ? AND user_id = ?');
            $stmt->execute([$alertId, $userId]);
            if ($stmt->rowCount() === 0) {
                return [
                    'success' => false,
                    'error' => 'Alerte non trouvée'
                ];
            }

            // Mettre à jour
            $stmt = $this->db->prepare('UPDATE alerts SET status = ? WHERE id = ? AND user_id = ?');
            $stmt->execute([$status, $alertId, $userId]);

            return [
                'success' => true,
                'message' => 'Alerte mise à jour'
            ];
        } catch (Exception $e) {
            return [
                'success' => false,
                'error' => 'Erreur: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Supprimer une alerte
     */
    public function delete($id)
    {
        try {
            $user = AuthMiddleware::verifyToken();

            $stmt = $this->db->prepare('DELETE FROM alerts WHERE id = ? AND user_id = ?');
            $stmt->execute([$id, $user->id]);

            if ($stmt->rowCount() === 0) {
                ResponseHandler::notFound('Alerte non trouvée');
            }

            ResponseHandler::success('Alerte supprimée');
        } catch (Exception $e) {
            ResponseHandler::internalError('Erreur: ' . $e->getMessage());
        }
    }

    /**
     * Répondre à une alerte (confirmer/refuser)
     */
    public function respondToAlert($contactId, $alertId, $response)
    {
        try {
            // Vérifier que le contact d'urgence existe
            $stmt = $this->db->prepare('SELECT id, user_id FROM emergency_contacts WHERE id = ?');
            $stmt->execute([$contactId]);
            $contact = $stmt->fetch(PDO::FETCH_ASSOC);

            if (!$contact) {
                return [
                    'success' => false,
                    'error' => 'Contact non trouvé'
                ];
            }

            // Vérifier que l'alerte existe et appartient à l'utilisateur
            $stmt = $this->db->prepare('SELECT id FROM alerts WHERE id = ? AND user_id = ?');
            $stmt->execute([$alertId, $contact['user_id']]);
            if ($stmt->rowCount() === 0) {
                return [
                    'success' => false,
                    'error' => 'Alerte non trouvée'
                ];
            }

            // Enregistrer la réponse
            $stmt = $this->db->prepare(
                'INSERT INTO alert_responses (alert_id, contact_id, response, responded_at) 
                VALUES (?, ?, ?, NOW())'
            );
            $stmt->execute([$alertId, $contactId, $response]);

            return [
                'success' => true,
                'message' => 'Réponse enregistrée'
            ];
        } catch (Exception $e) {
            return [
                'success' => false,
                'error' => 'Erreur: ' . $e->getMessage()
            ];
        }
    }
}
