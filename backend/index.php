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
// 3. CHARGER LA CONFIGURATION CORS SÉCURISÉE
// ═══════════════════════════════════════════════════════════════

// Inclure le fichier de configuration CORS (gestion des origines autorisées)
require_once __DIR__ . '/config/cors.php';

// ═══════════════════════════════════════════════════════════════
// 4. APPLIQUER LES HEADERS DE SÉCURITÉ CORS
// ═══════════════════════════════════════════════════════════════

// Configurer les headers CORS selon la whitelist d'origines autorisées
CORSConfig::configureHeaders();

// ═══════════════════════════════════════════════════════════════
// 5. CONFIGURER LES HEADERS GÉNÉRAUX
// ═══════════════════════════════════════════════════════════════

// Définir que toutes les réponses sont en JSON avec encodage UTF-8
header('Content-Type: application/json;charset=utf-8', true);

// ═══════════════════════════════════════════════════════════════
// 6. CHARGER LE SYSTÈME DE ROUTAGE
// ═══════════════════════════════════════════════════════════════

// Inclure le fichier qui gère toutes les routes API
require_once __DIR__ . '/routes/api.php';
