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
        if (!file_exists($path)) {
            throw new Exception("Fichier .env non trouvé à: $path");
        }

        $lines = file($path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);

        foreach ($lines as $line) {
            // Ignorer les commentaires
            if (strpos(trim($line), '#') === 0) {
                continue;
            }

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
