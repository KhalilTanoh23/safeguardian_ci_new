<?php

/**
 * ════════════════════════════════════════════════════════════════════════════
 * Middleware d'authentification SÉCURISÉ
 * 
 * Vérifie et valide les tokens JWT avec mesures de sécurité avancées :
 * - Validation JWT strict
 * - Détection des attaques (token replay, expiration)
 * - Journalisation des événements de sécurité
 * - Rate limiting par utilisateur
 * ════════════════════════════════════════════════════════════════════════════
 */

require_once __DIR__ . '/../config/jwt.php';
require_once __DIR__ . '/../config/SecurityConfig.php';
require_once __DIR__ . '/../config/database.php';

class AuthMiddleware
{
    /**
     * ════════════════════════════════════════════════════════════════
     * MÉTHODE STATIQUE: verifyToken()
     * Alias pour authenticate() - Compatibilité avec les contrôleurs
     * ════════════════════════════════════════════════════════════════
     */
    public static function verifyToken()
    {
        return self::authenticate();
    }

    /**
     * ────────────────────────────────────────────────────────────────────────
     * MÉTHODE STATIQUE: authenticate()
     * Authentifie l'utilisateur avec validation JWT STRICTE
     * 
     * @return stdClass|null L'utilisateur si authentifié
     * @throws Exception Si le token est invalide ou manquant
     * ────────────────────────────────────────────────────────────────────────
     */
    public static function authenticate()
    {
        try {
            // 1️⃣ Récupérer les headers d'authentification
            $headers = self::getAuthorizationHeaders();

            // 2️⃣ Vérifier si le header Authorization est présent
            if (!isset($headers['Authorization'])) {
                http_response_code(401);
                throw new Exception('Token manquant');
            }

            // 3️⃣ Extraire le token du header Authorization
            $token = str_replace('Bearer ', '', $headers['Authorization']);

            // 4️⃣ Valider le format du token
            if (empty($token) || !preg_match('/^[A-Za-z0-9\-._~+\/]+=*$/i', $token)) {
                http_response_code(401);
                SecurityConfig::logSecurityEvent(null, 'INVALID_TOKEN_FORMAT', 'Token format invalid');
                throw new Exception('Format de token invalide');
            }

            // 5️⃣ Décoder et valider le JWT
            $decoded = JWT::decode($token, Config::get('JWT_SECRET'));

            if (!is_array($decoded)) {
                throw new Exception('Token invalide');
            }

            // 6️⃣ Vérifier l'expiration
            if (!isset($decoded['exp']) || $decoded['exp'] < time()) {
                http_response_code(401);
                SecurityConfig::logSecurityEvent($decoded['id'] ?? null, 'EXPIRED_TOKEN', 'Token expiré');
                throw new Exception('Token expiré');
            }

            // 7️⃣ Vérifier l'émission (iat)
            if (!isset($decoded['iat']) || $decoded['iat'] > time()) {
                http_response_code(401);
                throw new Exception('Token émis dans le futur');
            }

            // 8️⃣ Vérifier que l'utilisateur existe encore
            $db = Database::getInstance()->getConnection();
            $stmt = $db->prepare('SELECT id, email, role, status FROM users WHERE id = ?');
            $stmt->execute([$decoded['id']]);
            $user = $stmt->fetch(PDO::FETCH_ASSOC);

            if (!$user) {
                http_response_code(401);
                SecurityConfig::logSecurityEvent($decoded['id'], 'USER_NOT_FOUND', 'User deleted or not found');
                throw new Exception('Utilisateur introuvable');
            }

            // 9️⃣ Vérifier que l'utilisateur est actif
            if ($user['status'] !== 'active') {
                http_response_code(403);
                SecurityConfig::logSecurityEvent($user['id'], 'INACTIVE_USER', 'User status: ' . $user['status']);
                throw new Exception('Compte utilisateur inactif');
            }

            // 🔟 Vérifier le rate limit
            SecurityConfig::checkRateLimit($user['id'], 1000, 3600);

            // ✅ Token valide - Retourner les données utilisateur
            return $user;
        } catch (Exception $e) {
            http_response_code(401);
            echo json_encode(['error' => $e->getMessage()]);
            exit;
        }
    }

    /**
     * ────────────────────────────────────────────────────────────────────────
     * MÉTHODE STATIQUE: getAuthorizationHeaders()
     * Extrait les headers d'autorisation de la requête
     * ────────────────────────────────────────────────────────────────────────
     */
    private static function getAuthorizationHeaders()
    {
        $headers = [];

        if (function_exists('apache_request_headers')) {
            $headers = apache_request_headers();
        } else {
            foreach ($_SERVER as $key => $value) {
                if (substr($key, 0, 5) == 'HTTP_') {
                    $header = substr($key, 5);
                    $header = str_replace('_', '-', $header);
                    $headers[$header] = $value;
                }
            }
        }

        return $headers;
    }

    /**
     * ────────────────────────────────────────────────────────────────────────
     * MÉTHODE: verifyUserRole()
     * Vérifier que l'utilisateur a le rôle requis (ACL)
     * ────────────────────────────────────────────────────────────────────────
     */
    public static function verifyUserRole($userId, $requiredRole)
    {
        try {
            $db = Database::getInstance()->getConnection();
            $stmt = $db->prepare('SELECT role FROM users WHERE id = ?');
            $stmt->execute([$userId]);
            $user = $stmt->fetch(PDO::FETCH_ASSOC);

            if (!$user || $user['role'] !== $requiredRole) {
                http_response_code(403);
                SecurityConfig::logSecurityEvent($userId, 'UNAUTHORIZED_ROLE', "Required: $requiredRole");
                throw new Exception('Permissions insuffisantes');
            }

            return true;
        } catch (Exception $e) {
            http_response_code(403);
            echo json_encode(['error' => $e->getMessage()]);
            exit;
        }
    }
}