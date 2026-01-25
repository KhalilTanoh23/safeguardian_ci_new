<?php
/**
 * ════════════════════════════════════════════════════════════════════════════
 * Configuration CORS (Cross-Origin Resource Sharing) Sécurisée
 * 
 * Gère les requêtes cross-origin et restreint les domaines autorisés
 * selon l'environnement (développement, staging, production)
 * ════════════════════════════════════════════════════════════════════════════
 */

// ═════════════════════════════════════════════════════════════════════════════
// CLASSE: CORSConfig
// Gestion centralisée de la configuration CORS et des headers de sécurité
// ═════════════════════════════════════════════════════════════════════════════

class CORSConfig {
    /**
     * ────────────────────────────────────────────────────────────────────────
     * PROPRIÉTÉ: Domaines autorisés par environnement
     * Stocke les origines (domaines) autorisées pour chaque environnement
     * ────────────────────────────────────────────────────────────────────────
     */
    private static $allowedOrigins = [
        // ───── Domaines autorisés en développement (localhost)
        'development' => [
            // Port 3000 typiquement utilisé par React/Vue en développement
            'http://localhost:3000',
            // Port 8080 typiquement utilisé par Flutter web
            'http://localhost:8080',
            // Port 8000 typiquement utilisé par Django/PHP
            'http://localhost:8000',
            // Adresses 127.0.0.1 (localhost) avec différents ports
            'http://127.0.0.1:3000',
            'http://127.0.0.1:8080',
            'http://127.0.0.1:8000',
        ],
        // ───── Domaines autorisés en production (HTTPS uniquement)
        'production' => [
            // Application principale
            'https://app.safeguardian.ci',
            // Interface d'administration
            'https://admin.safeguardian.ci',
            // Site web principal
            'https://www.safeguardian.ci',
        ],
        // ───── Domaines autorisés en staging (environnement de test)
        'staging' => [
            // Application de test
            'https://staging-app.safeguardian.ci',
            // Interface d'administration de test
            'https://staging-admin.safeguardian.ci',
        ]
    ];

    /**
     * ────────────────────────────────────────────────────────────────────────
     * MÉTHODE: configureHeaders()
     * Configure les headers CORS pour autoriser les requêtes cross-origin
     * @throws Exception Si l'origine n'est pas autorisée
     * ────────────────────────────────────────────────────────────────────────
     */
    public static function configureHeaders() {
        // Récupérer l'origine de la requête (le domaine qui effectue la requête)
        $origin = $_SERVER['HTTP_ORIGIN'] ?? '';
        
        // Récupérer l'environnement courant (development/staging/production)
        $environment = $_ENV['APP_ENV'] ?? 'development';
        
        // Récupérer la liste des origines autorisées pour cet environnement
        $allowed = self::$allowedOrigins[$environment] ?? [];
        
        // Récupérer les origines personnalisées depuis les variables d'environnement
        $customOrigins = $_ENV['CORS_ORIGINS'] ?? '';
        
        // Si des origines personnalisées sont configurées
        if (!empty($customOrigins)) {
            // Diviser la chaîne par des virgules et trimmer les espaces
            $customArray = explode(',', $customOrigins);
            // Fusionner les origines personnalisées avec les origines pré-configurées
            $allowed = array_merge($allowed, array_map('trim', $customArray));
        }
        
        // Vérifier si l'origine est présente (requête locale ou sans origine)
        if (empty($origin)) {
            // Pas d'origine fournie = requête locale ou non-CORS, autoriser
            return;
        }
        
        // Vérifier si l'origine est dans la liste des origines autorisées
        if (!in_array($origin, $allowed, true)) {
            // L'origine n'est pas autorisée, rejeter la requête
            self::rejectRequest('Origin not allowed: ' . $origin);
            // La fonction rejectRequest() appelle exit(), donc on ne continue pas
            return;
        }
        
        // ───── Configurer les headers CORS pour autoriser la requête
        
        // Indiquer au navigateur que l'origine est autorisée à accéder à la ressource
        header("Access-Control-Allow-Origin: $origin", true);
        
        // Autoriser les cookies et les credentials dans les requêtes cross-origin
        header('Access-Control-Allow-Credentials: true', true);
        
        // Lister les méthodes HTTP autorisées pour les requêtes cross-origin
        header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS, PATCH', true);
        
        // Lister les headers HTTP autorisés dans les requêtes cross-origin
        // Content-Type: type de contenu (application/json)
        // Authorization: pour les tokens JWT
        // X-Requested-With: indicateur de requête AJAX
        // X-CSRF-Token: token de protection contre les attaques CSRF
        header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With, X-CSRF-Token', true);
        
        // Durée pendant laquelle le navigateur peut mettre en cache les résultats CORS (1 jour)
        header('Access-Control-Max-Age: 86400', true);
        
        // Headers supplémentaires qu'on expose au client JavaScript
        header('Access-Control-Expose-Headers: Content-Type, X-Total-Count', true);
        
        // Ajouter les headers de sécurité supplémentaires
        self::addSecurityHeaders();
    }

    /**
     * ────────────────────────────────────────────────────────────────────────
     * MÉTHODE: addSecurityHeaders()
     * Ajoute les headers de sécurité supplémentaires pour protéger l'API
     * ────────────────────────────────────────────────────────────────────────
     */
    private static function addSecurityHeaders() {
        // ───── Prévenir le Clickjacking (X-Frame-Options)
        // DENY: Empêcher le document d'être affiché dans une iframe, même sur le même domaine
        header('X-Frame-Options: DENY', true);
        
        // ───── Prévenir la détection du MIME type (X-Content-Type-Options)
        // nosniff: Le navigateur ne doit pas interpréter le contenu différemment du MIME type déclaré
        // Cela prévient les attaques basées sur l'interprétation de fichiers
        header('X-Content-Type-Options: nosniff', true);
        
        // ───── Prévenir les attaques XSS dans les anciens navigateurs (X-XSS-Protection)
        // 1: Activer la protection XSS du navigateur
        // mode=block: Bloquer la page si une attaque XSS est détectée
        header('X-XSS-Protection: 1; mode=block', true);
        
        // ───── Politique de sécurité du contenu (Content-Security-Policy)
        // default-src 'self': Charger les ressources uniquement depuis le même domaine
        // script-src 'self' 'unsafe-inline': Scripts autorisés depuis le même domaine et scripts inline
        // style-src 'self' 'unsafe-inline': Styles autorisés depuis le même domaine et styles inline
        header("Content-Security-Policy: default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'", true);
        
        // ───── Politique de Referrer (Referrer-Policy)
        // strict-origin-when-cross-origin: Envoyer l'origine dans les requêtes cross-origin mais pas le chemin
        header('Referrer-Policy: strict-origin-when-cross-origin', true);
        
        // ───── Politique des permissions (Permissions-Policy)
        // Désactiver l'accès à la géolocalisation, microphone et caméra
        // Cette API s'appelle Permissions-Policy (anciennement Feature-Policy)
        header('Permissions-Policy: geolocation=(), microphone=(), camera=()', true);
        
        // ───── Forcer HTTPS en production (Strict-Transport-Security)
        // Vérifier si le forçage HTTPS est activé ou si on est en production
        if (($_ENV['FORCE_HTTPS'] ?? false) || $_ENV['APP_ENV'] === 'production') {
            // max-age=31536000: Durée de vie du header (1 an en secondes)
            // includeSubDomains: Appliquer également aux sous-domaines
            // Cette en-tête indique au navigateur d'utiliser HTTPS pour toutes les futures requêtes
            header('Strict-Transport-Security: max-age=31536000; includeSubDomains', true);
        }
    }

    /**
     * ────────────────────────────────────────────────────────────────────────
     * MÉTHODE: rejectRequest()
     * Rejette une requête CORS non autorisée avec un message d'erreur
     * @param string $reason Raison du rejet (affichée si DEBUG est activé)
     * ────────────────────────────────────────────────────────────────────────
     */
    private static function rejectRequest($reason = 'Request rejected') {
        // Définir le code HTTP 403 (Interdit)
        http_response_code(403);
        
        // Vérifier si le mode DEBUG est activé
        if ($_ENV['APP_DEBUG'] ?? false) {
            // En debug, afficher les détails du rejet pour faciliter le dépannage
            echo json_encode([
                // Type d'erreur
                'error' => 'CORS Error',
                // Raison détaillée du rejet
                'message' => $reason,
                // Domaine qui a effectué la requête
                'origin' => $_SERVER['HTTP_ORIGIN'] ?? 'unknown'
            ]);
        } else {
            // En production, afficher un message d'erreur générique pour ne pas révéler d'infos
            echo json_encode([
                'error' => 'Forbidden',
                'message' => 'Access denied'
            ]);
        }
        
        // Arrêter l'exécution du script
        exit;
    }

    /**
     * ────────────────────────────────────────────────────────────────────────
     * MÉTHODE: addOrigin()
     * Ajouter une origine dynamiquement (utile pour les tests)
     * @param string $origin Le domaine à ajouter
     * @param string $environment L'environnement (development/staging/production)
     * ────────────────────────────────────────────────────────────────────────
     */
    public static function addOrigin($origin, $environment = 'development') {
        // Vérifier si l'environnement existe dans la configuration
        if (!isset(self::$allowedOrigins[$environment])) {
            // Si non, créer un tableau vide pour cet environnement
            self::$allowedOrigins[$environment] = [];
        }
        
        // Vérifier que l'origine n'existe pas déjà pour éviter les doublons
        if (!in_array($origin, self::$allowedOrigins[$environment])) {
            // Ajouter l'origine à la liste
            self::$allowedOrigins[$environment][] = $origin;
        }
    }

    /**
     * ────────────────────────────────────────────────────────────────────────
     * MÉTHODE: isOriginAllowed()
     * Vérifier si une origine est autorisée
     * @param string $origin Le domaine à vérifier
     * @return boolean true si l'origine est autorisée, false sinon
     * ────────────────────────────────────────────────────────────────────────
     */
    public static function isOriginAllowed($origin) {
        // Récupérer l'environnement courant
        $environment = $_ENV['APP_ENV'] ?? 'development';
        
        // Récupérer les origines autorisées pour cet environnement
        $allowed = self::$allowedOrigins[$environment] ?? [];
        
        // Récupérer les origines personnalisées depuis les variables d'environnement
        $customOrigins = $_ENV['CORS_ORIGINS'] ?? '';
        
        // Si des origines personnalisées sont configurées
        if (!empty($customOrigins)) {
            // Diviser et fusionner avec les origines pré-configurées
            $customArray = explode(',', $customOrigins);
            $allowed = array_merge($allowed, array_map('trim', $customArray));
        }
        
        // Vérifier si l'origine se trouve dans la liste des autorisées
        return in_array($origin, $allowed, true);
    }

    /**
     * ────────────────────────────────────────────────────────────────────────
     * MÉTHODE: getAllowedOrigins()
     * Lister toutes les origines autorisées pour l'environnement courant
     * @return array Liste des domaines autorisés
     * ────────────────────────────────────────────────────────────────────────
     */
    public static function getAllowedOrigins() {
        // Récupérer l'environnement courant
        $environment = $_ENV['APP_ENV'] ?? 'development';
        
        // Récupérer les origines autorisées pour cet environnement
        $allowed = self::$allowedOrigins[$environment] ?? [];
        
        // Récupérer les origines personnalisées depuis les variables d'environnement
        $customOrigins = $_ENV['CORS_ORIGINS'] ?? '';
        
        // Si des origines personnalisées sont configurées
        if (!empty($customOrigins)) {
            // Diviser et fusionner avec les origines pré-configurées
            $customArray = explode(',', $customOrigins);
            $allowed = array_merge($allowed, array_map('trim', $customArray));
        }
        
        // Retourner la liste complète des origines autorisées
        return $allowed;
    }
}
