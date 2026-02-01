<?php

/**
 * ════════════════════════════════════════════════════════════════════════════
 * LocationController - Gestion des emplacements
 * ════════════════════════════════════════════════════════════════════════════
 */

require_once __DIR__ . '/../utils/Validator.php';
require_once __DIR__ . '/../utils/ResponseHandler.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../middleware/AuthMiddleware.php';
require_once __DIR__ . '/LocationController.php';

class LocationControllerImpl extends LocationController
{
    private $db;

    public function __construct()
    {
        $this->db = Database::getInstance()->getConnection();
    }

    /**
     * Mettre à jour la position actuelle
     */
    public function updateLocation()
    {
        try {
            $user = AuthMiddleware::verifyToken();
            $data = json_decode(file_get_contents('php://input'), true);

            // Validation coordonnées
            $latitude = $data['latitude'] ?? null;
            $longitude = $data['longitude'] ?? null;
            $accuracy = $data['accuracy'] ?? null;
            $altitude = $data['altitude'] ?? null;

            if (is_null($latitude) || is_null($longitude)) {
                ResponseHandler::validationError('Erreur', ['location' => 'Latitude et longitude requises']);
            }

            $coordsValid = Validator::validateCoordinates($latitude, $longitude);
            if (!$coordsValid['valid']) {
                ResponseHandler::validationError('Erreur', ['location' => $coordsValid['message']]);
            }

            // Insérer location
            $stmt = $this->db->prepare(
                'INSERT INTO locations (user_id, latitude, longitude, accuracy, altitude, recorded_at) 
                VALUES (?, ?, ?, ?, ?, NOW())'
            );
            $stmt->execute([$user->id, $latitude, $longitude, $accuracy, $altitude]);

            ResponseHandler::success('Position mise à jour');
        } catch (Exception $e) {
            ResponseHandler::internalError('Erreur: ' . $e->getMessage());
        }
    }

    /**
     * Récupérer l'historique des positions
     */
    public function getLocationHistory()
    {
        try {
            $user = AuthMiddleware::verifyToken();

            // Paramètres optionnels
            $limit = $_GET['limit'] ?? 100;
            $offset = $_GET['offset'] ?? 0;

            $stmt = $this->db->prepare(
                'SELECT id, latitude, longitude, accuracy, altitude, recorded_at 
                FROM locations 
                WHERE user_id = ? 
                ORDER BY recorded_at DESC 
                LIMIT ? OFFSET ?'
            );
            $stmt->execute([$user->id, $limit, $offset]);
            $locations = $stmt->fetchAll(PDO::FETCH_ASSOC);

            ResponseHandler::success('Historique récupéré', ['locations' => $locations]);
        } catch (Exception $e) {
            ResponseHandler::internalError('Erreur: ' . $e->getMessage());
        }
    }

    /**
     * Récupérer la dernière position connue
     */
    public function getLastLocation()
    {
        try {
            $user = AuthMiddleware::verifyToken();

            $stmt = $this->db->prepare(
                'SELECT id, latitude, longitude, accuracy, altitude, recorded_at 
                FROM locations 
                WHERE user_id = ? 
                ORDER BY recorded_at DESC 
                LIMIT 1'
            );
            $stmt->execute([$user->id]);
            $location = $stmt->fetch(PDO::FETCH_ASSOC);

            if (!$location) {
                ResponseHandler::notFound('Pas de position enregistrée');
            }

            ResponseHandler::success('Position récupérée', ['location' => $location]);
        } catch (Exception $e) {
            ResponseHandler::internalError('Erreur: ' . $e->getMessage());
        }
    }
}
