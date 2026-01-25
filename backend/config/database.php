<?php
/**
 * ════════════════════════════════════════════════════════════════════════════
 * Classe Database - Gestion de la connexion à la base de données
 * 
 * Utilise le pattern Singleton pour garantir une seule instance PDO
 * ════════════════════════════════════════════════════════════════════════════
 */

// ═════════════════════════════════════════════════════════════════════════════
// CLASSE: Database
// Gère la connexion PDO à la base de données MySQL
// ═════════════════════════════════════════════════════════════════════════════

class Database {
    /**
     * ────────────────────────────────────────────────────────────────────────
     * PROPRIÉTÉ STATIQUE: $instance
     * Stocke l'instance unique de la classe (pattern Singleton)
     * ────────────────────────────────────────────────────────────────────────
     */
    private static $instance = null;
    
    /**
     * ────────────────────────────────────────────────────────────────────────
     * PROPRIÉTÉ: $pdo
     * Objet PDO représentant la connexion à la base de données
     * ────────────────────────────────────────────────────────────────────────
     */
    private $pdo;

    /**
     * ────────────────────────────────────────────────────────────────────────
     * CONSTRUCTEUR PRIVÉ: __construct()
     * Initialise la connexion PDO à la base de données
     * Privé pour forcer l'utilisation du pattern Singleton
     * ────────────────────────────────────────────────────────────────────────
     */
    private function __construct() {
        // ───── Configuration de connexion
        
        // Serveur MySQL (localhost = machine locale)
        $host = 'localhost';
        
        // Nom de la base de données à utiliser
        $db = 'safeguardian_ci';
        
        // Utilisateur MySQL (root = administrateur)
        $user = 'root';
        
        // Mot de passe (vide par défaut en développement)
        $pass = '';
        
        // Jeu de caractères (utf8mb4 = UTF-8 avec support des emojis)
        $charset = 'utf8mb4';

        // ───── Construire la chaîne de connexion DSN (Data Source Name)
        // Format: mysql:host=serveur;dbname=base_de_donnees;charset=encodage
        $dsn = "mysql:host=$host;dbname=$db;charset=$charset";
        
        // ───── Options de configuration PDO
        $options = [
            // ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION: Lancer des exceptions en cas d'erreur
            // Cela facilite la détection et le gestion des erreurs
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            
            // ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC: Récupérer les résultats sous forme de tableaux associatifs
            // Cela permet d'accéder aux colonnes par nom plutôt que par index
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            
            // ATTR_EMULATE_PREPARES => false: Désactiver la préparation émulée par PDO
            // Utiliser la préparation native du serveur pour une meilleure sécurité (protection SQL injection)
            PDO::ATTR_EMULATE_PREPARES   => false,
        ];

        // ───── Tenter de créer la connexion
        try {
            // Créer une nouvelle instance PDO avec les paramètres fournis
            $this->pdo = new PDO($dsn, $user, $pass, $options);
        } catch (PDOException $e) {
            // En cas d'erreur de connexion, relancer l'exception avec les détails
            throw new PDOException($e->getMessage(), (int)$e->getCode());
        }
    }

    /**
     * ────────────────────────────────────────────────────────────────────────
     * MÉTHODE STATIQUE: getInstance()
     * Retourne l'instance unique de la base de données (pattern Singleton)
     * @return Database L'instance unique de la classe Database
     * ────────────────────────────────────────────────────────────────────────
     */
    public static function getInstance() {
        // Vérifier si aucune instance n'a encore été créée
        if (self::$instance == null) {
            // Créer la première instance (et la seule)
            self::$instance = new Database();
        }
        // Retourner l'instance existante
        return self::$instance;
    }

    /**
     * ────────────────────────────────────────────────────────────────────────
     * MÉTHODE: getConnection()
     * Retourne l'objet PDO pour exécuter des requêtes
     * @return PDO L'objet de connexion PDO
     * ────────────────────────────────────────────────────────────────────────
     */
    public function getConnection() {
        // Retourner l'objet PDO qui représente la connexion active
        return $this->pdo;
    }
}
