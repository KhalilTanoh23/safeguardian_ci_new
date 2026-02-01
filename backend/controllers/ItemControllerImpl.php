<?php

/**
 * ════════════════════════════════════════════════════════════════════════════
 * ItemController - Gestion des objets personnels
 * ════════════════════════════════════════════════════════════════════════════
 */

require_once __DIR__ . '/../utils/Validator.php';
require_once __DIR__ . '/../utils/ResponseHandler.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../middleware/AuthMiddleware.php';
require_once __DIR__ . '/ItemController.php';

class ItemControllerImpl extends ItemController
{
    private $db;

    public function __construct()
    {
        $this->db = Database::getInstance()->getConnection();
    }

    /**
     * Ajouter un nouvel objet
     */
    public function add()
    {
        try {
            $user = AuthMiddleware::verifyToken();
            $data = json_decode(file_get_contents('php://input'), true);

            // Validation
            $name = $data['name'] ?? '';
            $description = $data['description'] ?? '';
            $category = $data['category'] ?? '';
            $serialNumber = $data['serial_number'] ?? null;

            if (empty($name) || strlen($name) < 2) {
                ResponseHandler::validationError('Erreur', ['name' => 'Minimum 2 caractères']);
            }

            // Insérer objet
            $stmt = $this->db->prepare(
                'INSERT INTO items (user_id, name, description, category, serial_number, status, created_at) 
                VALUES (?, ?, ?, ?, ?, ?, NOW())'
            );
            $stmt->execute([$user->id, $name, $description, $category, $serialNumber, 'active']);

            $itemId = $this->db->lastInsertId();

            ResponseHandler::success('Objet ajouté', ['item_id' => $itemId], 201);
        } catch (Exception $e) {
            ResponseHandler::internalError('Erreur: ' . $e->getMessage());
        }
    }

    /**
     * Récupérer les objets
     */
    public function getItems($userId = null)
    {
        try {
            if ($userId === null) {
                $user = AuthMiddleware::verifyToken();
                $userId = $user->id;
            }

            $stmt = $this->db->prepare(
                'SELECT id, name, description, category, serial_number, status, image_url, created_at 
                FROM items WHERE user_id = ? ORDER BY created_at DESC'
            );
            $stmt->execute([$userId]);
            $items = $stmt->fetchAll(PDO::FETCH_ASSOC);

            ResponseHandler::success('Objets récupérés', ['items' => $items]);
        } catch (Exception $e) {
            ResponseHandler::internalError('Erreur: ' . $e->getMessage());
        }
    }

    /**
     * Mettre à jour un objet
     */
    public function update($id)
    {
        try {
            $user = AuthMiddleware::verifyToken();
            $data = json_decode(file_get_contents('php://input'), true);

            // Vérifier propriété
            $stmt = $this->db->prepare('SELECT id FROM items WHERE id = ? AND user_id = ?');
            $stmt->execute([$id, $user->id]);
            if ($stmt->rowCount() === 0) {
                ResponseHandler::notFound('Objet non trouvé');
            }

            // Mettre à jour
            $updates = [];
            $params = [];

            if (isset($data['name'])) {
                $updates[] = 'name = ?';
                $params[] = $data['name'];
            }
            if (isset($data['description'])) {
                $updates[] = 'description = ?';
                $params[] = $data['description'];
            }
            if (isset($data['status'])) {
                $updates[] = 'status = ?';
                $params[] = $data['status'];
            }

            if (empty($updates)) {
                ResponseHandler::error('Aucune donnée à mettre à jour');
            }

            $params[] = $id;
            $query = 'UPDATE items SET ' . implode(', ', $updates) . ' WHERE id = ?';

            $stmt = $this->db->prepare($query);
            $stmt->execute($params);

            ResponseHandler::success('Objet mis à jour');
        } catch (Exception $e) {
            ResponseHandler::internalError('Erreur: ' . $e->getMessage());
        }
    }

    /**
     * Marquer un objet comme perdu
     */
    public function markLost($id)
    {
        try {
            $user = AuthMiddleware::verifyToken();

            $stmt = $this->db->prepare('UPDATE items SET status = ? WHERE id = ? AND user_id = ?');
            $stmt->execute(['lost', $id, $user->id]);

            if ($stmt->rowCount() === 0) {
                ResponseHandler::notFound('Objet non trouvé');
            }

            ResponseHandler::success('Objet marqué comme perdu');
        } catch (Exception $e) {
            ResponseHandler::internalError('Erreur: ' . $e->getMessage());
        }
    }

    /**
     * Supprimer un objet
     */
    public function delete($id)
    {
        try {
            $user = AuthMiddleware::verifyToken();

            $stmt = $this->db->prepare('DELETE FROM items WHERE id = ? AND user_id = ?');
            $stmt->execute([$id, $user->id]);

            if ($stmt->rowCount() === 0) {
                ResponseHandler::notFound('Objet non trouvé');
            }

            ResponseHandler::success('Objet supprimé');
        } catch (Exception $e) {
            ResponseHandler::internalError('Erreur: ' . $e->getMessage());
        }
    }
}
