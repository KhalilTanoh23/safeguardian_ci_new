<?php

/**
 * ════════════════════════════════════════════════════════════════════════════
 * EmergencyContactController - Gestion des contacts d'urgence
 * ════════════════════════════════════════════════════════════════════════════
 */

require_once __DIR__ . '/../utils/Validator.php';
require_once __DIR__ . '/../utils/ResponseHandler.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../middleware/AuthMiddleware.php';
require_once __DIR__ . '/EmergencyContactController.php';

class EmergencyContactControllerImpl extends EmergencyContactController
{
    private $db;

    public function __construct()
    {
        $this->db = Database::getInstance()->getConnection();
    }

    /**
     * Ajouter un contact d'urgence
     */
    public function add()
    {
        try {
            $user = AuthMiddleware::verifyToken();
            $data = json_decode(file_get_contents('php://input'), true);

            // Validation
            $name = $data['name'] ?? '';
            $phone = $data['phone'] ?? '';
            $email = $data['email'] ?? '';
            $relationship = $data['relationship'] ?? '';

            $nameValid = Validator::validateName($name, 'Nom');
            if (!$nameValid['valid']) {
                ResponseHandler::validationError('Erreur', ['name' => $nameValid['message']]);
            }

            $phoneValid = Validator::validatePhone($phone);
            if (!$phoneValid['valid']) {
                ResponseHandler::validationError('Erreur', ['phone' => $phoneValid['message']]);
            }

            if (!empty($email)) {
                $emailValid = Validator::validateEmail($email);
                if (!$emailValid['valid']) {
                    ResponseHandler::validationError('Erreur', ['email' => $emailValid['message']]);
                }
            }

            // Insérer contact
            $stmt = $this->db->prepare(
                'INSERT INTO emergency_contacts (user_id, name, phone, email, relationship, verified_at) 
                VALUES (?, ?, ?, ?, ?, NOW())'
            );
            $stmt->execute([$user->id, $name, $phone, $email, $relationship]);

            $contactId = $this->db->lastInsertId();

            ResponseHandler::success('Contact ajouté', ['contact_id' => $contactId], 201);
        } catch (Exception $e) {
            ResponseHandler::internalError('Erreur: ' . $e->getMessage());
        }
    }

    /**
     * Récupérer les contacts d'urgence
     */
    public function getContacts($userId = null)
    {
        try {
            if ($userId === null) {
                $user = AuthMiddleware::verifyToken();
                $userId = $user->id;
            }

            $stmt = $this->db->prepare(
                'SELECT id, name, phone, email, relationship, verified_at 
                FROM emergency_contacts WHERE user_id = ? ORDER BY name ASC'
            );
            $stmt->execute([$userId]);
            $contacts = $stmt->fetchAll(PDO::FETCH_ASSOC);

            ResponseHandler::success('Contacts récupérés', ['contacts' => $contacts]);
        } catch (Exception $e) {
            ResponseHandler::internalError('Erreur: ' . $e->getMessage());
        }
    }

    /**
     * Mettre à jour un contact
     */
    public function update($id)
    {
        try {
            $user = AuthMiddleware::verifyToken();
            $data = json_decode(file_get_contents('php://input'), true);

            // Vérifier propriété
            $stmt = $this->db->prepare('SELECT id FROM emergency_contacts WHERE id = ? AND user_id = ?');
            $stmt->execute([$id, $user->id]);
            if ($stmt->rowCount() === 0) {
                ResponseHandler::notFound('Contact non trouvé');
            }

            // Mettre à jour
            $updates = [];
            $params = [];

            if (isset($data['name'])) {
                $updates[] = 'name = ?';
                $params[] = $data['name'];
            }
            if (isset($data['phone'])) {
                $updates[] = 'phone = ?';
                $params[] = $data['phone'];
            }
            if (isset($data['email'])) {
                $updates[] = 'email = ?';
                $params[] = $data['email'];
            }
            if (isset($data['relationship'])) {
                $updates[] = 'relationship = ?';
                $params[] = $data['relationship'];
            }

            if (empty($updates)) {
                ResponseHandler::error('Aucune donnée à mettre à jour');
            }

            $params[] = $id;
            $query = 'UPDATE emergency_contacts SET ' . implode(', ', $updates) . ' WHERE id = ?';

            $stmt = $this->db->prepare($query);
            $stmt->execute($params);

            ResponseHandler::success('Contact mis à jour');
        } catch (Exception $e) {
            ResponseHandler::internalError('Erreur: ' . $e->getMessage());
        }
    }

    /**
     * Supprimer un contact
     */
    public function delete($id)
    {
        try {
            $user = AuthMiddleware::verifyToken();

            $stmt = $this->db->prepare('DELETE FROM emergency_contacts WHERE id = ? AND user_id = ?');
            $stmt->execute([$id, $user->id]);

            if ($stmt->rowCount() === 0) {
                ResponseHandler::notFound('Contact non trouvé');
            }

            ResponseHandler::success('Contact supprimé');
        } catch (Exception $e) {
            ResponseHandler::internalError('Erreur: ' . $e->getMessage());
        }
    }
}
