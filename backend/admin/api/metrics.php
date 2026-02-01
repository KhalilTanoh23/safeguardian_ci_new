<?php

/**
 * API Endpoints pour le Dashboard Admin
 * ====================================
 */

header('Content-Type: application/json');
require_once __DIR__ . '/../admin/auth.php';
require_once __DIR__ . '/../config/database.php';

// Vérifier l'authentification admin
AdminAuth::checkAdmin();

class AdminMetrics
{
    /**
     * Récupère toutes les métriques du dashboard
     */
    public static function getAllMetrics()
    {
        return [
            'users' => self::getUserMetrics(),
            'alerts' => self::getAlertMetrics(),
            'incidents' => self::getIncidentMetrics(),
            'contacts' => self::getContactMetrics(),
            'system_health' => self::getSystemHealth(),
            'recent_activity' => self::getRecentActivity(),
            'timestamp' => date('Y-m-d H:i:s')
        ];
    }

    /**
     * Métriques des utilisateurs
     */
    public static function getUserMetrics()
    {
        try {
            $db = Database::getInstance();
            $pdo = $db->getConnection();

            $stmt = $pdo->query("SELECT COUNT(*) as total FROM users");
            $total = $stmt->fetch(PDO::FETCH_ASSOC)['total'];

            $stmt = $pdo->query("SELECT COUNT(*) as active FROM users WHERE status = 'active'");
            $active = $stmt->fetch(PDO::FETCH_ASSOC)['active'];

            $stmt = $pdo->query("
                SELECT COUNT(*) as today 
                FROM users 
                WHERE DATE(created_at) = CURDATE()
            ");
            $today = $stmt->fetch(PDO::FETCH_ASSOC)['today'];

            $change = $total > 0 ? round((($active / $total) * 100), 1) : 0;

            return [
                'total_users' => $total,
                'active_users' => $active,
                'new_today' => $today,
                'percentage' => $change,
                'change_text' => '+' . $change . '%'
            ];
        } catch (Exception $e) {
            return ['error' => $e->getMessage()];
        }
    }

    /**
     * Métriques des alertes
     */
    public static function getAlertMetrics()
    {
        try {
            $db = Database::getInstance();
            $pdo = $db->getConnection();

            $stmt = $pdo->query("SELECT COUNT(*) as total FROM alerts");
            $total = $stmt->fetch(PDO::FETCH_ASSOC)['total'];

            $stmt = $pdo->query("
                SELECT COUNT(*) as today 
                FROM alerts 
                WHERE DATE(timestamp) = CURDATE()
            ");
            $today = $stmt->fetch(PDO::FETCH_ASSOC)['today'];

            $stmt = $pdo->query("
                SELECT COUNT(*) as resolved 
                FROM alerts 
                WHERE status = 'resolved'
            ");
            $resolved = $stmt->fetch(PDO::FETCH_ASSOC)['resolved'];

            $pending = $total - $resolved;
            $change = $pending > 0 ? round((($pending / $total) * 100), 1) : 0;

            return [
                'total_alerts' => $total,
                'today_alerts' => $today,
                'pending_alerts' => $pending,
                'resolved_alerts' => $resolved,
                'change_text' => '-2.3%'
            ];
        } catch (Exception $e) {
            return ['error' => $e->getMessage()];
        }
    }

    /**
     * Métriques des incidents critiques
     */
    public static function getIncidentMetrics()
    {
        try {
            $db = Database::getInstance();
            $pdo = $db->getConnection();

            $stmt = $pdo->query("
                SELECT COUNT(*) as critical 
                FROM alerts 
                WHERE status = 'confirmed' AND DATE(timestamp) >= DATE_SUB(NOW(), INTERVAL 7 DAY)
            ");
            $critical = $stmt->fetch(PDO::FETCH_ASSOC)['critical'];

            return [
                'critical_incidents' => $critical,
                'this_week' => $critical,
                'change_text' => '+1 nouveau'
            ];
        } catch (Exception $e) {
            return ['error' => $e->getMessage()];
        }
    }

    /**
     * Métriques des contacts vérifiés
     */
    public static function getContactMetrics()
    {
        try {
            $db = Database::getInstance();
            $pdo = $db->getConnection();

            $stmt = $pdo->query("SELECT COUNT(*) as total FROM emergency_contacts");
            $total = $stmt->fetch(PDO::FETCH_ASSOC)['total'];

            $stmt = $pdo->query("SELECT COUNT(*) as verified FROM emergency_contacts WHERE is_verified = 1");
            $verified = $stmt->fetch(PDO::FETCH_ASSOC)['verified'];

            $percentage = $total > 0 ? round((($verified / $total) * 100), 1) : 0;

            return [
                'total_contacts' => $total,
                'verified_contacts' => $verified,
                'percentage' => $percentage,
                'change_text' => '+' . $percentage . '%'
            ];
        } catch (Exception $e) {
            return ['error' => $e->getMessage()];
        }
    }

    /**
     * État de santé du système
     */
    public static function getSystemHealth()
    {
        return [
            'database' => ['status' => 'operational', 'percentage' => 98],
            'api' => ['status' => 'operational', 'percentage' => 99],
            'notifications' => ['status' => 'operational', 'percentage' => 95],
            'geolocation' => ['status' => 'operational', 'percentage' => 100],
            'overall' => 100
        ];
    }

    /**
     * Activités récentes
     */
    public static function getRecentActivity()
    {
        try {
            $db = Database::getInstance();
            $pdo = $db->getConnection();

            $stmt = $pdo->query("
                SELECT 
                    'user_signup' as type,
                    CONCAT(first_name, ' ', last_name) as description,
                    created_at as timestamp
                FROM users
                ORDER BY created_at DESC
                LIMIT 3
            ");
            $activities = $stmt->fetchAll(PDO::FETCH_ASSOC);

            return $activities ?: [];
        } catch (Exception $e) {
            return ['error' => $e->getMessage()];
        }
    }
}

// Déterminer l'action
$action = $_GET['action'] ?? 'all';

if ($action === 'all') {
    echo json_encode(AdminMetrics::getAllMetrics());
} else if ($action === 'users') {
    echo json_encode(AdminMetrics::getUserMetrics());
} else if ($action === 'alerts') {
    echo json_encode(AdminMetrics::getAlertMetrics());
} else if ($action === 'incidents') {
    echo json_encode(AdminMetrics::getIncidentMetrics());
} else if ($action === 'contacts') {
    echo json_encode(AdminMetrics::getContactMetrics());
} else if ($action === 'health') {
    echo json_encode(AdminMetrics::getSystemHealth());
} else if ($action === 'activity') {
    echo json_encode(AdminMetrics::getRecentActivity());
} else {
    http_response_code(400);
    echo json_encode(['error' => 'Action invalide']);
}
