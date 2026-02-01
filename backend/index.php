<?php

/**
 * ╔══════════════════════════════════════════════════════════════╗
 * ║          POINT D'ENTRÉE API SAFEGUARDIAN CI                 ║
 * ╚══════════════════════════════════════════════════════════════╝
 * 
 * Ce fichier est le point d'entrée principal pour toutes les
 * requêtes API REST de l'application SafeGuardian CI.
 * 
 * Responsabilités:
 * - Charger la configuration d'environnement (.env)
 * - Configurer les headers de sécurité (CORS)
 * - Inclure le système de routage
 */

// ═══════════════════════════════════════════════════════════════
// 1. CHARGER LES VARIABLES D'ENVIRONNEMENT DEPUIS LE FICHIER .env
// ═══════════════════════════════════════════════════════════════

// Construire le chemin absolu du fichier .env
$envFile = __DIR__ . '/.env';

// Vérifier si le fichier .env existe
if (file_exists($envFile)) {
    // Charger le fichier ligne par ligne (ignorer les lignes vides/commentaires)
    $lines = file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);

    // Itérer sur chaque ligne du fichier .env
    foreach ($lines as $line) {
        // Ignorer les commentaires (lignes commençant par #)
        if (strpos($line, '#') === 0 || strpos($line, '=') === false) {
            continue;
        }

        // Diviser la ligne en clé et valeur (ex: "KEY=value" -> ["KEY", "value"])
        list($key, $value) = explode('=', $line, 2);

        // Stocker dans $_ENV après avoir trimé les espaces inutiles
        $_ENV[trim($key)] = trim($value);
    }
}

// ═══════════════════════════════════════════════════════════════
// 2. CONFIGURER LE FUSEAU HORAIRE
// ═══════════════════════════════════════════════════════════════

// Définir le timezone UTC pour toute l'application (cohérence mondiale)
date_default_timezone_set('UTC');

// ═══════════════════════════════════════════════════════════════
// 3. CHARGER LA CONFIGURATION DE SÉCURITÉ COMPLÈTE
// ═══════════════════════════════════════════════════════════════

require_once __DIR__ . '/config/SecurityConfig.php';

// Initialiser tous les headers de sécurité
SecurityConfig::initializeHeaders();

// Configurer CORS de manière sécurisée
SecurityConfig::setupCORS();

// ═══════════════════════════════════════════════════════════════
// 4. VÉRIFIER LES ATTAQUES BASIQUES
// ═══════════════════════════════════════════════════════════════

// Vérifier les tentatives d'injection SQL dans l'URL
if (preg_match('/(union|select|insert|delete|update|drop|create|alter|exec|script|javascript|eval)/i', $_SERVER['QUERY_STRING'] ?? '')) {
    http_response_code(403);
    die(json_encode(['error' => 'Requête suspecte détectée']));
}

// Inclure le fichier qui gère toutes les routes API
require_once __DIR__ . '/routes/api.php';
