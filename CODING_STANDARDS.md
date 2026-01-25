# 📖 Conventions de Codage - SafeGuardian CI

## Frontend (Dart/Flutter)

### 1. Nommage des fichiers
```dart
// ✅ Bon
class_name.dart
my_widget.dart
auth_bloc.dart

// ❌ Mauvais
MyClass.dart
MyWidget.dart
auth_BLoC.dart
```

### 2. Organisation des imports
```dart
// 1. Imports Flutter/Dart
import 'package:flutter/material.dart';
import 'dart:async';

// 2. Imports packages
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// 3. Imports locaux
import '../../core/services/api_service.dart';
import '../models/user.dart';
```

### 3. Nommage des variables
```dart
// ✅ Bon
final userName = 'John';
late final int userId;
const maxAttempts = 3;
final _privateVariable = 'hidden';

// ❌ Mauvais
final user_name = 'John';
late final INT userId;
const MAX_ATTEMPTS = 3;
final privateVariable = 'hidden';
```

### 4. Structure d'une classe
```dart
class MyWidget extends StatefulWidget {
  // 1. Constantes
  static const String routeName = '/my_widget';
  
  // 2. Propriétés publiques
  final String title;
  
  // 3. Propriétés privées
  final String _privateData;
  
  // 4. Constructeur
  const MyWidget({
    required this.title,
    required String privateData,
  }) : _privateData = privateData;
  
  // 5. Méthodes
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

### 5. Documentation
```dart
/// Crée un utilisateur avec les données fournies.
///
/// [email] est l'email unique de l'utilisateur
/// [password] doit contenir au moins 8 caractères
///
/// Retourne [User] si succès, sinon lève une exception
Future<User> createUser({
  required String email,
  required String password,
}) async {
  // Implémentation
}
```

---

## Backend (PHP)

### 1. Nommage des fichiers
```php
// ✅ Bon
UserController.php
DatabaseConnection.php
user_repository.php

// ❌ Mauvais
user_controller.php
database_connection.php
UserRepository.php
```

### 2. Organisation des fichiers
```
backend/
├── config/           # Configuration
├── controllers/      # Contrôleurs
├── middleware/       # Middleware
├── utils/           # Utilitaires
├── database/        # Migrations
└── routes/          # Routes
```

### 3. Nommage des variables
```php
// ✅ Bon
$userId = 1;
$userName = 'John';
private $database;
const MAX_ATTEMPTS = 3;

// ❌ Mauvais
$user_id = 1;
$USER_NAME = 'John';
private $db;
const maxAttempts = 3;
```

### 4. Structure d'une classe
```php
<?php

namespace App\Controllers;

use PDO;

class UserController {
    // 1. Propriétés
    private $db;
    
    // 2. Constantes
    const MAX_LOGIN_ATTEMPTS = 5;
    
    // 3. Constructeur
    public function __construct() {
        $this->db = Database::getInstance()->getConnection();
    }
    
    // 4. Méthodes publiques
    public function createUser($data) {
        // Validation
        // Logique
        // Retour
    }
    
    // 5. Méthodes privées
    private function validateEmail($email) {
        return filter_var($email, FILTER_VALIDATE_EMAIL);
    }
}
```

### 5. Gestion d'erreurs
```php
try {
    // Code
    $result = $this->database->query($sql);
    
} catch (PDOException $e) {
    // Log l'erreur
    error_log($e->getMessage());
    
    // Retourner une réponse d'erreur
    return ResponseHandler::error(
        'Erreur de base de données',
        500
    );
}
```

### 6. Validation des données
```php
// Réinitialiser les erreurs
Validator::reset();

// Valider
Validator::required($email, 'Email');
Validator::email($email, 'Email');
Validator::minLength($password, 8, 'Mot de passe');

// Vérifier les erreurs
if (Validator::hasErrors()) {
    return ResponseHandler::validationError(
        Validator::getErrors()
    );
}
```

### 7. Réponses JSON
```php
// ✅ Succès
ResponseHandler::success(
    $data,
    'Utilisateur créé avec succès',
    201
);

// ❌ Erreur
ResponseHandler::error(
    'Email déjà utilisé',
    400
);

// ⚠️ Non autorisé
ResponseHandler::unauthorized();
```

---

## API REST

### 1. Conventions des endpoints
```
GET    /api/users           # Lister
POST   /api/users           # Créer
GET    /api/users/{id}      # Détail
PUT    /api/users/{id}      # Modifier
DELETE /api/users/{id}      # Supprimer
PATCH  /api/users/{id}      # Mise à jour partielle
```

### 2. Codes de statut HTTP
```
200 OK                       # Succès GET, PUT, PATCH
201 Created                  # Succès POST
204 No Content              # Succès DELETE
400 Bad Request             # Erreur client
401 Unauthorized            # Non authentifié
403 Forbidden               # Pas de permissions
404 Not Found               # Ressource inexistante
422 Unprocessable Entity    # Erreur de validation
500 Internal Server Error   # Erreur serveur
```

### 3. Format de réponse
```json
// ✅ Succès
{
  "success": true,
  "message": "Opération réussie",
  "data": {
    "id": 1,
    "name": "John"
  },
  "timestamp": "2024-01-20T10:30:00Z"
}

// ❌ Erreur
{
  "success": false,
  "message": "Email invalide",
  "errors": [
    "Email doit être valide"
  ],
  "timestamp": "2024-01-20T10:30:00Z"
}
```

### 4. Authentification
```
// Header requis pour les routes protégées
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

// Token dans le header Authorization
// Format: Bearer <token>
```

---

## Git Commits

### Format
```
<type>(<scope>): <message>

<body>

<footer>
```

### Types
```
feat:     Nouvelle fonctionnalité
fix:      Correction de bug
refactor: Refactorisation du code
style:    Changements de style (sans logic)
test:     Ajout de tests
docs:     Documentation
```

### Exemples
```
feat(auth): ajouter connexion avec JWT

- Implémenter le contrôleur d'authentification
- Ajouter la middleware JWT
- Générer et valider les tokens

Closes #123
```

```
fix(api): corriger l'endpoint des alertes

La réponse d'erreur n'était pas correctement formatée

Closes #456
```

---

## Sécurité

### 1. Validation des inputs
```php
// ✅ Toujours valider
$email = filter_var($_POST['email'], FILTER_VALIDATE_EMAIL);
if (!$email) {
    return ResponseHandler::error('Email invalide', 400);
}
```

### 2. Mot de passe
```php
// ✅ Hasher les mots de passe
$hash = password_hash($password, PASSWORD_DEFAULT);

// ✅ Vérifier les mots de passe
if (password_verify($password, $hash)) {
    // OK
}
```

### 3. SQL Injection
```php
// ❌ JAMAIS faire cela
$query = "SELECT * FROM users WHERE id = " . $_GET['id'];

// ✅ Utiliser des prepared statements
$stmt = $db->prepare("SELECT * FROM users WHERE id = ?");
$stmt->execute([$userId]);
```

### 4. CORS
```php
// ✅ En développement
header('Access-Control-Allow-Origin: *');

// ✅ En production
header('Access-Control-Allow-Origin: https://app.safeguardian.ci');
```

---

## Tests

### Dart - Unit Test
```dart
void main() {
  group('ApiService', () {
    test('createUser should return User', () async {
      // Arrange
      final apiService = ApiService();
      
      // Act
      final user = await apiService.createUser(
        email: 'test@example.com',
        password: 'password123',
      );
      
      // Assert
      expect(user.email, 'test@example.com');
    });
  });
}
```

### PHP - Unit Test
```php
class UserControllerTest extends TestCase {
    public function testCreateUser() {
        // Arrange
        $controller = new UserController();
        
        // Act
        $result = $controller->createUser([
            'email' => 'test@example.com',
            'password' => 'password123',
        ]);
        
        // Assert
        $this->assertTrue($result['success']);
    }
}
```

---

## Checklist de Review

- [ ] Le code suit les conventions
- [ ] Les noms sont explicites
- [ ] Les commentaires sont utiles
- [ ] Pas de code dupliqué
- [ ] Les tests passent
- [ ] Pas de logs de debug
- [ ] Les erreurs sont gérées
- [ ] La sécurité est respectée
- [ ] La performance est acceptable
- [ ] La documentation est à jour

---

**Respect des conventions = Code de qualité! 💪**
