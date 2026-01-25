<?php

class DocumentController {
    private $db;

    public function __construct() {
        $this->db = Database::getInstance()->getConnection();
    }

    /**
     * Récupère tous les documents de l'utilisateur
     * 
     * @param string $userId L'ID utilisateur
     * @return array Les documents trouvés
     */
    public function getDocuments($userId) {
        try {
            $stmt = $this->db->prepare("SELECT id, name, description, file_path, file_type, file_size, is_encrypted, created_at, updated_at FROM documents WHERE user_id = ? ORDER BY created_at DESC");
            $stmt->execute([$userId]);
            $documents = $stmt->fetchAll(PDO::FETCH_ASSOC);

            return [
                'success' => true,
                'message' => 'Documents récupérés avec succès',
                'data' => $documents
            ];
        } catch (Exception $e) {
            return [
                'success' => false,
                'error' => 'Erreur lors de la récupération des documents: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Récupère un document spécifique
     * 
     * @param string $userId L'ID utilisateur
     * @param string $documentId L'ID du document
     * @return array Le document trouvé
     */
    public function getDocument($userId, $documentId) {
        try {
            $stmt = $this->db->prepare("SELECT id, name, description, file_path, file_type, file_size, is_encrypted, created_at, updated_at FROM documents WHERE id = ? AND user_id = ?");
            $stmt->execute([$documentId, $userId]);
            $document = $stmt->fetch(PDO::FETCH_ASSOC);

            if (!$document) {
                return [
                    'success' => false,
                    'error' => 'Document non trouvé'
                ];
            }

            return [
                'success' => true,
                'message' => 'Document récupéré avec succès',
                'data' => $document
            ];
        } catch (Exception $e) {
            return [
                'success' => false,
                'error' => 'Erreur lors de la récupération du document: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Ajoute un nouveau document
     * 
     * @param string $userId L'ID utilisateur
     * @param array $data Les données du document
     * @return array Le résultat de l'opération
     */
    public function addDocument($userId, $data) {
        try {
            // Validation des données
            if (!isset($data['name']) || !isset($data['type'])) {
                return [
                    'success' => false,
                    'error' => 'Nom et type du document requis'
                ];
            }

            // Préparer les données avec des valeurs par défaut
            $name = $data['name'];
            $description = $data['description'] ?? '';
            $filePath = $data['file_path'] ?? '';
            $fileType = $data['type'];
            $fileSize = $data['file_size'] ?? 0;
            $isEncrypted = $data['is_encrypted'] ?? false;

            // Insérer le document dans la base de données
            $stmt = $this->db->prepare("INSERT INTO documents (user_id, name, description, file_path, file_type, file_size, is_encrypted) VALUES (?, ?, ?, ?, ?, ?, ?)");
            $stmt->execute([$userId, $name, $description, $filePath, $fileType, $fileSize, $isEncrypted]);

            // Récupérer l'ID du document créé
            $documentId = $this->db->lastInsertId();

            return [
                'success' => true,
                'message' => 'Document créé avec succès',
                'data' => ['id' => $documentId]
            ];
        } catch (Exception $e) {
            return [
                'success' => false,
                'error' => 'Erreur lors de la création du document: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Met à jour un document
     * 
     * @param string $userId L'ID utilisateur
     * @param string $documentId L'ID du document
     * @param array $data Les nouvelles données
     * @return array Le résultat de l'opération
     */
    public function updateDocument($userId, $documentId, $data) {
        try {
            // Vérifier que le document appartient à l'utilisateur
            $checkStmt = $this->db->prepare("SELECT id FROM documents WHERE id = ? AND user_id = ?");
            $checkStmt->execute([$documentId, $userId]);
            if (!$checkStmt->fetch()) {
                return [
                    'success' => false,
                    'error' => 'Document non trouvé ou accès non autorisé'
                ];
            }

            $updateFields = [];
            $params = [];

            if (isset($data['name'])) {
                $updateFields[] = "name = ?";
                $params[] = $data['name'];
            }
            if (isset($data['description'])) {
                $updateFields[] = "description = ?";
                $params[] = $data['description'];
            }
            if (isset($data['file_path'])) {
                $updateFields[] = "file_path = ?";
                $params[] = $data['file_path'];
            }
            if (isset($data['file_type'])) {
                $updateFields[] = "file_type = ?";
                $params[] = $data['file_type'];
            }
            if (isset($data['file_size'])) {
                $updateFields[] = "file_size = ?";
                $params[] = $data['file_size'];
            }
            if (isset($data['is_encrypted'])) {
                $updateFields[] = "is_encrypted = ?";
                $params[] = $data['is_encrypted'];
            }

            if (empty($updateFields)) {
                return [
                    'success' => false,
                    'error' => 'Aucune donnée à mettre à jour'
                ];
            }

            $params[] = $documentId;
            $params[] = $userId;

            $stmt = $this->db->prepare("UPDATE documents SET " . implode(', ', $updateFields) . " WHERE id = ? AND user_id = ?");
            $stmt->execute($params);

            return [
                'success' => true,
                'message' => 'Document mis à jour avec succès'
            ];
        } catch (Exception $e) {
            return [
                'success' => false,
                'error' => 'Erreur lors de la mise à jour du document: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Supprime un document
     * 
     * @param string $userId L'ID utilisateur
     * @param string $documentId L'ID du document à supprimer
     * @return array Le résultat de l'opération
     */
    public function deleteDocument($userId, $documentId) {
        try {
            // Vérifier que le document appartient à l'utilisateur
            $checkStmt = $this->db->prepare("SELECT file_path FROM documents WHERE id = ? AND user_id = ?");
            $checkStmt->execute([$documentId, $userId]);
            $document = $checkStmt->fetch(PDO::FETCH_ASSOC);

            if (!$document) {
                return [
                    'success' => false,
                    'error' => 'Document non trouvé ou accès non autorisé'
                ];
            }

            // Supprimer le document de la base de données
            $stmt = $this->db->prepare("DELETE FROM documents WHERE id = ? AND user_id = ?");
            $stmt->execute([$documentId, $userId]);

            // TODO: Supprimer le fichier physique si nécessaire
            // unlink($document['file_path']);

            return [
                'success' => true,
                'message' => 'Document supprimé avec succès'
            ];
        } catch (Exception $e) {
            return [
                'success' => false,
                'error' => 'Erreur lors de la suppression du document: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Partage un document avec d'autres utilisateurs
     * 
     * @param string $userId L'ID utilisateur
     * @param string $documentId L'ID du document
     * @param array $data Les données de partage
     * @return array Le résultat de l'opération
     */
    public function shareDocument($userId, $documentId, $data) {
        try {
            if (!isset($data['shared_with']) || !is_array($data['shared_with'])) {
                return [
                    'success' => false,
                    'error' => 'Liste des utilisateurs à partager requis'
                ];
            }

            // Vérifier que le document appartient à l'utilisateur
            $checkStmt = $this->db->prepare("SELECT id FROM documents WHERE id = ? AND user_id = ?");
            $checkStmt->execute([$documentId, $userId]);
            if (!$checkStmt->fetch()) {
                return [
                    'success' => false,
                    'error' => 'Document non trouvé ou accès non autorisé'
                ];
            }

            // Pour l'instant, on simule le partage (une vraie implémentation nécessiterait une table de partage)
            // TODO: Créer une table document_shares pour gérer les partages
            $sharedUsers = $data['shared_with'];

            // Ici on pourrait insérer dans une table de partage
            // Pour l'instant, on retourne succès avec le nombre d'utilisateurs partagés
            return [
                'success' => true,
                'message' => 'Document partagé avec ' . count($sharedUsers) . ' utilisateur(s)',
                'data' => [
                    'shared_with' => $sharedUsers,
                    'document_id' => $documentId
                ]
            ];
        } catch (Exception $e) {
            return [
                'success' => false,
                'error' => 'Erreur lors du partage du document: ' . $e->getMessage()
            ];
        }
    }
}
