<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../middleware/AuthMiddleware.php';

class EmergencyContactController {
    private $db;

    public function __construct() {
        $this->db = Database::getInstance()->getConnection();
    }

    public function getContacts($userId) {
        try {
            $stmt = $this->db->prepare("
                SELECT id, user_id, name, relationship, phone, email, priority, is_verified,
                       can_see_live_location, last_alert, response_time, added_date
                FROM emergency_contacts
                WHERE user_id = ?
                ORDER BY priority ASC
            ");
            $stmt->execute([$userId]);
            $contacts = $stmt->fetchAll();

            return array_map(function($contact) {
                return [
                    'id' => $contact['id'],
                    'userId' => $contact['user_id'],
                    'name' => $contact['name'],
                    'relationship' => $contact['relationship'],
                    'phone' => $contact['phone'],
                    'email' => $contact['email'],
                    'priority' => $contact['priority'],
                    'isVerified' => (bool)$contact['is_verified'],
                    'canSeeLiveLocation' => (bool)$contact['can_see_live_location'],
                    'lastAlert' => $contact['last_alert'],
                    'responseTime' => $contact['response_time'],
                    'addedDate' => $contact['added_date']
                ];
            }, $contacts);
        } catch (Exception $e) {
            http_response_code(500);
            return ['error' => 'Erreur lors de la récupération des contacts'];
        }
    }

    public function addContact($userId, $data) {
        try {
            $stmt = $this->db->prepare("
                INSERT INTO emergency_contacts (user_id, name, relationship, phone, email, priority, added_date)
                VALUES (?, ?, ?, ?, ?, ?, NOW())
            ");
            $stmt->execute([
                $userId,
                $data['name'],
                $data['relationship'],
                $data['phone'],
                $data['email'],
                $data['priority']
            ]);

            return [
                'id' => $this->db->lastInsertId(),
                'message' => 'Contact ajouté avec succès'
            ];
        } catch (Exception $e) {
            http_response_code(500);
            return ['error' => 'Erreur lors de l\'ajout du contact'];
        }
    }

    public function updateContact($userId, $contactId, $data) {
        try {
            $stmt = $this->db->prepare("
                UPDATE emergency_contacts
                SET name = ?, relationship = ?, phone = ?, email = ?, priority = ?
                WHERE id = ? AND user_id = ?
            ");
            $stmt->execute([
                $data['name'],
                $data['relationship'],
                $data['phone'],
                $data['email'],
                $data['priority'],
                $contactId,
                $userId
            ]);

            if ($stmt->rowCount() === 0) {
                http_response_code(404);
                return ['error' => 'Contact non trouvé'];
            }

            return ['message' => 'Contact mis à jour avec succès'];
        } catch (Exception $e) {
            http_response_code(500);
            return ['error' => 'Erreur lors de la mise à jour du contact'];
        }
    }

    public function deleteContact($userId, $contactId) {
        try {
            $stmt = $this->db->prepare("DELETE FROM emergency_contacts WHERE id = ? AND user_id = ?");
            $stmt->execute([$contactId, $userId]);

            if ($stmt->rowCount() === 0) {
                http_response_code(404);
                return ['error' => 'Contact non trouvé'];
            }

            return ['message' => 'Contact supprimé avec succès'];
        } catch (Exception $e) {
            http_response_code(500);
            return ['error' => 'Erreur lors de la suppression du contact'];
        }
    }
}