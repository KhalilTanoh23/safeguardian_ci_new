<?php

/**
 * ════════════════════════════════════════════════════════════════════════════
 * Configuration d'environnement - SafeGuardian CI
 * Charge les variables d'environnement depuis le fichier .env
 * ════════════════════════════════════════════════════════════════════════════
 */

class Config
{
    private static $env = [];

    /**
     * Charger les variables d'environnement depuis le fichier .env
     */
    public static function load($path = __DIR__ . '/../.env')
    {
        // Support pour variables d'env système (Railway)
        if (function_exists('getenv')) {
            foreach (['DATABASE_URL', 'JWT_SECRET', 'DB_DRIVER', 'CORS_ORIGINS', 'APP_ENV', 'APP_DEBUG'] as $key) {
                if ($val = getenv($key)) {
                    self::$env[$key] = $val;
                }
            }
        }

        if (!file_exists($path)) {
            if (empty(self::$env)) {
                throw new Exception("Fichier .env non trouvé à: $path");
            }
            return;

            // Diviser la ligne par le signe égal
            if (strpos($line, '=') === false) {
                continue;
            }

            [$key, $value] = explode('=', $line, 2);
            $key = trim($key);
            $value = trim($value);

            // Retirer les guillemets si présents
            $value = trim($value, '"\'');

            self::$env[$key] = $value;
        }
    }

    /**
     * Obtenir une variable d'environnement
     */
    public static function get($key, $default = null)
    {
        return self::$env[$key] ?? $default;
    }

    /**
     * Vérifier si une variable d'environnement existe
     */
    public static function has($key)
    {
        return isset(self::$env[$key]);
    }
}

// Charger les variables d'environnement automatiquement
Config::load();
