<?php

/**
 * ════════════════════════════════════════════════════════════════════════════
 * CONTRÔLEUR D'AUTHENTIFICATION - AuthController
 * 
 * Gère toutes les opérations liées à l'authentification des utilisateurs:
 * - Enregistrement (Registration)
 * - Connexion (Login)
 * - Récupération du profil utilisateur
 * 
 * Sécurité implémentée:
 * - Hachage des mots de passe avec PASSWORD_DEFAULT (bcrypt)
 * - Requêtes préparées (prévention SQL Injection)
 * - JWT pour l'authentification sans état (Stateless)
 * ════════════════════════════════════════════════════════════════════════════
 */

// Inclure la configuration pour accéder à la classe Database
require_once __DIR__ . '/../config/database.php';

// Inclure la configuration JWT pour encoder/décoder les tokens
require_once __DIR__ . '/../config/jwt.php';

// ═════════════════════════════════════════════════════════════════════════════
// CLASSE: AuthController
// Contrôleur responsable de la gestion de l'authentification utilisateur
// ═════════════════════════════════════════════════════════════════════════════

class AuthController
{
    /**
     * ────────────────────────────────────────────────────────────────────────
     * PROPRIÉTÉ: $db
     * Stocke la connexion PDO à la base de données pour les requêtes SQL
     * ────────────────────────────────────────────────────────────────────────
     */
    private $db;

    /**
     * ────────────────────────────────────────────────────────────────────────
     * CONSTRUCTEUR: __construct()
     * Initialise le contrôleur en obtenant la connexion à la base de données
     * ────────────────────────────────────────────────────────────────────────
     */
    public function __construct()
    {
        // Récupérer l'instance unique de la base de données (Singleton Pattern)
        // et obtenir son objet PDO pour exécuter les requêtes
        $this->db = Database::getInstance()->getConnection();
    }

    // ═════════════════════════════════════════════════════════════════════════
    // MÉTHODE: register()
    // Enregistrer un nouvel utilisateur dans la base de données
    // @param array $data Données du formulaire d'enregistrement
    // @return array Réponse contenant le token JWT et les infos utilisateur
    // ═════════════════════════════════════════════════════════════════════════

    public function register($data)
    {
        // Encapsuler le code dans un bloc try-catch pour gérer les erreurs
        try {
            // ───── ÉTAPE 1: Vérifier que l'utilisateur n'existe pas déjà

            // Préparer une requête SQL pour chercher un utilisateur avec cet email
            // Le ? est un placeholder pour éviter les injections SQL
            $stmt = $this->db->prepare("SELECT id FROM users WHERE email = ?");

            // Exécuter la requête avec l'email fourni
            $stmt->execute([$data['email']]);

            // Essayer de récupérer la première ligne du résultat
            if ($stmt->fetch()) {
                // Si un utilisateur avec cet email existe, retourner une erreur
                http_response_code(400); // 400 = Bad Request
                return ['error' => 'Utilisateur déjà existant'];
            }

            // ───── ÉTAPE 2: Hacher le mot de passe de manière sécurisée

            // PASSWORD_DEFAULT utilise bcrypt (actuellement l'algorithme le plus sûr)
            // Le mot de passe est irréversiblement transformé
            $hashedPassword = password_hash($data['password'], PASSWORD_DEFAULT);

            // ───── ÉTAPE 3: Insérer le nouvel utilisateur dans la base de données

            // Préparer la requête d'insertion avec 5 placeholders pour 5 colonnes
            $stmt = $this->db->prepare("
                INSERT INTO users (email, password, first_name, last_name, phone, created_at)
                VALUES (?, ?, ?, ?, ?, NOW())
            ");

            // Exécuter la requête avec les données de l'utilisateur
            // NOW() est une fonction MySQL qui retourne la date/heure actuelle
            $stmt->execute([
                $data['email'],           // Email fourni lors de l'enregistrement
                $hashedPassword,          // Mot de passe hashé (pas le mot de passe en clair!)
                $data['firstName'],       // Prénom de l'utilisateur
                $data['lastName'],        // Nom de l'utilisateur
                $data['phone']            // Numéro de téléphone
            ]);

            // ───── ÉTAPE 4: Récupérer l'ID de l'utilisateur nouvellement créé

            // lastInsertId() retourne l'ID auto-généré par la base de données
            $userId = $this->db->lastInsertId();

            // ───── ÉTAPE 5: Générer un token JWT pour authentifier l'utilisateur

            // Encoder les informations utilisateur dans le token
            $token = JWT::encode([
                'userId' => $userId,                           // ID unique de l'utilisateur
                'email' => $data['email'],                     // Email de l'utilisateur
                'exp' => time() + (24 * 60 * 60)              // Expiration: 24 heures à partir de maintenant
            ]);

            // ───── ÉTAPE 6: Retourner la réponse au client

            // Retourner le token et les informations de l'utilisateur
            return [
                // Token JWT à utiliser pour les requêtes futures authentifiées
                'token' => $token,
                // Informations de base de l'utilisateur (sans le mot de passe!)
                'user' => [
                    'id' => $userId,
                    'email' => $data['email'],
                    'firstName' => $data['firstName'],
                    'lastName' => $data['lastName'],
                    'phone' => $data['phone']
                ]
            ];
        } catch (Exception $e) {
            // En cas d'erreur (exception levée), retourner une erreur 500
            http_response_code(500); // 500 = Internal Server Error
            return ['error' => 'Erreur lors de l\'inscription'];
        }
    }

    // ═════════════════════════════════════════════════════════════════════════
    // MÉTHODE: login()
    // Authentifier un utilisateur existant
    // @param array $data Données du formulaire de connexion (email + password)
    // @return array Réponse contenant le token JWT
    // ═════════════════════════════════════════════════════════════════════════

    public function login($data)
    {
        // Encapsuler le code dans un bloc try-catch pour gérer les erreurs
        try {
            // ───── ÉTAPE 1: Chercher l'utilisateur par son email

            // Préparer une requête pour récupérer tous les infos de l'utilisateur
            $stmt = $this->db->prepare("SELECT id, email, password, first_name, last_name, phone FROM users WHERE email = ?");

            // Exécuter la requête avec l'email fourni
            $stmt->execute([$data['email']]);

            // Récupérer le premier utilisateur trouvé sous forme de tableau
            $user = $stmt->fetch();

            // ───── ÉTAPE 2: Vérifier que l'utilisateur existe et le mot de passe est correct

            // Vérifier deux choses:
            // 1. L'utilisateur existe (résultat non vide)
            // 2. Le mot de passe fourni correspond au mot de passe haché en base de données
            //    password_verify() compare le mot de passe en clair avec le hash bcrypt
            if (!$user || !password_verify($data['password'], $user['password'])) {
                // Authentification échouée: utilisateur non trouvé ou mot de passe incorrect
                http_response_code(401); // 401 = Unauthorized
                return ['error' => 'Email ou mot de passe incorrect'];
            }

            // ───── ÉTAPE 3: Créer le token JWT pour cet utilisateur

            // Encoder les informations de l'utilisateur authentifié dans le token
            $token = JWT::encode([
                'userId' => $user['id'],                       // ID unique de l'utilisateur
                'email' => $user['email'],                     // Email de l'utilisateur
                'exp' => time() + (24 * 60 * 60)              // Expiration: 24 heures
            ]);

            // ───── ÉTAPE 4: Retourner la réponse au client

            // Retourner le token et les informations de l'utilisateur
            return [
                // Token JWT à utiliser pour les requêtes futures authentifiées
                'token' => $token,
                // Informations de base de l'utilisateur
                'user' => [
                    'id' => $user['id'],
                    'email' => $user['email'],
                    'firstName' => $user['first_name'],
                    'lastName' => $user['last_name'],
                    'phone' => $user['phone']
                ]
            ];
        } catch (Exception $e) {
            // En cas d'erreur lors de la connexion
            http_response_code(500); // 500 = Internal Server Error
            return ['error' => 'Erreur lors de la connexion'];
        }
    }

    // ═════════════════════════════════════════════════════════════════════════
    // MÉTHODE: getProfile()
    // Récupérer le profil complet d'un utilisateur authentifié
    // @param int $userId ID de l'utilisateur dont on veut le profil
    // @return array Réponse contenant les informations du profil
    // ═════════════════════════════════════════════════════════════════════════

    public function getProfile($userId)
    {
        // Encapsuler le code dans un bloc try-catch pour gérer les erreurs
        try {
            // ───── ÉTAPE 1: Chercher l'utilisateur par son ID

            // Préparer une requête pour récupérer les informations complètes
            $stmt = $this->db->prepare("
                SELECT id, email, first_name, last_name, phone, profile_image, created_at
                FROM users WHERE id = ?
            ");

            // Exécuter la requête avec l'ID de l'utilisateur
            $stmt->execute([$userId]);

            // Récupérer l'utilisateur sous forme de tableau
            $user = $stmt->fetch();

            // ───── ÉTAPE 2: Vérifier que l'utilisateur existe

            // Si aucun utilisateur n'est trouvé avec cet ID
            if (!$user) {
                // Retourner une erreur 404 (Not Found)
                http_response_code(404);
                return ['error' => 'Utilisateur non trouvé'];
            }

            // ───── ÉTAPE 3: Retourner les informations du profil

            // Retourner les informations de l'utilisateur
            return [
                'id' => $user['id'],                      // ID unique
                'email' => $user['email'],                // Email
                'firstName' => $user['first_name'],       // Prénom
                'lastName' => $user['last_name'],         // Nom
                'phone' => $user['phone'],                // Téléphone
                'profileImage' => $user['profile_image'], // URL de la photo de profil
                'createdAt' => $user['created_at']        // Date de création du compte
            ];
        } catch (Exception $e) {
            // En cas d'erreur lors de la récupération du profil
            http_response_code(500); // 500 = Internal Server Error
            return ['error' => 'Erreur lors de la récupération du profil'];
        }
    }

    // ═════════════════════════════════════════════════════════════════════════
    // MÉTHODE: updateProfile()
    // Mettre à jour le profil d'un utilisateur authentifié
    // @param int $userId ID de l'utilisateur dont on veut modifier le profil
    // @param array $data Données à mettre à jour (firstName, lastName, phone)
    // @return array Réponse contenant les informations mises à jour
    // ═════════════════════════════════════════════════════════════════════════

    public function updateProfile($userId, $data)
    {
        // Encapsuler le code dans un bloc try-catch pour gérer les erreurs
        try {
            // ───── ÉTAPE 1: Normaliser les clés d'entrée (accepter camelCase et snake_case)

            // Supporter les deux formats : firstName/first_name et lastName/last_name
            $firstName = $data['firstName'] ?? $data['first_name'] ?? null;
            $lastName = $data['lastName'] ?? $data['last_name'] ?? null;
            $phone = $data['phone'] ?? null;

            // ───── ÉTAPE 2: Valider les données d'entrée

            // Vérifier que les champs obligatoires sont présents
            if (!$firstName || !$lastName) {
                http_response_code(400); // 400 = Bad Request
                return ['error' => 'Les champs firstName et lastName sont requis'];
            }

            // ───── ÉTAPE 3: Valider le format des données

            // Vérifier que le prénom n'est pas vide et fait au maximum 50 caractères
            if (empty(trim($firstName)) || strlen($firstName) > 50) {
                http_response_code(400);
                return ['error' => 'Le prénom doit contenir entre 1 et 50 caractères'];
            }

            // Vérifier que le nom n'est pas vide et fait au maximum 50 caractères
            if (empty(trim($lastName)) || strlen($lastName) > 50) {
                http_response_code(400);
                return ['error' => 'Le nom doit contenir entre 1 et 50 caractères'];
            }

            // Vérifier que le téléphone est au bon format seulement s'il est fourni (optionnel)
            if (isset($phone) && !empty(trim($phone))) {
                if (!preg_match('/^[0-9+\-\s()]{10,15}$/', $phone)) {
                    http_response_code(400);
                    return ['error' => 'Format de téléphone invalide'];
                }
            }

            // ───── ÉTAPE 4: Mettre à jour l'utilisateur dans la base de données

            // Préparer la requête de mise à jour
            $stmt = $this->db->prepare("
                UPDATE users
                SET first_name = ?, last_name = ?, phone = ?, updated_at = NOW()
                WHERE id = ?
            ");

            // Exécuter la requête avec les nouvelles données
            $stmt->execute([
                trim($firstName),  // Prénom nettoyé
                trim($lastName),   // Nom nettoyé
                trim($phone ?? ''),      // Téléphone nettoyé
                $userId                    // ID de l'utilisateur
            ]);

            // ───── ÉTAPE 5: Vérifier que la mise à jour a réussi

            // Vérifier le nombre de lignes affectées
            if ($stmt->rowCount() === 0) {
                http_response_code(404);
                return ['error' => 'Utilisateur non trouvé ou aucune modification effectuée'];
            }

            // ───── ÉTAPE 6: Récupérer et retourner les informations mises à jour

            // Retourner les informations mises à jour en camelCase pour cohérence frontend
            return [
                'id' => $userId,
                'firstName' => trim($firstName),
                'lastName' => trim($lastName),
                'phone' => isset($phone) && !empty(trim($phone)) ? trim($phone) : null,
                'message' => 'Profil mis à jour avec succès'
            ];
        } catch (Exception $e) {
            // En cas d'erreur lors de la mise à jour du profil
            http_response_code(500); // 500 = Internal Server Error
            return ['error' => 'Erreur lors de la mise à jour du profil'];
        }
    }
}
