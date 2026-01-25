<?php
/**
 * ════════════════════════════════════════════════════════════════════════════
 * Classe Config - Configuration centralisée de l'application
 * 
 * Stocke toutes les constantes de configuration en un seul endroit
 * ════════════════════════════════════════════════════════════════════════════
 */

// ═════════════════════════════════════════════════════════════════════════════
// CLASSE: Config
// Centralise toutes les configurations de l'application
// ═════════════════════════════════════════════════════════════════════════════

class Config {
    /**
     * ────────────────────────────────────────────────────────────────────────
     * CONSTANTE: Environnement
     * ────────────────────────────────────────────────────────────────────────
     */
    
    // L'environnement d'exécution de l'application
    // 'development': Mode développement avec affichage des erreurs
    // 'production': Mode production avec erreurs masquées
    const ENV = 'development';
    
    /**
     * ────────────────────────────────────────────────────────────────────────
     * CONSTANTES: Configuration Base de Données
     * Paramètres de connexion à MySQL
     * ────────────────────────────────────────────────────────────────────────
     */
    
    // L'adresse du serveur MySQL (localhost = machine locale)
    const DB_HOST = 'localhost';
    
    // Le nom de la base de données à utiliser
    const DB_NAME = 'safeguardian_ci';
    
    // L'utilisateur MySQL (root = administrateur)
    const DB_USER = 'root';
    
    // Le mot de passe MySQL (vide en développement)
    const DB_PASS = '';
    
    // Le jeu de caractères (utf8mb4 = UTF-8 complet avec support emojis)
    const DB_CHARSET = 'utf8mb4';
    
    /**
     * ────────────────────────────────────────────────────────────────────────
     * CONSTANTES: Configuration JWT (Authentification)
     * Paramètres pour les tokens d'authentification
     * ────────────────────────────────────────────────────────────────────────
     */
    
    // ⚠️  La clé secrète utilisée pour signer les tokens JWT
    // DOIT être changée en production avec une clé forte et unique
    const JWT_SECRET = 'your-secret-key-here-change-in-production';
    
    // La durée de validité du token en secondes (86400 = 24 heures)
    // Après cette période, l'utilisateur doit se reconnecter
    const JWT_EXPIRATION = 86400;
    
    /**
     * ────────────────────────────────────────────────────────────────────────
     * CONSTANTE: Répertoire des uploads
     * Où stocker les fichiers téléversés par les utilisateurs
     * ────────────────────────────────────────────────────────────────────────
     */
    
    // Le chemin absolu du répertoire où stocker les documents uploadés
    // __DIR__ = répertoire du fichier courant (/backend/config)
    // ../ = remonte d'un niveau (/backend)
    // /uploads = va au dossier uploads
    const UPLOAD_DIR = __DIR__ . '/../uploads';
    
    /**
     * ────────────────────────────────────────────────────────────────────────
     * CONSTANTES: URLs (Points d'accès)
     * Adresses URL pour l'API et le frontend
     * ────────────────────────────────────────────────────────────────────────
     */
    
    // L'URL de base de l'API (où les requêtes sont envoyées)
    const API_URL = 'http://localhost:8000/api';
    
    // L'URL du frontend (pour les redirections après authentification)
    const FRONTEND_URL = 'http://localhost:3000';
    
    /**
     * ────────────────────────────────────────────────────────────────────────
     * CONSTANTES: Configuration Email
     * Paramètres du serveur SMTP pour l'envoi d'emails
     * ────────────────────────────────────────────────────────────────────────
     */
    
    // L'adresse du serveur SMTP (mail.example.com)
    const MAIL_HOST = 'smtp.example.com';
    
    // Le port SMTP (587 = TLS, 465 = SSL)
    const MAIL_PORT = 587;
    
    // L'identifiant de connexion au serveur SMTP
    const MAIL_USER = 'your-email@example.com';
    
    // Le mot de passe du compte email
    const MAIL_PASS = 'your-password';
    
    // L'adresse email d'où proviennent les emails automatiques
    const MAIL_FROM = 'noreply@safeguardian.ci';
    
    /**
     * ────────────────────────────────────────────────────────────────────────
     * MÉTHODE STATIQUE: get()
     * Récupérer une valeur de configuration par clé
     * @param string $key La clé de configuration à récupérer
     * @param mixed $default Valeur par défaut si la clé n'existe pas
     * @return mixed La valeur de la configuration
     * ────────────────────────────────────────────────────────────────────────
     */
    public static function get($key, $default = null) {
        // Vérifier si la clé existe comme constante dans cette classe
        // defined() vérifie si une constante existe
        // constant() récupère la valeur de la constante
        return defined("self::$key") ? constant("self::$key") : $default;
    }
    
    /**
     * ────────────────────────────────────────────────────────────────────────
     * MÉTHODE STATIQUE: isDevelopment()
     * Vérifier si l'application est en mode développement
     * @return bool true si en développement, false sinon
     * ────────────────────────────────────────────────────────────────────────
     */
    public static function isDevelopment() {
        // Comparer l'environnement avec la chaîne 'development'
        return self::ENV === 'development';
    }
    
    /**
     * ────────────────────────────────────────────────────────────────────────
     * MÉTHODE STATIQUE: isProduction()
     * Vérifier si l'application est en mode production
     * @return bool true si en production, false sinon
     * ────────────────────────────────────────────────────────────────────────
     */
    public static function isProduction() {
        // Comparer l'environnement avec la chaîne 'production'
        return self::ENV === 'production';
    }
}
