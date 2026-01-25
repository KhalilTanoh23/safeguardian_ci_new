<?php
/**
 * ════════════════════════════════════════════════════════════════════════════
 * Classe JWT - Gestion des tokens JWT (JSON Web Token)
 * 
 * Encode et decode les tokens JWT pour l'authentification sécurisée
 * Utilise l'algorithme HMAC-SHA256
 * ════════════════════════════════════════════════════════════════════════════
 */

// ═════════════════════════════════════════════════════════════════════════════
// CLASSE: JWT
// Gère l'encodage et décodage de tokens JWT pour l'authentification
// ═════════════════════════════════════════════════════════════════════════════

class JWT {
    /**
     * ────────────────────────────────────────────────────────────────────────
     * PROPRIÉTÉ STATIQUE: $secret
     * Clé secrète utilisée pour signer les tokens JWT
     * ⚠️  IMPORTANT: À CHANGER EN PRODUCTION AVEC UNE CLÉ FORTE
     * ────────────────────────────────────────────────────────────────────────
     */
    private static $secret = 'your-secret-key-here-change-in-production';

    /**
     * ────────────────────────────────────────────────────────────────────────
     * MÉTHODE STATIQUE: encode()
     * Encode un payload en token JWT signé
     * @param array $payload Les données à inclure dans le token
     * @return string Le token JWT complet (header.payload.signature)
     * ────────────────────────────────────────────────────────────────────────
     */
    public static function encode($payload) {
        // ───── Créer l'en-tête (header) du JWT
        // typ: Le type de token (toujours JWT)
        // alg: L'algorithme de signature utilisé (HS256 = HMAC-SHA256)
        $header = json_encode(['typ' => 'JWT', 'alg' => 'HS256']);
        
        // ───── Encoder l'en-tête en base64
        // D'abord encoder en base64 standard
        $header_encoded = base64_encode($header);
        // Puis remplacer les caractères pour obtenir la base64url (-, _, au lieu de +, /, =)
        // La base64url est une variante de base64 qui utilise des caractères URL-safe
        $header_encoded = str_replace(['+', '/', '='], ['-', '_', ''], $header_encoded);

        // ───── Encoder le payload (les données) en base64
        // D'abord convertir le payload en JSON
        // Puis encoder en base64
        $payload_encoded = base64_encode(json_encode($payload));
        // Puis remplacer les caractères pour obtenir la base64url
        $payload_encoded = str_replace(['+', '/', '='], ['-', '_', ''], $payload_encoded);

        // ───── Créer la signature
        // Signer les données header.payload avec la clé secrète
        // Utiliser l'algorithme HMAC-SHA256
        // Le paramètre 'true' retourne le résultat en binaire brut
        $signature = hash_hmac('sha256', $header_encoded . "." . $payload_encoded, self::$secret, true);
        
        // ───── Encoder la signature en base64url
        // Encoder la signature en base64
        $signature_encoded = base64_encode($signature);
        // Remplacer les caractères pour obtenir la base64url
        $signature_encoded = str_replace(['+', '/', '='], ['-', '_', ''], $signature_encoded);

        // ───── Retourner le token JWT complet
        // Format: header.payload.signature
        // Le point (.) sépare les trois parties
        return $header_encoded . "." . $payload_encoded . "." . $signature_encoded;
    }

    /**
     * ────────────────────────────────────────────────────────────────────────
     * MÉTHODE STATIQUE: decode()
     * Décide et vérifie un token JWT
     * @param string $token Le token JWT à décoder
     * @return array|false Le payload du token si valide, false sinon
     * ────────────────────────────────────────────────────────────────────────
     */
    public static function decode($token) {
        // ───── Diviser le token en ses trois parties
        // Utiliser le point (.) comme séparateur
        $parts = explode('.', $token);
        
        // ───── Vérifier que le token contient exactement 3 parties
        if (count($parts) !== 3) {
            // Token malformé, retourner false
            return false;
        }

        // ───── Extraire chaque partie du token
        // La première partie est l'en-tête (header)
        $header = $parts[0];
        // La deuxième partie est les données (payload)
        $payload = $parts[1];
        // La troisième partie est la signature
        $signature = $parts[2];

        // ───── Vérifier la signature
        // Recalculer la signature attendue
        $expected_signature = hash_hmac('sha256', $header . "." . $payload, self::$secret, true);
        // Encoder la signature attendue en base64url
        $expected_signature_encoded = base64_encode($expected_signature);
        $expected_signature_encoded = str_replace(['+', '/', '='], ['-', '_', ''], $expected_signature_encoded);

        // ───── Comparer les signatures
        // Si les signatures ne correspondent pas, le token a été modifié ou est faux
        if ($signature !== $expected_signature_encoded) {
            // La signature est invalide, retourner false
            return false;
        }

        // ───── Décoder le payload
        // Inverser la transformation base64url en base64 standard
        // Ajouter les caractères '=' pour le padding si nécessaire
        $payload_decoded = str_replace(['-', '_'], ['+', '/'], $payload);
        // Décoder depuis base64
        $payload_decoded = base64_decode($payload_decoded);
        // Convertir le JSON en tableau PHP
        $payload_decoded = json_decode($payload_decoded, true);
        
        // ───── Retourner le payload décodé
        return $payload_decoded;
    }

    /**
     * ────────────────────────────────────────────────────────────────────────
     * MÉTHODE STATIQUE: getTokenFromHeader()
     * Extrait le token JWT du header Authorization
     * Format attendu: "Bearer <token>"
     * @return string|null Le token s'il est présent, null sinon
     * ────────────────────────────────────────────────────────────────────────
     */
    public static function getTokenFromHeader() {
        // ───── Récupérer tous les en-têtes HTTP de la requête
        $headers = getallheaders();
        
        // ───── Vérifier si l'en-tête Authorization est présent
        if (isset($headers['Authorization'])) {
            // Récupérer la valeur du header Authorization
            $auth_header = $headers['Authorization'];
            
            // ───── Extraire le token avec une expression régulière
            // Le regex cherche "Bearer " suivi du token
            // /Bearer\s+(.*)$/i cherche:
            //   - "Bearer" en début
            //   - \s+ un ou plusieurs espaces
            //   - (.*) capture le reste (le token)
            //   - $ jusqu'à la fin
            //   - i case-insensitive (majuscule ou minuscule)
            if (preg_match('/Bearer\s+(.*)$/i', $auth_header, $matches)) {
                // Retourner le token capturé (groupe 1 de la regex)
                return $matches[1];
            }
        }
        
        // ───── Aucun token trouvé
        return null;
    }
}
