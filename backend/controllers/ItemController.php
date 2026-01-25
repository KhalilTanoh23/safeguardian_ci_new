<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../middleware/AuthMiddleware.php';

class ItemController {
    private $db;

    public function __construct() {
        $this->db = Database::getInstance()->getConnection();
    }

    public function getItems($userId) {
        try {
            $stmt = $this->db->prepare("
                SELECT id, user_id, name, description, category, value, location, is_lost,
                       image_url, created_at, updated_at
                FROM items
                WHERE user_id = ?
                ORDER BY created_at DESC
            ");
            $stmt->execute([$userId]);
            $items = $stmt->fetchAll();

            return array_map(function($item) {
                return [
                    'id' => $item['id'],
                    'userId' => $item['user_id'],
                    'name' => $item['name'],
                    'description' => $item['description'],
                    'category' => $item['category'],
                    'value' => $item['value'] ? (float)$item['value'] : null,
                    'location' => $item['location'],
                    'isLost' => (bool)$item['is_lost'],
                    'imageUrl' => $item['image_url'],
                    'createdAt' => $item['created_at'],
                    'updatedAt' => $item['updated_at']
                ];
            }, $items);
        } catch (Exception $e) {
            http_response_code(500);
            return ['error' => 'Erreur lors de la récupération des objets'];
        }
    }

    public function addItem($userId, $data) {
        try {
            $stmt = $this->db->prepare("
                INSERT INTO items (user_id, name, description, category, value, location, image_url, created_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, NOW())
            ");
            $stmt->execute([
                $userId,
                $data['name'],
                $data['description'] ?? null,
                $data['category'] ?? null,
                $data['value'] ?? null,
                $data['location'] ?? null,
                $data['imageUrl'] ?? null
            ]);

            return [
                'id' => $this->db->lastInsertId(),
                'message' => 'Objet ajouté avec succès'
            ];
        } catch (Exception $e) {
            http_response_code(500);
            return ['error' => 'Erreur lors de l\'ajout de l\'objet'];
        }
    }

    public function updateItem($userId, $itemId, $data) {
        try {
            $stmt = $this->db->prepare("
                UPDATE items
                SET name = ?, description = ?, category = ?, value = ?, location = ?,
                    image_url = ?, is_lost = ?, updated_at = NOW()
                WHERE id = ? AND user_id = ?
            ");
            $stmt->execute([
                $data['name'],
                $data['description'] ?? null,
                $data['category'] ?? null,
                $data['value'] ?? null,
                $data['location'] ?? null,
                $data['imageUrl'] ?? null,
                $data['isLost'] ?? false,
                $itemId,
                $userId
            ]);

            if ($stmt->rowCount() === 0) {
                http_response_code(404);
                return ['error' => 'Objet non trouvé'];
            }

            return ['message' => 'Objet mis à jour avec succès'];
        } catch (Exception $e) {
            http_response_code(500);
            return ['error' => 'Erreur lors de la mise à jour de l\'objet'];
        }
    }

    public function deleteItem($userId, $itemId) {
        try {
            $stmt = $this->db->prepare("DELETE FROM items WHERE id = ? AND user_id = ?");
            $stmt->execute([$itemId, $userId]);

            if ($stmt->rowCount() === 0) {
                http_response_code(404);
                return ['error' => 'Objet non trouvé'];
            }

            return ['message' => 'Objet supprimé avec succès'];
        } catch (Exception $e) {
            http_response_code(500);
            return ['error' => 'Erreur lors de la suppression de l\'objet'];
        }
    }

    public function markAsLost($userId, $itemId, $isLost) {
        try {
            $stmt = $this->db->prepare("
                UPDATE items SET is_lost = ?, updated_at = NOW()
                WHERE id = ? AND user_id = ?
            ");
            $stmt->execute([$isLost, $itemId, $userId]);

            if ($stmt->rowCount() === 0) {
                http_response_code(404);
                return ['error' => 'Objet non trouvé'];
            }

            return ['message' => $isLost ? 'Objet marqué comme perdu' : 'Objet marqué comme retrouvé'];
        } catch (Exception $e) {
            http_response_code(500);
            return ['error' => 'Erreur lors de la mise à jour du statut'];
        }
    }
}
