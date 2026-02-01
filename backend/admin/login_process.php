<?php

/**
 * Traitement de la connexion admin
 */

require_once __DIR__ . '/auth.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = $_POST['email'] ?? '';
    $password = $_POST['password'] ?? '';

    if (empty($email) || empty($password)) {
        header('Location: login.php?error=Veuillez remplir tous les champs');
        exit;
    }

    $result = AdminAuth::login($email, $password);

    if ($result['success']) {
        header('Location: index.php');
        exit;
    } else {
        header('Location: login.php?error=' . urlencode($result['message']));
        exit;
    }
} else {
    header('Location: login.php');
    exit;
}
