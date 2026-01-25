<?php

class ResponseHandler {
    /**
     * Envoyer une réponse de succès
     * 
     * @param mixed $data Les données à retourner
     * @param string $message Message de succès
     * @param int $code Code HTTP
     */
    public static function success($data = null, $message = 'Succès', $code = 200) {
        http_response_code($code);
        echo json_encode([
            'success' => true,
            'message' => $message,
            'data' => $data,
            'timestamp' => date('Y-m-d H:i:s')
        ]);
        exit;
    }

    /**
     * Envoyer une réponse d'erreur
     * 
     * @param string $message Message d'erreur
     * @param int $code Code HTTP
     * @param mixed $errors Détails des erreurs
     */
    public static function error($message = 'Erreur', $code = 400, $errors = null) {
        http_response_code($code);
        $response = [
            'success' => false,
            'message' => $message,
            'timestamp' => date('Y-m-d H:i:s')
        ];
        
        if ($errors) {
            $response['errors'] = $errors;
        }
        
        echo json_encode($response);
        exit;
    }

    /**
     * Envoyer une réponse de validation échouée
     * 
     * @param array $errors Les erreurs de validation
     */
    public static function validationError($errors) {
        self::error('Erreur de validation', 422, $errors);
    }

    /**
     * Envoyer une réponse non autorisée
     */
    public static function unauthorized() {
        self::error('Non autorisé', 401);
    }

    /**
     * Envoyer une réponse interdite
     */
    public static function forbidden() {
        self::error('Accès refusé', 403);
    }

    /**
     * Envoyer une réponse non trouvée
     */
    public static function notFound() {
        self::error('Ressource non trouvée', 404);
    }

    /**
     * Envoyer une réponse pour erreur serveur
     */
    public static function internalError($message = 'Erreur interne du serveur') {
        self::error($message, 500);
    }
}
