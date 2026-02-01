<?php

class DocumentController
{
    private $db;

    public function __construct()
    {
        $this->db = Database::getInstance()->getConnection();
    }

    /**
     * Récupère tous les documents de l'utilisateur
     * 
     * @param string $userId L'ID utilisateur
     * @return array Les documents trouvés
     */
    public function getDocuments($userId)
    {
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
    public function getDocument($userId, $documentId)
    {
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
    public function addDocument($userId, $data)
    {
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
    public function updateDocument($userId, $documentId, $data)
    {
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
    public function deleteDocument($userId, $documentId)
    {
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

            // Supprimer le fichier physique si nécessaire
            if (!empty($document['file_path']) && file_exists($document['file_path'])) {
                if (!unlink($document['file_path'])) {
                    // Log l'erreur mais ne bloque pas la suppression de la base de données
                    error_log("Impossible de supprimer le fichier physique: " . $document['file_path']);
                }
            }

            // Supprimer les partages associés au document
            $deleteSharesStmt = $this->db->prepare("DELETE FROM document_shares WHERE document_id = ?");
            $deleteSharesStmt->execute([$documentId]);

            // Supprimer le document de la base de données
            $stmt = $this->db->prepare("DELETE FROM documents WHERE id = ? AND user_id = ?");
            $stmt->execute([$documentId, $userId]);

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
    public function shareDocument($userId, $documentId, $data)
    {
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

            $permissions = $data['permissions'] ?? 'view';
            $expiresAt = isset($data['expires_at']) ? $data['expires_at'] : null;
            $sharedUsers = $data['shared_with'];
            $successfulShares = 0;
            $errors = [];

            // Commencer une transaction
            $this->db->beginTransaction();

            foreach ($sharedUsers as $sharedUserId) {
                try {
                    // Vérifier que l'utilisateur partagé existe
                    $userCheckStmt = $this->db->prepare("SELECT id FROM users WHERE id = ?");
                    $userCheckStmt->execute([$sharedUserId]);
                    if (!$userCheckStmt->fetch()) {
                        $errors[] = "Utilisateur $sharedUserId non trouvé";
                        continue;
                    }

                    // Insérer ou mettre à jour le partage
                    $shareStmt = $this->db->prepare("
                        INSERT INTO document_shares (document_id, shared_by_user_id, shared_with_user_id, permissions, expires_at, is_active)
                        VALUES (?, ?, ?, ?, ?, TRUE)
                        ON DUPLICATE KEY UPDATE
                        permissions = VALUES(permissions),
                        expires_at = VALUES(expires_at),
                        is_active = TRUE,
                        shared_at = CURRENT_TIMESTAMP
                    ");
                    $shareStmt->execute([$documentId, $userId, $sharedUserId, $permissions, $expiresAt]);
                    $successfulShares++;
                } catch (Exception $e) {
                    $errors[] = "Erreur pour l'utilisateur $sharedUserId: " . $e->getMessage();
                }
            }

            // Valider la transaction
            $this->db->commit();

            return [
                'success' => true,
                'message' => "Document partagé avec $successfulShares utilisateur(s) sur " . count($sharedUsers),
                'data' => [
                    'shared_with' => $sharedUsers,
                    'document_id' => $documentId,
                    'successful_shares' => $successfulShares,
                    'errors' => $errors
                ]
            ];
        } catch (Exception $e) {
            // Annuler la transaction en cas d'erreur
            if ($this->db->inTransaction()) {
                $this->db->rollBack();
            }
            return [
                'success' => false,
                'error' => 'Erreur lors du partage du document: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Récupère les documents partagés avec l'utilisateur
     *
     * @param string $userId L'ID utilisateur
     * @return array Les documents partagés
     */
    public function getSharedDocuments($userId)
    {
        try {
            $stmt = $this->db->prepare("
                SELECT
                    d.id, d.name, d.description, d.file_path, d.file_type, d.file_size, d.is_encrypted,
                    d.created_at, d.updated_at,
                    ds.permissions, ds.shared_at, ds.expires_at,
                    u.first_name, u.last_name, u.email as shared_by_email
                FROM document_shares ds
                JOIN documents d ON ds.document_id = d.id
                JOIN users u ON ds.shared_by_user_id = u.id
                WHERE ds.shared_with_user_id = ? AND ds.is_active = TRUE
                AND (ds.expires_at IS NULL OR ds.expires_at > NOW())
                ORDER BY ds.shared_at DESC
            ");
            $stmt->execute([$userId]);
            $sharedDocuments = $stmt->fetchAll(PDO::FETCH_ASSOC);

            return [
                'success' => true,
                'message' => 'Documents partagés récupérés avec succès',
                'data' => $sharedDocuments
            ];
        } catch (Exception $e) {
            return [
                'success' => false,
                'error' => 'Erreur lors de la récupération des documents partagés: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Révoque le partage d'un document
     *
     * @param string $userId L'ID utilisateur
     * @param string $documentId L'ID du document
     * @param string $sharedWithUserId L'ID de l'utilisateur avec qui le document était partagé
     * @return array Le résultat de l'opération
     */
    public function revokeShare($userId, $documentId, $sharedWithUserId)
    {
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

            $stmt = $this->db->prepare("
                UPDATE document_shares
                SET is_active = FALSE
                WHERE document_id = ? AND shared_by_user_id = ? AND shared_with_user_id = ?
            ");
            $stmt->execute([$documentId, $userId, $sharedWithUserId]);

            return [
                'success' => true,
                'message' => 'Partage révoqué avec succès'
            ];
        } catch (Exception $e) {
            return [
                'success' => false,
                'error' => 'Erreur lors de la révocation du partage: ' . $e->getMessage()
            ];
        }
    }
}
