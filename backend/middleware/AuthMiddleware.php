<?php
/**
 * ════════════════════════════════════════════════════════════════════════════
 * Middleware d'authentification
 * 
 * Vérifie et valide les tokens JWT pour sécuriser les routes protégées
 * ════════════════════════════════════════════════════════════════════════════
 */

// ───── Charger la classe JWT pour le décodage des tokens
require_once __DIR__ . '/../config/jwt.php';

// ═════════════════════════════════════════════════════════════════════════════
// CLASSE: AuthMiddleware
// Gère l'authentification des requêtes via tokens JWT
// ═════════════════════════════════════════════════════════════════════════════

class AuthMiddleware {
    /**
     * ────────────────────────────────────────────────────────────────────────
     * MÉTHODE STATIQUE: authenticate()
     * Authentifie l'utilisateur en vérifiant le token JWT
     * 
     * @return string L'ID utilisateur si authentifié
     * @throws Exception Si le token est invalide ou manquant
     * ────────────────────────────────────────────────────────────────────────
     */
    public static function authenticate() {
        // ───── Récupérer les headers d'authentification
        // Les headers HTTP sont extraits du serveur
        $headers = self::getAuthorizationHeaders();
        
        // ───── Vérifier si le header Authorization est présent
        if (!isset($headers['Authorization'])) {
            // Le token n'a pas été fourni
            // Retourner le code HTTP 401 (Non autorisé)
            http_response_code(401);
            // Lever une exception pour arrêter l'exécution
            throw new Exception('Token manquant');
        }

        // ───── Extraire le token du header Authorization
        // Format attendu: "Bearer <token>"
        // Supprimer le préfixe "Bearer " pour obtenir uniquement le token
        $token = str_replace('Bearer ', '', $headers['Authorization']);
        
        // ───── Essayer de décoder et valider le token
        try {
            // Décoder le token JWT
            $decoded = JWT::decode($token);
            
            // ───── Vérifier que le décodage a réussi
            if (!$decoded) {
                // Le token n'a pas pu être décodé (signature invalide ou malformé)
                http_response_code(401);
                // Lever une exception
                throw new Exception('Token invalide ou expiré');
            }

            // ───── Vérifier l'expiration du token
            // Le token contient un champ 'exp' (expiration time) en timestamp Unix
            if (isset($decoded['exp']) && $decoded['exp'] < time()) {
                // Le token a expiré (sa date d'expiration est dans le passé)
                http_response_code(401);
                // Lever une exception
                throw new Exception('Token expiré');
            }

            // ───── Retourner l'ID utilisateur du token
            // Essayer d'abord 'userId' (camelCase), sinon 'user_id' (snake_case)
            return $decoded['userId'] ?? $decoded['user_id'];
        } catch (Exception $e) {
            // En cas d'erreur lors du décodage
            http_response_code(401);
            // Relancer l'exception avec les détails
            throw new Exception('Token invalide: ' . $e->getMessage());
        }
    }

    /**
     * ────────────────────────────────────────────────────────────────────────
     * MÉTHODE STATIQUE PRIVÉE: getAuthorizationHeaders()
     * Extrait et formate les headers HTTP de la requête
     * 
     * @return array Les headers HTTP avec les clés formatées
     * ────────────────────────────────────────────────────────────────────────
     */
    private static function getAuthorizationHeaders() {
        // ───── Initialiser le tableau des headers
        $headers = [];
        
        // ───── Parcourir toutes les variables de serveur
        // $_SERVER contient les headers HTTP avec le préfixe "HTTP_"
        foreach ($_SERVER as $key => $value) {
            // ───── Vérifier si la clé commence par "HTTP_"
            // Cela indique que c'est un header HTTP
            if (substr($key, 0, 5) == 'HTTP_') {
                // ───── Formater le nom du header
                // Exemple: HTTP_AUTHORIZATION -> Authorization
                
                // Supprimer le préfixe "HTTP_"
                $header_name = substr($key, 5);
                
                // Convertir en minuscules
                $header_name = strtolower($header_name);
                
                // Remplacer les underscores par des espaces
                $header_name = str_replace('_', ' ', $header_name);
                
                // Mettre la première lettre de chaque mot en majuscule
                $header_name = ucwords($header_name);
                
                // Remplacer les espaces par des tirets (format standard des headers)
                $header_name = str_replace(' ', '-', $header_name);
                
                // ───── Ajouter le header au tableau
                $headers[$header_name] = $value;
            }
        }
        
        // ───── Retourner le tableau des headers formatés
        return $headers;
    }

    /**
     * ────────────────────────────────────────────────────────────────────────
     * MÉTHODE STATIQUE: hasPermission()
     * Vérifie si l'utilisateur a les permissions requises
     * 
     * @param string $userId L'ID utilisateur
     * @param array $requiredRoles Les rôles requis
     * @return bool True si l'utilisateur a les permissions
     * ────────────────────────────────────────────────────────────────────────
     */
    public static function hasPermission($userId, array $requiredRoles = []) {
        // ───── Vérification des permissions
        // À implémenter selon votre système de permissions et rôles
        
        // Pour l'instant, cette méthode est un placeholder
        // Tout utilisateur authentifié est considéré comme autorisé
        // À améliorer: vérifier les rôles dans la base de données
        
        // Retourner true pour autoriser l'accès
        return true;
    }
}
