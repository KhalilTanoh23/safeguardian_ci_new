<?php

/**
 * Gestion de l'authentification administrateur
 * ============================================
 */

session_start();

require_once __DIR__ . '/../config/database.php';

class AdminAuth
{
    /**
     * Vérifie si un administrateur est connecté
     * Retourne les infos de l'utilisateur ou redirige vers la connexion
     */
    public static function checkAdmin()
    {
        if (!isset($_SESSION['admin_id']) || !isset($_SESSION['admin_role'])) {
            header('Location: /admin/login.php');
            exit;
        }

        // Vérifier que le rôle est bien 'admin'
        if ($_SESSION['admin_role'] !== 'admin') {
            session_destroy();
            header('Location: /admin/login.php?error=unauthorized');
            exit;
        }

        return $_SESSION;
    }

    /**
     * Valide les credentials admin et lance une session
     */
    public static function login($email, $password)
    {
        try {
            $db = Database::getInstance();
            $pdo = $db->getConnection();

            // Récupérer l'utilisateur avec ce rôle admin
            $stmt = $pdo->prepare("
                SELECT id, email, password, first_name, last_name, role
                FROM users
                WHERE email = :email AND role = :role
                LIMIT 1
            ");
            $stmt->execute([
                ':email' => $email,
                ':role' => 'admin'
            ]);

            $user = $stmt->fetch(PDO::FETCH_ASSOC);

            if (!$user) {
                return ['success' => false, 'message' => 'Email ou mot de passe incorrect'];
            }

            // Vérifier le mot de passe
            if (!password_verify($password, $user['password'])) {
                return ['success' => false, 'message' => 'Email ou mot de passe incorrect'];
            }

            // Créer la session
            $_SESSION['admin_id'] = $user['id'];
            $_SESSION['admin_email'] = $user['email'];
            $_SESSION['admin_name'] = $user['first_name'] . ' ' . $user['last_name'];
            $_SESSION['admin_role'] = $user['role'];
            $_SESSION['login_time'] = time();

            return [
                'success' => true,
                'message' => 'Connexion réussie',
                'user' => [
                    'id' => $user['id'],
                    'email' => $user['email'],
                    'name' => $user['first_name'] . ' ' . $user['last_name']
                ]
            ];
        } catch (Exception $e) {
            return ['success' => false, 'message' => 'Erreur serveur: ' . $e->getMessage()];
        }
    }

    /**
     * Déconnecte l'admin
     */
    public static function logout()
    {
        session_destroy();
        header('Location: /admin/login.php');
        exit;
    }

    /**
     * Retourne les informations de l'admin connecté
     */
    public static function getAdminInfo()
    {
        if (isset($_SESSION['admin_id'])) {
            return [
                'id' => $_SESSION['admin_id'],
                'email' => $_SESSION['admin_email'],
                'name' => $_SESSION['admin_name'],
                'role' => $_SESSION['admin_role']
            ];
        }
        return null;
    }
}
