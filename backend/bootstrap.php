<?php
/**
 * Initialisation de l'application backend
 * 
 * Ce fichier charge toutes les classes nécessaires
 */

// Définir les erreurs et avertissements
if (Config::isDevelopment()) {
    ini_set('display_errors', 1);
    error_reporting(E_ALL);
} else {
    ini_set('display_errors', 0);
    error_reporting(E_ALL);
}

// Autoloader simple
spl_autoload_register(function ($class) {
    $paths = [
        __DIR__ . '/config/',
        __DIR__ . '/controllers/',
        __DIR__ . '/middleware/',
        __DIR__ . '/utils/',
    ];

    foreach ($paths as $path) {
        $file = $path . $class . '.php';
        if (file_exists($file)) {
            require_once $file;
            return;
        }
    }
});

// Charger les configurations
require_once __DIR__ . '/config/config.php';
require_once __DIR__ . '/config/jwt.php';
require_once __DIR__ . '/config/database.php';
require_once __DIR__ . '/utils/ResponseHandler.php';
require_once __DIR__ . '/utils/Validator.php';
require_once __DIR__ . '/middleware/AuthMiddleware.php';

// Charger les contrôleurs
require_once __DIR__ . '/controllers/AuthController.php';
require_once __DIR__ . '/controllers/AlertController.php';
require_once __DIR__ . '/controllers/EmergencyContactController.php';
require_once __DIR__ . '/controllers/ItemController.php';
require_once __DIR__ . '/controllers/DocumentController.php';
