<?php

/**
 * ════════════════════════════════════════════════════════════════════════════
 * CONTRÔLEUR DES EMPLACEMENTS - LocationController
 * 
 * Gère toutes les opérations liées aux emplacements et géolocalisation:
 * - Mettre à jour la position GPS actuelle
 * - Récupérer l'historique des positions
 * - Récupérer la dernière position connue
 * 
 * Fonctionnalités:
 * - Enregistrement des coordonnées (latitude, longitude, précision, altitude)
 * - Timestamp automatique (recorded_at)
 * - Historique chronologique des mouvements
 * ════════════════════════════════════════════════════════════════════════════
 */

// Inclure la configuration pour accéder à la classe Database
require_once __DIR__ . '/../config/database.php';

// Inclure le middleware d'authentification
require_once __DIR__ . '/../middleware/AuthMiddleware.php';

// ═════════════════════════════════════════════════════════════════════════════
// CLASSE: LocationController
// Contrôleur responsable de la gestion des emplacements utilisateur
// ═════════════════════════════════════════════════════════════════════════════

class LocationController
{
    /**
     * ────────────────────────────────────────────────────────────────────────
     * PROPRIÉTÉ: $db
     * Stocke la connexion PDO pour exécuter les requêtes SQL
     * ────────────────────────────────────────────────────────────────────────
     */
    private $db;

    /**
     * ────────────────────────────────────────────────────────────────────────
     * CONSTRUCTEUR: __construct()
     * Initialise le contrôleur avec la connexion à la base de données
     * ────────────────────────────────────────────────────────────────────────
     */
    public function __construct()
    {
        // Récupérer la connexion PDO depuis l'instance Singleton de Database
        $this->db = Database::getInstance()->getConnection();
    }

    // ═════════════════════════════════════════════════════════════════════════
    // SIGNATURES DES MÉTHODES (Interface)
    // ═════════════════════════════════════════════════════════════════════════

    /**
     * Mettre à jour la position actuelle de l'utilisateur
     * 
     * @return void
     */
    public function updateLocation()
    {
        throw new Exception('Méthode non implémentée');
    }

    /**
     * Récupérer l'historique des positions de l'utilisateur
     * 
     * @return void
     */
    public function getLocationHistory()
    {
        throw new Exception('Méthode non implémentée');
    }

    /**
     * Récupérer la dernière position connue de l'utilisateur
     * 
     * @return void
     */
    public function getLastLocation()
    {
        throw new Exception('Méthode non implémentée');
    }
}
