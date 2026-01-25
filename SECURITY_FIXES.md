# 🔐 CORRECTIONS DE SÉCURITÉ - SafeGuardian CI

**Solutions prêtes à implémenter pour sécuriser l'application**

---

## 1. 🔴 FIXER CORS TROP PERMISSIF

### ❌ Avant (INSÉCURISÉ)
```php
header('Access-Control-Allow-Origin: *');  // Accepte TOUT!
```

### ✅ Après (SÉCURISÉ)
```php
<?php
// backend/config/cors.php
class CORSConfig {
    // Domaines autorisés
    const ALLOWED_ORIGINS = [
        'https://app.safeguardian.ci',      // Production app
        'https://admin.safeguardian.ci',    // Admin panel
        'http://localhost:3000',             // Dev frontend
        'http://localhost:8080',             // Dev flutter web
    ];

    public static function configureHeaders() {
        $origin = $_SERVER['HTTP_ORIGIN'] ?? '';
        
        // Vérifier si l'origine est autorisée
        if (in_array($origin, self::ALLOWED_ORIGINS)) {
            header("Access-Control-Allow-Origin: $origin");
            header('Access-Control-Allow-Credentials: true');
            header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS, PATCH');
            header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
            header('Access-Control-Max-Age: 86400');
        } else {
            // Rejeter les origines non autorisées
            http_response_code(403);
            exit(json_encode(['error' => 'Origin not allowed']));
        }
    }
}
```

### 📝 Utilisation
```php
// backend/index.php
require_once __DIR__ . '/config/cors.php';
CORSConfig::configureHeaders();
```

---

## 2. 🔴 SÉCURISER JWT SECRET

### ❌ Avant (INSÉCURISÉ)
```php
private static $secret = 'your-secret-key-here-change-in-production';
```

### ✅ Après (SÉCURISÉ)
```php
<?php
// backend/config/jwt.php

class JWT {
    // Utiliser variable d'environnement
    private static $secret = null;

    public static function getSecret() {
        if (self::$secret === null) {
            self::$secret = $_ENV['JWT_SECRET'] ?? getenv('JWT_SECRET');
            
            if (empty(self::$secret)) {
                throw new Exception('JWT_SECRET non configurée!');
            }
            
            // Vérifier la longueur (minimum 32 caractères)
            if (strlen(self::$secret) < 32) {
                throw new Exception('JWT_SECRET doit faire au minimum 32 caractères');
            }
        }
        
        return self::$secret;
    }

    public static function encode($payload) {
        $secret = self::getSecret();
        
        $header = json_encode(['typ' => 'JWT', 'alg' => 'HS256']);
        $header_encoded = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($header));

        $payload_encoded = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode(json_encode($payload)));

        $signature = hash_hmac('sha256', $header_encoded . "." . $payload_encoded, $secret, true);
        $signature_encoded = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($signature));

        return $header_encoded . "." . $payload_encoded . "." . $signature_encoded;
    }

    public static function decode($token) {
        $secret = self::getSecret();
        
        $parts = explode('.', $token);
        if (count($parts) !== 3) {
            return false;
        }

        $header = $parts[0];
        $payload = $parts[1];
        $signature = $parts[2];

        $expected_signature = hash_hmac('sha256', $header . "." . $payload, $secret, true);
        $expected_signature_encoded = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($expected_signature));

        if ($signature !== $expected_signature_encoded) {
            return false;
        }

        $payload_decoded = json_decode(base64_decode(str_replace(['-', '_'], ['+', '/'], $payload)), true);
        return $payload_decoded;
    }
}
```

### 📝 Générer une clé sécurisée
```bash
# Générer une clé forte
php -r 'echo bin2hex(random_bytes(32));'

# Exemple de résultat:
# a3f8c9e2d1b4f7a6c5e8d2b1f9a3c6e5d8f2b5a8e1c4f7a0d3b6c9e2f5a8

# Mettre dans .env
JWT_SECRET=a3f8c9e2d1b4f7a6c5e8d2b1f9a3c6e5d8f2b5a8e1c4f7a0d3b6c9e2f5a8
```

---

## 3. 🔴 AJOUTER VALIDATION DES INPUTS

### ✅ Nouvelle classe
```php
<?php
// backend/utils/InputValidator.php

class InputValidator {
    
    /**
     * Valider les données d'inscription
     */
    public static function validateRegister($data) {
        $errors = [];
        
        // Email
        if (empty($data['email'])) {
            $errors['email'] = 'Email requis';
        } elseif (!filter_var($data['email'], FILTER_VALIDATE_EMAIL)) {
            $errors['email'] = 'Email invalide';
        } elseif (strlen($data['email']) > 255) {
            $errors['email'] = 'Email trop long';
        }
        
        // Password
        if (empty($data['password'])) {
            $errors['password'] = 'Mot de passe requis';
        } elseif (strlen($data['password']) < 8) {
            $errors['password'] = 'Minimum 8 caractères';
        } elseif (!preg_match('/[A-Z]/', $data['password'])) {
            $errors['password'] = 'Au moins 1 majuscule requise';
        } elseif (!preg_match('/[0-9]/', $data['password'])) {
            $errors['password'] = 'Au moins 1 chiffre requis';
        } elseif (!preg_match('/[!@#$%^&*]/', $data['password'])) {
            $errors['password'] = 'Au moins 1 caractère spécial requis';
        }
        
        // First Name
        if (empty($data['firstName'])) {
            $errors['firstName'] = 'Prénom requis';
        } elseif (strlen($data['firstName']) > 50) {
            $errors['firstName'] = 'Prénom trop long';
        }
        
        // Last Name
        if (empty($data['lastName'])) {
            $errors['lastName'] = 'Nom requis';
        } elseif (strlen($data['lastName']) > 50) {
            $errors['lastName'] = 'Nom trop long';
        }
        
        // Phone
        if (empty($data['phone'])) {
            $errors['phone'] = 'Téléphone requis';
        } elseif (!preg_match('/^(\+225|0)[0-9]{9,10}$/', preg_replace('/\s+/', '', $data['phone']))) {
            $errors['phone'] = 'Téléphone invalide (format: +225XXXXXXXXX ou 0XXXXXXXXX)';
        }
        
        return [
            'valid' => empty($errors),
            'errors' => $errors
        ];
    }
    
    /**
     * Valider les données de connexion
     */
    public static function validateLogin($data) {
        $errors = [];
        
        if (empty($data['email'])) {
            $errors['email'] = 'Email requis';
        } elseif (!filter_var($data['email'], FILTER_VALIDATE_EMAIL)) {
            $errors['email'] = 'Email invalide';
        }
        
        if (empty($data['password'])) {
            $errors['password'] = 'Mot de passe requis';
        }
        
        return [
            'valid' => empty($errors),
            'errors' => $errors
        ];
    }
    
    /**
     * Sanitizer une chaîne
     */
    public static function sanitizeString($string) {
        return trim(htmlspecialchars(stripslashes($string), ENT_QUOTES, 'UTF-8'));
    }
    
    /**
     * Sanitizer un email
     */
    public static function sanitizeEmail($email) {
        return filter_var(trim(strtolower($email)), FILTER_SANITIZE_EMAIL);
    }
}
```

### 📝 Utilisation
```php
// backend/controllers/AuthController.php

public function register($data) {
    try {
        // Validation
        $validation = InputValidator::validateRegister($data);
        if (!$validation['valid']) {
            return ResponseHandler::validationError($validation['errors']);
        }
        
        // Sanitization
        $data['email'] = InputValidator::sanitizeEmail($data['email']);
        $data['firstName'] = InputValidator::sanitizeString($data['firstName']);
        $data['lastName'] = InputValidator::sanitizeString($data['lastName']);
        
        // ... reste du code
    }
}
```

---

## 4. 🔴 IMPLÉMENTER RATE LIMITING

### ✅ Nouvelle classe
```php
<?php
// backend/utils/RateLimiter.php

class RateLimiter {
    private $maxAttempts = 5;           // 5 tentatives
    private $lockoutDuration = 900;     // 15 minutes
    
    /**
     * Vérifier et enregistrer une tentative
     */
    public function checkLimit($identifier, $action = 'login') {
        $cacheKey = "rate_limit:{$action}:{$identifier}";
        $attempts = apcu_fetch($cacheKey);
        
        if ($attempts === false) {
            $attempts = 0;
        }
        
        $attempts++;
        
        if ($attempts > $this->maxAttempts) {
            http_response_code(429);
            return [
                'success' => false,
                'error' => 'Trop de tentatives. Veuillez réessayer dans 15 minutes.'
            ];
        }
        
        // Enregistrer la tentative
        apcu_store($cacheKey, $attempts, $this->lockoutDuration);
        
        return ['success' => true];
    }
    
    /**
     * Réinitialiser les tentatives
     */
    public function reset($identifier, $action = 'login') {
        $cacheKey = "rate_limit:{$action}:{$identifier}";
        apcu_delete($cacheKey);
    }
}
```

### 📝 Utilisation
```php
// backend/controllers/AuthController.php

public function login($data) {
    try {
        $rateLimiter = new RateLimiter();
        
        // Vérifier le rate limiting
        $limitCheck = $rateLimiter->checkLimit($data['email'], 'login');
        if (!$limitCheck['success']) {
            return $limitCheck;
        }
        
        // Reste du code...
        
        // Si succès, réinitialiser
        $rateLimiter->reset($data['email'], 'login');
    }
}
```

---

## 5. 🔴 SÉCURISER LES CREDENTIALS

### ❌ Avant (INSÉCURISÉ)
```php
$host = 'localhost';
$db = 'safeguardian_ci';
$user = 'root';
$pass = '';
```

### ✅ Après (SÉCURISÉ)
```php
<?php
// backend/config/database.php

class Database {
    private static $instance = null;
    private $pdo;

    private function __construct() {
        // Utiliser des variables d'environnement
        $host = $_ENV['DB_HOST'] ?? getenv('DB_HOST') ?? 'localhost';
        $db = $_ENV['DB_NAME'] ?? getenv('DB_NAME');
        $user = $_ENV['DB_USER'] ?? getenv('DB_USER');
        $pass = $_ENV['DB_PASS'] ?? getenv('DB_PASS') ?? '';
        
        // Vérifier les variables obligatoires
        if (empty($db) || empty($user)) {
            throw new Exception('Database credentials not configured');
        }

        $charset = 'utf8mb4';
        $dsn = "mysql:host=$host;dbname=$db;charset=$charset";
        $options = [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES   => false,
        ];

        try {
            $this->pdo = new PDO($dsn, $user, $pass, $options);
        } catch (PDOException $e) {
            throw new Exception('Database connection failed');
        }
    }

    // ... reste du code
}
```

### 📝 Fichier .env
```bash
# .env (à la racine du backend)
DB_HOST=localhost
DB_NAME=safeguardian_ci
DB_USER=safeguardian_user
DB_PASS=mot_de_passe_fort_ici
JWT_SECRET=clé_jwt_forte_ici_32_caractères_minimum
APP_ENV=production
APP_DEBUG=false
```

### 📝 .gitignore
```bash
# .gitignore
.env
.env.local
.env.*.local
config/config.php
*.log
```

---

## 6. 🟠 CHIFFRER TOKENS EN FRONTEND

### ✅ Nouvelle classe Dart
```dart
// lib/core/services/secure_storage_service.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const String _tokenKey = 'auth_token';
  
  final _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_available_when_unlocked_this_device_only,
    ),
  );

  /// Sauvegarder le token de manière sécurisée
  Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(
        key: _tokenKey,
        value: token,
      );
    } catch (e) {
      debugPrint('❌ Erreur sauvegarde token: $e');
      rethrow;
    }
  }

  /// Récupérer le token
  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: _tokenKey);
    } catch (e) {
      debugPrint('❌ Erreur lecture token: $e');
      return null;
    }
  }

  /// Supprimer le token
  Future<void> removeToken() async {
    try {
      await _secureStorage.delete(key: _tokenKey);
    } catch (e) {
      debugPrint('❌ Erreur suppression token: $e');
    }
  }

  /// Vérifier si token existe
  Future<bool> hasToken() async {
    try {
      final token = await getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
```

### 📝 Ajouter à pubspec.yaml
```yaml
dependencies:
  flutter_secure_storage: ^9.0.0
```

### 📝 Utilisation
```dart
// lib/core/services/api_service.dart

class ApiService {
  final _secureStorage = SecureStorageService();

  Future<void> setToken(String token) async {
    await _secureStorage.saveToken(token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.getToken();
  }
}
```

---

## 7. 🟠 FORCER HTTPS

### ✅ Configuration Frontend
```dart
// lib/core/services/api_service.dart

class ApiService {
  // Utiliser HTTPS en production
  static String get baseUrl {
    const isDev = bool.fromEnvironment('DEV_MODE', defaultValue: true);
    
    if (isDev) {
      return 'http://localhost:8000/api';  // Dev
    } else {
      return 'https://api.safeguardian.ci/api';  // Production
    }
  }

  Future<http.Response> _makeRequest(
    String method,
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      
      // Vérifier HTTPS en production
      if (!kDebugMode && uri.scheme != 'https') {
        throw Exception('HTTPS requis en production');
      }
      
      // ...
    }
  }
}
```

### ✅ Configuration Backend
```bash
# .htaccess ou Nginx config
# Rediriger HTTP vers HTTPS
RewriteEngine On
RewriteCond %{HTTPS} off
RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
```

---

## 8. 🟠 VALIDER CERTIFICATS SSL

### ✅ Configuration Flutter
```dart
// lib/core/services/api_service.dart

import 'package:http/http.dart' as http;
import 'dart:io';

class ApiService {
  late http.Client _httpClient;

  ApiService() {
    // Créer un HttpClient avec validation SSL stricte
    final httpClient = HttpClient();
    httpClient.badCertificateCallback = (cert, host, port) {
      // En production, toujours retourner false
      // (rejeter les certificats invalides)
      return !kReleaseMode;  // Accepter seulement en debug
    };
    
    _httpClient = http.IOClient(httpClient);
  }

  // Utiliser _httpClient pour toutes les requêtes
}
```

---

## 9. 🟠 RÉDUIRE DURÉE DE SESSION

### ✅ Avant (INSÉCURISÉ)
```php
'exp' => time() + (24 * 60 * 60) // 24 heures!
```

### ✅ Après (SÉCURISÉ)
```php
<?php
// backend/config/jwt.php

class JWT {
    // Durées de session
    const SHORT_SESSION = 900;      // 15 minutes
    const MEDIUM_SESSION = 3600;    // 1 heure  
    const LONG_SESSION = 86400;     // 24 heures (refresh token)
    
    public static function encode($payload, $duration = self::MEDIUM_SESSION) {
        $payload['exp'] = time() + $duration;
        // ... reste du code
    }
}

// Utilisation
$token = JWT::encode([
    'userId' => $userId,
    'email' => $user['email'],
    'type' => 'access'  // Distinguer access/refresh tokens
], JWT::MEDIUM_SESSION);

$refreshToken = JWT::encode([
    'userId' => $userId,
    'type' => 'refresh'
], JWT::LONG_SESSION);
```

---

## 10. 🟠 AJOUTER CSRF PROTECTION

### ✅ Nouvelle classe
```php
<?php
// backend/utils/CSRFToken.php

class CSRFToken {
    const TOKEN_LENGTH = 32;
    const SESSION_KEY = 'csrf_token';
    
    /**
     * Générer un token CSRF
     */
    public static function generate() {
        if (!isset($_SESSION[self::SESSION_KEY])) {
            $_SESSION[self::SESSION_KEY] = bin2hex(random_bytes(self::TOKEN_LENGTH));
        }
        
        return $_SESSION[self::SESSION_KEY];
    }
    
    /**
     * Vérifier un token CSRF
     */
    public static function verify($token) {
        return isset($_SESSION[self::SESSION_KEY]) && 
               hash_equals($_SESSION[self::SESSION_KEY], $token);
    }
    
    /**
     * Obtenir le token depuis le header
     */
    public static function getFromRequest() {
        return $_SERVER['HTTP_X_CSRF_TOKEN'] ?? 
               $_POST['csrf_token'] ?? 
               null;
    }
}
```

### 📝 Utilisation
```php
// Dans les POST/PUT/DELETE
$token = CSRFToken::getFromRequest();
if (!CSRFToken::verify($token)) {
    http_response_code(403);
    return ['error' => 'CSRF token invalide'];
}
```

---

## 🚀 RÉSUMÉ DES CHANGES

| Problème | Correction | Priorité |
|----------|-----------|----------|
| CORS permissif | CORSConfig class | 🔴 CRITIQUE |
| JWT weak secret | Variable d'env | 🔴 CRITIQUE |
| No validation | InputValidator class | 🔴 CRITIQUE |
| No rate limit | RateLimiter class | 🔴 CRITIQUE |
| Exposed credentials | .env file | 🔴 CRITIQUE |
| Insecure token storage | FlutterSecureStorage | 🟠 HAUTE |
| No HTTPS | Force HTTPS config | 🟠 HAUTE |
| No SSL validation | Certificate validation | 🟠 HAUTE |
| Long sessions | Reduce JWT exp time | 🟠 HAUTE |
| No CSRF | CSRFToken class | 🟠 HAUTE |

---

## 📋 Checklist d'Implémentation

- [ ] Créer CORSConfig.php
- [ ] Mettre à jour JWT.php avec env variables
- [ ] Créer InputValidator.php
- [ ] Créer RateLimiter.php
- [ ] Créer fichier .env
- [ ] Mettre à jour .gitignore
- [ ] Ajouter flutter_secure_storage
- [ ] Créer SecureStorageService.dart
- [ ] Configurer HTTPS en production
- [ ] Créer CSRFToken.php
- [ ] Tester toutes les corrections
- [ ] Documentation mise à jour

---

**Prochaine étape**: Implémenter ces corrections immédiatement! 🔒
