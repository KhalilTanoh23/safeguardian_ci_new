<?php

/**
 * ════════════════════════════════════════════════════════════════════════════
 * CONFIGURATION DE SÉCURITÉ - SafeGuardian CI
 * 
 * Centralise toutes les mesures de sécurité :
 * - Headers HTTP sécurisés
 * - Rate limiting
 * - CORS
 * - CSRF protection
 * - Content Security Policy
 * ════════════════════════════════════════════════════════════════════════════
 */

class SecurityConfig
{
    /**
     * Initialiser tous les headers de sécurité
     */
    public static function initializeHeaders()
    {
        header('X-Frame-Options: SAMEORIGIN');
        header('X-Content-Type-Options: nosniff');
        header('X-XSS-Protection: 1; mode=block');
        header('Strict-Transport-Security: max-age=31536000; includeSubDomains');
        header("Content-Security-Policy: default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; font-src 'self'");
        header('Referrer-Policy: strict-origin-when-cross-origin');
        header('Permissions-Policy: geolocation=(), microphone=(), camera=()');
        header('Content-Type: application/json; charset=utf-8');
    }

    /**
     * Configurer CORS de manière sécurisée
     */
    public static function setupCORS()
    {
        $allowedOrigins = [
            'http://localhost:3000',
            'http://localhost:8000',
            'https://safeguardian.app',
            'https://www.safeguardian.app'
        ];

        $origin = $_SERVER['HTTP_ORIGIN'] ?? '';

        if (in_array($origin, $allowedOrigins)) {
            header('Access-Control-Allow-Origin: ' . $origin);
            header('Access-Control-Allow-Credentials: true');
            header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS, PATCH');
            header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With, X-CSRF-Token');
            header('Access-Control-Max-Age: 3600');
        }

        if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
            http_response_code(200);
            exit();
        }
    }

    /**
     * Implémenter le Rate Limiting
     */
    public static function checkRateLimit($userId, $limit = 100, $window = 3600)
    {
        $sessionKey = "rate_limit_{$userId}";

        if (!isset($_SESSION[$sessionKey])) {
            $_SESSION[$sessionKey] = [
                'count' => 0,
                'reset_time' => time() + $window
            ];
        }

        $limiter = &$_SESSION[$sessionKey];

        if (time() > $limiter['reset_time']) {
            $limiter['count'] = 0;
            $limiter['reset_time'] = time() + $window;
        }

        $limiter['count']++;

        if ($limiter['count'] > $limit) {
            http_response_code(429);
            die(json_encode(['error' => 'Trop de requêtes']));
        }
    }

    /**
     * Sanitizer les entrées
     */
    public static function sanitizeInput($data)
    {
        if (is_array($data)) {
            return array_map([self::class, 'sanitizeInput'], $data);
        }

        $data = trim($data);
        $data = htmlspecialchars($data, ENT_QUOTES, 'UTF-8');

        return $data;
    }

    /**
     * Enregistrer les activités de sécurité
     */
    public static function logSecurityEvent($userId, $eventType, $details = '')
    {
        try {
            require_once __DIR__ . '/database.php';
            $db = Database::getInstance()->getConnection();

            $stmt = $db->prepare(
                'INSERT INTO security_audits (user_id, event_type, details, ip_address, user_agent) 
                 VALUES (?, ?, ?, ?, ?)'
            );

            $stmt->execute([
                $userId,
                $eventType,
                $details,
                $_SERVER['REMOTE_ADDR'] ?? 'unknown',
                $_SERVER['HTTP_USER_AGENT'] ?? 'unknown'
            ]);
        } catch (Exception $e) {
            error_log('Security logging failed: ' . $e->getMessage());
        }
    }

    /**
     * Vérifier l'adresse IP
     */
    public static function getClientIP()
    {
        $ipKeys = ['HTTP_CF_CONNECTING_IP', 'HTTP_X_FORWARDED_FOR', 'REMOTE_ADDR'];

        foreach ($ipKeys as $key) {
            if (array_key_exists($key, $_SERVER) === true) {
                foreach (explode(',', $_SERVER[$key]) as $ip) {
                    $ip = trim($ip);

                    if ((bool) filter_var($ip, FILTER_VALIDATE_IP)) {
                        return $ip;
                    }
                }
            }
        }

        return $_SERVER['REMOTE_ADDR'] ?? 'unknown';
    }

    /**
     * Valider les permissions (ACL)
     */
    public static function checkPermission($userId, $resourceId, $resourceType, $action = 'view')
    {
        try {
            require_once __DIR__ . '/database.php';
            $db = Database::getInstance()->getConnection();

            $query = '';
            $params = [$userId];

            switch ($resourceType) {
                case 'alert':
                    $query = 'SELECT id FROM alerts WHERE id = ? AND user_id = ?';
                    $params = [$resourceId, $userId];
                    break;
                case 'contact':
                    $query = 'SELECT id FROM emergency_contacts WHERE id = ? AND user_id = ?';
                    $params = [$resourceId, $userId];
                    break;
                case 'document':
                    $query = 'SELECT id FROM documents WHERE id = ? AND user_id = ?';
                    $params = [$resourceId, $userId];
                    break;
                case 'item':
                    $query = 'SELECT id FROM items WHERE id = ? AND user_id = ?';
                    $params = [$resourceId, $userId];
                    break;
                default:
                    return false;
            }

            $stmt = $db->prepare($query);
            $stmt->execute($params);

            return $stmt->rowCount() > 0;
        } catch (Exception $e) {
            error_log('Permission check failed: ' . $e->getMessage());
            return false;
        }
    }
}

// Sessions sécurisées
session_start([
    'cookie_httponly' => true,
    'cookie_samesite' => 'Strict',
    'cookie_secure' => !empty($_SERVER['HTTPS']),
    'use_only_cookies' => true,
]);
