<?php

/**
 * API pour récupérer les infos du profil admin
 */

header('Content-Type: application/json');
require_once __DIR__ . '/../admin/auth.php';

$admin = AdminAuth::getAdminInfo();

if ($admin) {
    echo json_encode($admin);
} else {
    http_response_code(401);
    echo json_encode(['error' => 'Non authentifié']);
}
