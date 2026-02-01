<?php

/**
 * ════════════════════════════════════════════════════════════════════════════
 * Bootstrap - Initialisation de l'application SafeGuardian CI
 * ════════════════════════════════════════════════════════════════════════════
 */

// Définir la racine de l'application
define('APP_ROOT', __DIR__);

// Charger les variables d'environnement
$envFile = APP_ROOT . '/.env';
if (!file_exists($envFile)) {
    die('Fichier .env non trouvé');
}

$lines = file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
foreach ($lines as $line) {
    if (strpos($line, '#') === 0 || strpos($line, '=') === false) {
        continue;
    }
    list($key, $value) = explode('=', $line, 2);
    $_ENV[trim($key)] = trim($value);
}

// Charger les configurations de base
require_once APP_ROOT . '/config/env.php';
require_once APP_ROOT . '/config/database.php';
require_once APP_ROOT . '/config/cors.php';
require_once APP_ROOT . '/config/jwt.php';
require_once APP_ROOT . '/config/SecurityConfig.php';
