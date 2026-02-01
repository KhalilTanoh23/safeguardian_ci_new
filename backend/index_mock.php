<?php

/**
 * ════════════════════════════════════════════════════════════════════════════
 * API Mock - SafeGuardian CI
 * Version temporaire fonctionnelle sans dépendance PDO MySQL
 * Pour tester l'authentification Flutter
 * ════════════════════════════════════════════════════════════════════════════
 */

header('Content-Type: application/json;charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// ═════════════════════════════════════════════════════════════════════════════
// JWT SIMPLE
// ═════════════════════════════════════════════════════════════════════════════

class SimpleJWT
{
    private static $secret = 'e8f3a2c9d4b7f1e6a3c8d2f5b9a1e4c7d0f3a6b9e2c5f8a1d4e7a0c3f6b9';

    public static function encode($data)
    {
        $header = json_encode(['alg' => 'HS256', 'typ' => 'JWT']);
        $payload = json_encode($data);

        $headerEncoded = rtrim(strtr(base64_encode($header), '+/', '-_'), '=');
        $payloadEncoded = rtrim(strtr(base64_encode($payload), '+/', '-_'), '=');

        $signature = hash_hmac('sha256', "$headerEncoded.$payloadEncoded", self::$secret, true);
        $signatureEncoded = rtrim(strtr(base64_encode($signature), '+/', '-_'), '=');

        return "$headerEncoded.$payloadEncoded.$signatureEncoded";
    }

    public static function decode($token)
    {
        $parts = explode('.', $token);
        if (count($parts) !== 3) return null;

        $payload = json_decode(base64_decode(strtr($parts[1], '-_', '+/')), true);
        return $payload;
    }
}

// ═════════════════════════════════════════════════════════════════════════════
// BASE DE DONNÉES MOCK (JSON FILE)
// ═════════════════════════════════════════════════════════════════════════════

class MockDatabase
{
    private static $usersFile = __DIR__ . '/mock_users.json';

    public static function getUsers()
    {
        if (!file_exists(self::$usersFile)) {
            return [];
        }
        return json_decode(file_get_contents(self::$usersFile), true) ?? [];
    }

    public static function saveUsers($users)
    {
        file_put_contents(self::$usersFile, json_encode($users, JSON_PRETTY_PRINT));
    }

    public static function getUserByEmail($email)
    {
        $users = self::getUsers();
        foreach ($users as $user) {
            if ($user['email'] === $email) {
                return $user;
            }
        }
        return null;
    }

    public static function createUser($email, $password, $firstName, $lastName, $phone)
    {
        $users = self::getUsers();

        $newUser = [
            'id' => count($users) + 1,
            'email' => $email,
            'password' => password_hash($password, PASSWORD_DEFAULT),
            'firstName' => $firstName,
            'lastName' => $lastName,
            'phone' => $phone,
            'status' => 'active',
            'role' => 'user',
            'profileImage' => null,
            'createdAt' => date('Y-m-d H:i:s')
        ];

        $users[] = $newUser;
        self::saveUsers($users);

        return $newUser;
    }
}

// ═════════════════════════════════════════════════════════════════════════════
// ROUTEUR
// ═════════════════════════════════════════════════════════════════════════════

$method = $_SERVER['REQUEST_METHOD'];
$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$uri = str_replace('/api', '', $uri);
$parts = explode('/', trim($uri, '/'));

try {
    if ($parts[0] === 'auth') {
        if ($method === 'POST' && $parts[1] === 'register') {
            // ═══ REGISTER ═══
            $data = json_decode(file_get_contents('php://input'), true);

            $email = $data['email'] ?? '';
            $password = $data['password'] ?? '';
            $firstName = $data['firstName'] ?? '';
            $lastName = $data['lastName'] ?? '';
            $phone = $data['phone'] ?? '';

            if (empty($email) || empty($password)) {
                http_response_code(400);
                echo json_encode(['error' => 'Email et password requis']);
                exit;
            }

            if (MockDatabase::getUserByEmail($email)) {
                http_response_code(400);
                echo json_encode(['error' => 'Email déjà utilisé']);
                exit;
            }

            $user = MockDatabase::createUser($email, $password, $firstName, $lastName, $phone);

            $token = SimpleJWT::encode([
                'id' => $user['id'],
                'email' => $user['email'],
                'role' => $user['role'],
                'iat' => time(),
                'exp' => time() + 86400
            ]);

            http_response_code(201);
            echo json_encode([
                'token' => $token,
                'user' => [
                    'id' => $user['id'],
                    'email' => $user['email'],
                    'firstName' => $user['firstName'],
                    'lastName' => $user['lastName'],
                    'phone' => $user['phone'],
                    'role' => $user['role']
                ]
            ]);
        } else if ($method === 'POST' && $parts[1] === 'login') {
            // ═══ LOGIN ═══
            $data = json_decode(file_get_contents('php://input'), true);

            $email = $data['email'] ?? '';
            $password = $data['password'] ?? '';

            if (empty($email) || empty($password)) {
                http_response_code(400);
                echo json_encode(['error' => 'Email et password requis']);
                exit;
            }

            $user = MockDatabase::getUserByEmail($email);

            if (!$user || !password_verify($password, $user['password'])) {
                http_response_code(401);
                echo json_encode(['error' => 'Email ou password incorrect']);
                exit;
            }

            $token = SimpleJWT::encode([
                'id' => $user['id'],
                'email' => $user['email'],
                'role' => $user['role'],
                'iat' => time(),
                'exp' => time() + 86400
            ]);

            http_response_code(200);
            echo json_encode([
                'token' => $token,
                'user' => [
                    'id' => $user['id'],
                    'email' => $user['email'],
                    'firstName' => $user['firstName'],
                    'lastName' => $user['lastName'],
                    'phone' => $user['phone'],
                    'role' => $user['role'],
                    'status' => $user['status']
                ]
            ]);
        } else if ($method === 'GET' && $parts[1] === 'profile') {
            // ═══ GET PROFILE ═══
            $authHeader = $_SERVER['HTTP_AUTHORIZATION'] ?? '';
            if (empty($authHeader)) {
                http_response_code(401);
                echo json_encode(['error' => 'Token requis']);
                exit;
            }

            $token = str_replace('Bearer ', '', $authHeader);
            $decoded = SimpleJWT::decode($token);

            if (!$decoded || $decoded['exp'] < time()) {
                http_response_code(401);
                echo json_encode(['error' => 'Token invalide']);
                exit;
            }

            $user = MockDatabase::getUserByEmail($decoded['email']);

            http_response_code(200);
            echo json_encode([
                'id' => $user['id'],
                'email' => $user['email'],
                'firstName' => $user['firstName'],
                'lastName' => $user['lastName'],
                'phone' => $user['phone'],
                'profileImage' => $user['profileImage'],
                'status' => $user['status'],
                'role' => $user['role'],
                'createdAt' => $user['createdAt']
            ]);
        } else {
            http_response_code(404);
            echo json_encode(['error' => 'Endpoint non trouvé']);
        }
    } else {
        http_response_code(404);
        echo json_encode(['error' => 'Route non trouvée']);
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
}
