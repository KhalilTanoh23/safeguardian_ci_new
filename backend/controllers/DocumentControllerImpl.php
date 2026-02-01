<?php

/**
 * ════════════════════════════════════════════════════════════════════════════
 * DocumentController - Gestion des documents
 * ════════════════════════════════════════════════════════════════════════════
 */

require_once __DIR__ . '/../utils/Validator.php';
require_once __DIR__ . '/../utils/ResponseHandler.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../middleware/AuthMiddleware.php';
require_once __DIR__ . '/DocumentController.php';

class DocumentControllerImpl extends DocumentController
{
    private $db;
    private $uploadDir = __DIR__ . '/../../uploads/documents/';

    public function __construct()
    {
        $this->db = Database::getInstance()->getConnection();
        if (!file_exists($this->uploadDir)) {
            mkdir($this->uploadDir, 0755, true);
        }
    }

    /**
     * Uploader un document
     */
    public function upload()
    {
        try {
            $user = AuthMiddleware::verifyToken();

            if (!isset($_FILES['file'])) {
                ResponseHandler::validationError('Erreur', ['file' => 'Fichier requis']);
            }

            $file = $_FILES['file'];
            $title = $_POST['title'] ?? $file['name'];
            $documentType = $_POST['document_type'] ?? 'other';

            // Validation fichier
            $allowedTypes = ['application/pdf', 'image/jpeg', 'image/png', 'application/msword'];
            if (!in_array($file['type'], $allowedTypes)) {
                ResponseHandler::error('Type de fichier non autorisé');
            }

            if ($file['size'] > 10 * 1024 * 1024) { // 10MB max
                ResponseHandler::error('Fichier trop volumineux (max 10MB)');
            }

            // Générer nom unique
            $filename = uniqid() . '_' . basename($file['name']);
            $filepath = $this->uploadDir . $filename;

            if (!move_uploaded_file($file['tmp_name'], $filepath)) {
                ResponseHandler::internalError('Erreur lors du téléchargement');
            }

            // Insérer document en BD
            $stmt = $this->db->prepare(
                'INSERT INTO documents (user_id, title, document_type, file_path, file_size, uploaded_at) 
                VALUES (?, ?, ?, ?, ?, NOW())'
            );
            $stmt->execute([$user->id, $title, $documentType, $filename, $file['size']]);

            $documentId = $this->db->lastInsertId();

            ResponseHandler::success('Document uploadé', ['document_id' => $documentId], 201);
        } catch (Exception $e) {
            ResponseHandler::internalError('Erreur: ' . $e->getMessage());
        }
    }

    /**
     * Récupérer les documents
     */
    public function getDocuments($userId = null)
    {
        try {
            if ($userId === null) {
                $user = AuthMiddleware::verifyToken();
                $userId = $user->id;
            }

            $stmt = $this->db->prepare(
                'SELECT id, title, document_type, file_size, uploaded_at 
                FROM documents WHERE user_id = ? ORDER BY uploaded_at DESC'
            );
            $stmt->execute([$userId]);
            $documents = $stmt->fetchAll(PDO::FETCH_ASSOC);

            ResponseHandler::success('Documents récupérés', ['documents' => $documents]);
        } catch (Exception $e) {
            ResponseHandler::internalError('Erreur: ' . $e->getMessage());
        }
    }

    /**
     * Télécharger un document
     */
    public function download($id)
    {
        try {
            $user = AuthMiddleware::verifyToken();

            $stmt = $this->db->prepare('SELECT file_path, title FROM documents WHERE id = ? AND user_id = ?');
            $stmt->execute([$id, $user->id]);
            $doc = $stmt->fetch(PDO::FETCH_ASSOC);

            if (!$doc) {
                ResponseHandler::notFound('Document non trouvé');
            }

            $filepath = $this->uploadDir . $doc['file_path'];
            if (!file_exists($filepath)) {
                ResponseHandler::notFound('Fichier non trouvé');
            }

            header('Content-Disposition: attachment; filename=' . $doc['title']);
            header('Content-Type: application/octet-stream');
            readfile($filepath);
        } catch (Exception $e) {
            ResponseHandler::internalError('Erreur: ' . $e->getMessage());
        }
    }

    /**
     * Supprimer un document
     */
    public function delete($id)
    {
        try {
            $user = AuthMiddleware::verifyToken();

            $stmt = $this->db->prepare('SELECT file_path FROM documents WHERE id = ? AND user_id = ?');
            $stmt->execute([$id, $user->id]);
            $doc = $stmt->fetch(PDO::FETCH_ASSOC);

            if (!$doc) {
                ResponseHandler::notFound('Document non trouvé');
            }

            // Supprimer fichier
            $filepath = $this->uploadDir . $doc['file_path'];
            if (file_exists($filepath)) {
                unlink($filepath);
            }

            // Supprimer BD
            $stmt = $this->db->prepare('DELETE FROM documents WHERE id = ?');
            $stmt->execute([$id]);

            ResponseHandler::success('Document supprimé');
        } catch (Exception $e) {
            ResponseHandler::internalError('Erreur: ' . $e->getMessage());
        }
    }
}
