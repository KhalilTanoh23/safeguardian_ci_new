<?php
/**
 * Rate Limiter - Protection contre les attaques par force brute
 * 
 * Utilise APCu ou fichiers pour le cache
 */

class RateLimiter {
    /**
     * Vérifier et enregistrer une tentative
     * 
     * @param string $identifier Identifiant unique (email, IP, etc)
     * @param string $action Type d'action (login, password_reset, etc)
     * @param int $maxAttempts Nombre maximum de tentatives
     * @param int $windowSeconds Durée de la fenêtre (en secondes)
     * @return array ['allowed' => bool, 'remaining' => int, 'retryAfter' => int]
     */
    public static function checkLimit(
        $identifier,
        $action = 'login',
        $maxAttempts = 5,
        $windowSeconds = 900
    ) {
        $cacheKey = "rate_limit:{$action}:{$identifier}";
        
        // Obtenir les tentatives précédentes
        $data = self::getCacheData($cacheKey);
        $attempts = $data['attempts'] ?? 0;
        $firstAttempt = $data['firstAttempt'] ?? time();
        
        // Vérifier si la fenêtre a expiré
        if (time() - $firstAttempt > $windowSeconds) {
            // Réinitialiser
            self::setCacheData($cacheKey, [
                'attempts' => 1,
                'firstAttempt' => time()
            ], $windowSeconds);
            
            return [
                'allowed' => true,
                'remaining' => $maxAttempts - 1,
                'retryAfter' => 0
            ];
        }
        
        $attempts++;
        
        // Enregistrer la tentative
        self::setCacheData($cacheKey, [
            'attempts' => $attempts,
            'firstAttempt' => $firstAttempt
        ], $windowSeconds);
        
        $allowed = $attempts <= $maxAttempts;
        $remaining = max(0, $maxAttempts - $attempts);
        $retryAfter = $windowSeconds - (time() - $firstAttempt);
        
        return [
            'allowed' => $allowed,
            'remaining' => $remaining,
            'retryAfter' => $retryAfter
        ];
    }

    /**
     * Réinitialiser les tentatives
     */
    public static function reset($identifier, $action = 'login') {
        $cacheKey = "rate_limit:{$action}:{$identifier}";
        self::deleteCacheData($cacheKey);
    }

    /**
     * Obtenir les données du cache
     */
    private static function getCacheData($key) {
        // Utiliser APCu si disponible
        if (function_exists('apcu_fetch')) {
            $data = apcu_fetch($key);
            return $data !== false ? $data : [];
        }
        
        // Sinon utiliser les fichiers
        return self::getFileData($key);
    }

    /**
     * Stocker les données en cache
     */
    private static function setCacheData($key, $data, $ttl = 900) {
        // Utiliser APCu si disponible
        if (function_exists('apcu_store')) {
            apcu_store($key, $data, $ttl);
            return;
        }
        
        // Sinon utiliser les fichiers
        self::setFileData($key, $data, $ttl);
    }

    /**
     * Supprimer les données du cache
     */
    private static function deleteCacheData($key) {
        // APCu
        if (function_exists('apcu_delete')) {
            apcu_delete($key);
            return;
        }
        
        // Fichiers
        self::deleteFileData($key);
    }

    /**
     * Stocker les données dans un fichier
     */
    private static function setFileData($key, $data, $ttl = 900) {
        $cacheDir = sys_get_temp_dir() . '/safeguardian_cache';
        
        // Créer le répertoire s'il n'existe pas
        if (!is_dir($cacheDir)) {
            mkdir($cacheDir, 0700, true);
        }
        
        $filename = $cacheDir . '/' . hash('sha256', $key) . '.json';
        $content = [
            'data' => $data,
            'expires' => time() + $ttl
        ];
        
        file_put_contents($filename, json_encode($content));
    }

    /**
     * Récupérer les données d'un fichier
     */
    private static function getFileData($key) {
        $cacheDir = sys_get_temp_dir() . '/safeguardian_cache';
        $filename = $cacheDir . '/' . hash('sha256', $key) . '.json';
        
        if (!file_exists($filename)) {
            return [];
        }
        
        $content = json_decode(file_get_contents($filename), true);
        
        // Vérifier l'expiration
        if (isset($content['expires']) && $content['expires'] < time()) {
            unlink($filename);
            return [];
        }
        
        return $content['data'] ?? [];
    }

    /**
     * Supprimer les données d'un fichier
     */
    private static function deleteFileData($key) {
        $cacheDir = sys_get_temp_dir() . '/safeguardian_cache';
        $filename = $cacheDir . '/' . hash('sha256', $key) . '.json';
        
        if (file_exists($filename)) {
            unlink($filename);
        }
    }

    /**
     * Obtenir l'adresse IP du client
     */
    public static function getClientIP() {
        if (!empty($_SERVER['HTTP_CLIENT_IP'])) {
            return $_SERVER['HTTP_CLIENT_IP'];
        }
        
        if (!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) {
            // Utiliser la première IP
            $ips = explode(',', $_SERVER['HTTP_X_FORWARDED_FOR']);
            return trim($ips[0]);
        }
        
        return $_SERVER['REMOTE_ADDR'] ?? 'unknown';
    }
}
