<?php

/**
 * ════════════════════════════════════════════════════════════════════════════
 * AuthController - Implémentation complète
 * 
 * Gère l'authentification des utilisateurs (login, register, logout, profile)
 * ════════════════════════════════════════════════════════════════════════════
 */

require_once __DIR__ . '/../utils/Validator.php';
require_once __DIR__ . '/../utils/ResponseHandler.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/jwt.php';
require_once __DIR__ . '/../middleware/AuthMiddleware.php';
require_once __DIR__ . '/AuthController.php';

class AuthControllerImpl extends AuthController
{
    private $db;

    public function __construct()
    {
        $this->db = Database::getInstance()->getConnection();
    }

    /**
     * ════════════════════════════════════════════════════════════════════════
     * ACTION: Register (Enregistrement)
     * ════════════════════════════════════════════════════════════════════════
     */
    public function register($data = null)
    {
        try {
            // Si data n'est pas fournie, récupérer du corps de la requête
            if ($data === null) {
                $data = json_decode(file_get_contents('php://input'), true);
            }

            // ═══ Validation ═══
            $email = $data['email'] ?? '';
            $password = $data['password'] ?? '';
            $firstName = $data['first_name'] ?? '';
            $lastName = $data['last_name'] ?? '';
            $phone = $data['phone'] ?? '';

            // Valider email
            $emailValid = Validator::validateEmail($email);
            if (!$emailValid['valid']) {
                ResponseHandler::validationError('Erreur validation', ['email' => $emailValid['message']]);
            }

            // Valider mot de passe
            $passwordValid = Validator::validatePassword($password);
            if (!$passwordValid['valid']) {
                ResponseHandler::validationError('Erreur validation', ['password' => $passwordValid['message']]);
            }

            // Valider nom/prénom
            $firstNameValid = Validator::validateName($firstName, 'Prénom');
            if (!$firstNameValid['valid']) {
                ResponseHandler::validationError('Erreur validation', ['first_name' => $firstNameValid['message']]);
            }

            $lastNameValid = Validator::validateName($lastName, 'Nom');
            if (!$lastNameValid['valid']) {
                ResponseHandler::validationError('Erreur validation', ['last_name' => $lastNameValid['message']]);
            }

            // Valider téléphone
            if (!empty($phone)) {
                $phoneValid = Validator::validatePhone($phone);
                if (!$phoneValid['valid']) {
                    ResponseHandler::validationError('Erreur validation', ['phone' => $phoneValid['message']]);
                }
            }

            // ═══ Vérifier email existant ═══
            $stmt = $this->db->prepare('SELECT id FROM users WHERE email = ?');
            $stmt->execute([$email]);
            if ($stmt->rowCount() > 0) {
                ResponseHandler::error('Email déjà utilisé', 400);
            }

            // ═══ Créer utilisateur ═══
            $hashedPassword = password_hash($password, PASSWORD_DEFAULT);

            $stmt = $this->db->prepare(
                'INSERT INTO users (email, password, first_name, last_name, phone, status, role) 
                VALUES (?, ?, ?, ?, ?, ?, ?)'
            );
            $stmt->execute([
                $email,
                $hashedPassword,
                $firstName,
                $lastName,
                $phone,
                'pending',
                'user'
            ]);

            $userId = $this->db->lastInsertId();

            // ═══ Créer user_settings ═══
            $stmt = $this->db->prepare(
                'INSERT INTO user_settings (user_id, notifications_enabled, emergency_alert_enabled) 
                VALUES (?, ?, ?)'
            );
            $stmt->execute([$userId, true, true]);

            // ═══ Générer JWT ═══
            $user = [
                'id' => $userId,
                'email' => $email,
                'first_name' => $firstName,
                'last_name' => $lastName,
                'role' => 'user',
                'iat' => time(),
                'exp' => time() + 3600
            ];
            $token = JWT::encode($user, Config::get('JWT_SECRET'));

            ResponseHandler::success('Enregistrement réussi', [
                'token' => $token,
                'user' => [
                    'id' => $userId,
                    'email' => $email,
                    'first_name' => $firstName,
                    'last_name' => $lastName,
                    'role' => 'user'
                ]
            ], 201);
        } catch (Exception $e) {
            ResponseHandler::internalError('Erreur lors de l\'enregistrement: ' . $e->getMessage());
        }
    }

    /**
     * ════════════════════════════════════════════════════════════════════════
     * ACTION: Login (Connexion)
     * ════════════════════════════════════════════════════════════════════════
     */
    public function login($data = null)
    {
        try {
            if ($data === null) {
                $data = json_decode(file_get_contents('php://input'), true);
            }

            // ═══ Validation ═══
            $email = $data['email'] ?? '';
            $password = $data['password'] ?? '';

            if (empty($email) || empty($password)) {
                ResponseHandler::validationError('Email et mot de passe requis');
            }

            // ═══ Chercher utilisateur ═══
            $stmt = $this->db->prepare('SELECT * FROM users WHERE email = ?');
            $stmt->execute([$email]);
            $user = $stmt->fetch(PDO::FETCH_ASSOC);

            if (!$user || !password_verify($password, $user['password'])) {
                ResponseHandler::unauthorized('Email ou mot de passe incorrect');
            }

            // ═══ Vérifier statut utilisateur ═══
            if ($user['status'] === 'blocked') {
                ResponseHandler::error('Compte bloqué', 403);
            }

            // ═══ Générer JWT ═══
            $tokenData = [
                'id' => $user['id'],
                'email' => $user['email'],
                'first_name' => $user['first_name'],
                'last_name' => $user['last_name'],
                'role' => $user['role'],
                'iat' => time(),
                'exp' => time() + 3600
            ];
            $token = JWT::encode($tokenData, Config::get('JWT_SECRET'));

            // ═══ Mettre à jour last_login (optionnel) ═══
            // À implémenter si nécessaire

            ResponseHandler::success('Connexion réussie', [
                'token' => $token,
                'user' => [
                    'id' => $user['id'],
                    'email' => $user['email'],
                    'first_name' => $user['first_name'],
                    'last_name' => $user['last_name'],
                    'phone' => $user['phone'],
                    'role' => $user['role']
                ]
            ]);
        } catch (Exception $e) {
            ResponseHandler::internalError('Erreur lors de la connexion: ' . $e->getMessage());
        }
    }

    /**
     * ════════════════════════════════════════════════════════════════════════
     * ACTION: Get Profile (Récupérer le profil)
     * ════════════════════════════════════════════════════════════════════════
     */
    public function getProfile($userId = null)
    {
        try {
            if ($userId === null) {
                $user = AuthMiddleware::verifyToken();
                $userId = $user->id;
            }

            // ═══ Récupérer profil complet ═══
            $stmt = $this->db->prepare('SELECT id, email, first_name, last_name, phone, profile_image, status, role, created_at FROM users WHERE id = ?');
            $stmt->execute([$userId]);
            $profile = $stmt->fetch(PDO::FETCH_ASSOC);

            if (!$profile) {
                ResponseHandler::notFound('Utilisateur non trouvé');
            }

            // ═══ Récupérer settings ═══
            $stmt = $this->db->prepare('SELECT * FROM user_settings WHERE user_id = ?');
            $stmt->execute([$user->id]);
            $settings = $stmt->fetch(PDO::FETCH_ASSOC);

            // Retourner le profil au format attendu par l'app Flutter
            ResponseHandler::success('Profil récupéré', [
                'id' => $profile['id'],
                'email' => $profile['email'],
                'firstName' => $profile['first_name'],
                'lastName' => $profile['last_name'],
                'phone' => $profile['phone'],
                'profileImage' => $profile['profile_image'],
                'status' => $profile['status'],
                'role' => $profile['role'],
                'createdAt' => $profile['created_at'],
                'settings' => $settings
            ]);
        } catch (Exception $e) {
            ResponseHandler::internalError('Erreur: ' . $e->getMessage());
        }
    }

    public function updateProfile($userId = null, $data = null)
    {
        try {
            if ($userId === null) {
                $user = AuthMiddleware::verifyToken();
                $userId = $user->id;
            }
            if ($data === null) {
                $data = json_decode(file_get_contents('php://input'), true);
            }

            // ═══ Validation ═══
            if (isset($data['first_name'])) {
                $nameValid = Validator::validateName($data['first_name'], 'Prénom');
                if (!$nameValid['valid']) {
                    ResponseHandler::validationError('Erreur', ['first_name' => $nameValid['message']]);
                }
            }

            if (isset($data['last_name'])) {
                $nameValid = Validator::validateName($data['last_name'], 'Nom');
                if (!$nameValid['valid']) {
                    ResponseHandler::validationError('Erreur', ['last_name' => $nameValid['message']]);
                }
            }

            if (isset($data['phone']) && !empty($data['phone'])) {
                $phoneValid = Validator::validatePhone($data['phone']);
                if (!$phoneValid['valid']) {
                    ResponseHandler::validationError('Erreur', ['phone' => $phoneValid['message']]);
                }
            }

            // ═══ Mettre à jour ═══
            $updates = [];
            $params = [];

            if (isset($data['first_name'])) {
                $updates[] = 'first_name = ?';
                $params[] = $data['first_name'];
            }
            if (isset($data['last_name'])) {
                $updates[] = 'last_name = ?';
                $params[] = $data['last_name'];
            }
            if (isset($data['phone'])) {
                $updates[] = 'phone = ?';
                $params[] = $data['phone'];
            }
            if (isset($data['profile_image'])) {
                $updates[] = 'profile_image = ?';
                $params[] = $data['profile_image'];
            }

            if (empty($updates)) {
                ResponseHandler::error('Aucune donnée à mettre à jour');
            }

            $params[] = $user->id;
            $query = 'UPDATE users SET ' . implode(', ', $updates) . ' WHERE id = ?';

            $stmt = $this->db->prepare($query);
            $stmt->execute($params);

            ResponseHandler::success('Profil mis à jour');
        } catch (Exception $e) {
            ResponseHandler::internalError('Erreur: ' . $e->getMessage());
        }
    }

    /**
     * ════════════════════════════════════════════════════════════════════════
     * ACTION: Logout (Déconnexion)
     * ════════════════════════════════════════════════════════════════════════
     */
    public function logout()
    {
        try {
            // ═══ Vérifier token ═══
            $user = AuthMiddleware::verifyToken();

            // ═══ Pour stateless JWT, logout se fait côté client ═══
            // Mais on peut marquer la session comme fermée côté serveur si nécessaire

            ResponseHandler::success('Déconnexion réussie');
        } catch (Exception $e) {
            ResponseHandler::internalError('Erreur: ' . $e->getMessage());
        }
    }
}
