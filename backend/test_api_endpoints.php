<?php

/**
 * ════════════════════════════════════════════════════════════════════════════
 * Test complet de l'API SafeGuardian
 * Fichier: backend/test_api_endpoints.php
 * 
 * Usage: php -S localhost:8000 index.php
 * Puis accéder: http://localhost:8000/test_api_endpoints.php
 * ════════════════════════════════════════════════════════════════════════════
 */

require_once __DIR__ . '/config/database.php';
require_once __DIR__ . '/config/jwt.php';
require_once __DIR__ . '/utils/Validator.php';
require_once __DIR__ . '/utils/ResponseHandler.php';

// Configuration test
$baseUrl = 'http://localhost:8000/api';
$testEmail = 'test_' . time() . '@example.com';
$testPassword = 'TestPassword123!';
$testToken = '';

// Résultats
$results = [];
$passed = 0;
$failed = 0;

function makeRequest($method, $endpoint, $data = null, $token = null)
{
    global $baseUrl;

    $url = $baseUrl . $endpoint;
    $context = stream_context_create([
        'http' => [
            'method' => $method,
            'header' => [
                'Content-Type: application/json',
                $token ? 'Authorization: Bearer ' . $token : ''
            ],
            'content' => $data ? json_encode($data) : null,
            'timeout' => 5
        ],
        'ssl' => [
            'verify_peer' => false,
            'verify_peer_name' => false
        ]
    ]);

    try {
        $response = file_get_contents($url, false, $context);
        return json_decode($response, true);
    } catch (Exception $e) {
        return ['error' => $e->getMessage()];
    }
}

function testEndpoint($name, $method, $endpoint, $data = null, $token = null)
{
    global $results, $passed, $failed;

    $result = makeRequest($method, $endpoint, $data, $token);
    $success = isset($result['message']) || isset($result['data']);

    $results[] = [
        'test' => $name,
        'endpoint' => $endpoint,
        'method' => $method,
        'success' => $success,
        'response' => $result
    ];

    if ($success) {
        $passed++;
    } else {
        $failed++;
    }

    return $result;
}

// ═══════════════════════════════════════════════════════════════════════════
// TESTS
// ═══════════════════════════════════════════════════════════════════════════

echo "<!DOCTYPE html>
<html>
<head>
    <title>SafeGuardian API Tests</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .test { margin: 10px 0; padding: 10px; border-left: 4px solid #ccc; }
        .pass { background: #d4edda; border-left-color: #28a745; }
        .fail { background: #f8d7da; border-left-color: #dc3545; }
        .endpoint { font-weight: bold; color: #0066cc; }
        .response { margin-top: 5px; padding: 5px; background: #f5f5f5; overflow-x: auto; }
        code { font-family: monospace; font-size: 12px; }
        .summary { margin: 20px 0; padding: 15px; background: #e7f3ff; border: 1px solid #b3d9ff; }
    </style>
</head>
<body>

<h1>🧪 SafeGuardian CI - API Test Suite</h1>
<p>Tests d'intégration pour vérifier tous les endpoints</p>

<hr>";

// Test 1: Register
echo "<h2>1️⃣ Authentication Tests</h2>";

$registerResult = testEndpoint(
    'Register - Créer un nouvel utilisateur',
    'POST',
    '/auth/register',
    [
        'email' => $testEmail,
        'password' => $testPassword,
        'first_name' => 'Test',
        'last_name' => 'User',
        'phone' => '+33612345678'
    ]
);

// Récupérer le token
if (isset($registerResult['data']['token'])) {
    $testToken = $registerResult['data']['token'];
}

// Test 2: Login
$loginResult = testEndpoint(
    'Login - Se connecter',
    'POST',
    '/auth/login',
    [
        'email' => $testEmail,
        'password' => $testPassword
    ]
);

// Test 3: Get Profile
testEndpoint(
    'Get Profile - Récupérer le profil',
    'GET',
    '/auth/profile',
    null,
    $testToken
);

// Test 4: Update Profile
testEndpoint(
    'Update Profile - Mettre à jour le profil',
    'POST',
    '/auth/profile/update',
    [
        'first_name' => 'TestUpdated',
        'last_name' => 'UserUpdated'
    ],
    $testToken
);

// ═══════════════════════════════════════════════════════════════════════════

echo "<h2>2️⃣ Alert Tests</h2>";

// Test 5: Create Alert
$createAlertResult = testEndpoint(
    'Create Alert - Créer une alerte',
    'POST',
    '/alerts/create',
    [
        'title' => 'Alerte de test',
        'description' => 'Ceci est une alerte de test',
        'type' => 'info',
        'latitude' => 48.8566,
        'longitude' => 2.3522
    ],
    $testToken
);

// Test 6: Get Alerts
testEndpoint(
    'Get Alerts - Récupérer les alertes',
    'GET',
    '/alerts',
    null,
    $testToken
);

// ═══════════════════════════════════════════════════════════════════════════

echo "<h2>3️⃣ Contact Tests</h2>";

// Test 7: Add Contact
$contactResult = testEndpoint(
    'Add Contact - Ajouter un contact d\'urgence',
    'POST',
    '/contacts/add',
    [
        'name' => 'Jean Dupont',
        'phone' => '+33612345678',
        'email' => 'jean@example.com',
        'relationship' => 'Ami'
    ],
    $testToken
);

// Test 8: Get Contacts
testEndpoint(
    'Get Contacts - Récupérer les contacts',
    'GET',
    '/contacts',
    null,
    $testToken
);

// ═══════════════════════════════════════════════════════════════════════════

echo "<h2>4️⃣ Item Tests</h2>";

// Test 9: Add Item
testEndpoint(
    'Add Item - Ajouter un objet',
    'POST',
    '/items/add',
    [
        'name' => 'Téléphone',
        'category' => 'Électronique',
        'description' => 'iPhone 14 Pro',
        'serial_number' => 'ABCD1234567890'
    ],
    $testToken
);

// Test 10: Get Items
testEndpoint(
    'Get Items - Récupérer les objets',
    'GET',
    '/items',
    null,
    $testToken
);

// ═══════════════════════════════════════════════════════════════════════════

echo "<h2>5️⃣ Location Tests</h2>";

// Test 11: Update Location
testEndpoint(
    'Update Location - Mettre à jour la position',
    'POST',
    '/location/update',
    [
        'latitude' => 48.8566,
        'longitude' => 2.3522,
        'accuracy' => 10.5,
        'altitude' => 35.2
    ],
    $testToken
);

// Test 12: Get Location History
testEndpoint(
    'Get Location History - Historique des positions',
    'GET',
    '/location/history',
    null,
    $testToken
);

// ═══════════════════════════════════════════════════════════════════════════

// Afficher résultats
echo "<div class='summary'>
    <h3>📊 Résumé des Tests</h3>
    <p><strong>✅ Réussis:</strong> $passed</p>
    <p><strong>❌ Échoués:</strong> $failed</p>
    <p><strong>📈 Taux de réussite:</strong> " . ($passed + $failed > 0 ? round($passed / ($passed + $failed) * 100, 1) : 0) . "%</p>
</div>";

echo "<h2>📋 Détails des Tests</h2>";

foreach ($results as $result) {
    $class = $result['success'] ? 'pass' : 'fail';
    $icon = $result['success'] ? '✅' : '❌';

    echo "<div class='test $class'>
        <div>$icon <strong>{$result['test']}</strong></div>
        <div><span class='endpoint'>{$result['method']} {$result['endpoint']}</span></div>
        <div class='response'><code>" . htmlspecialchars(json_encode($result['response'], JSON_PRETTY_PRINT)) . "</code></div>
    </div>";
}

echo "</body></html>";
