# SafeGuardian CI - Backend API

Backend PHP pour l'application SafeGuardian CI, une application d'alertes d'urgence pour la Côte d'Ivoire.

## Technologies utilisées

- **PHP 8.0+** : Langage de programmation
- **MySQL** : Base de données
- **JWT** : Authentification stateless
- **Composer** : Gestionnaire de dépendances (optionnel)

## Installation

### 1. Prérequis

- PHP 8.0 ou supérieur
- MySQL 5.7 ou supérieur
- Serveur web (Apache/Nginx) avec mod_rewrite activé
- Extension PDO MySQL activée

### 2. Configuration de la base de données

1. Créer une base de données MySQL :
```sql
CREATE DATABASE safeguardian_ci;
```

2. Exécuter le script SQL :
```bash
mysql -u root -p safeguardian_ci < database/schema.sql
```

3. Modifier les paramètres de connexion dans `config/database.php` :
```php
$host = 'localhost';  // Votre hôte MySQL
$db = 'safeguardian_ci';  // Nom de la base
$user = 'root';  // Utilisateur MySQL
$pass = '';  // Mot de passe MySQL
```

### 3. Configuration JWT

Modifier la clé secrète dans `config/jwt.php` :
```php
private static $secret = 'votre-cle-secrete-unique-ici';
```

### 4. Déploiement

Placer le dossier `backend/` dans le répertoire racine de votre serveur web ou utiliser un serveur PHP intégré :

```bash
cd backend
php -S localhost:8000
```

## Structure du projet

```
backend/
├── config/
│   ├── database.php    # Configuration base de données
│   └── jwt.php         # Gestion JWT
├── controllers/
│   ├── AuthController.php           # Authentification
│   ├── EmergencyContactController.php  # Contacts d'urgence
│   ├── AlertController.php          # Gestion des alertes
│   ├── ItemController.php           # Objets personnels
│   └── DocumentController.php       # Documents
├── middleware/
│   └── AuthMiddleware.php           # Middleware d'authentification
├── routes/
│   └── api.php                      # Routage API
├── database/
│   └── schema.sql                   # Schéma base de données
├── uploads/                         # Dossier pour les fichiers uploadés
├── .htaccess                        # Configuration Apache
├── index.php                        # Point d'entrée API
└── README.md                        # Documentation
```

## API Endpoints

### Authentification

- `POST /api/auth/register` - Inscription utilisateur
- `POST /api/auth/login` - Connexion utilisateur
- `GET /api/auth/profile` - Profil utilisateur (authentifié)

### Contacts d'urgence

- `GET /api/contacts` - Liste des contacts (authentifié)
- `POST /api/contacts` - Ajouter un contact (authentifié)
- `PUT /api/contacts/{id}` - Modifier un contact (authentifié)
- `DELETE /api/contacts/{id}` - Supprimer un contact (authentifié)

### Alertes

- `GET /api/alerts` - Liste des alertes (authentifié)
- `POST /api/alerts` - Créer une alerte (authentifié)
- `PUT /api/alerts/{id}` - Mettre à jour le statut d'une alerte (authentifié)

### Objets

- `GET /api/items` - Liste des objets (authentifié)
- `POST /api/items` - Ajouter un objet (authentifié)
- `PUT /api/items/{id}` - Modifier un objet (authentifié)
- `DELETE /api/items/{id}` - Supprimer un objet (authentifié)

### Documents

- `GET /api/documents` - Liste des documents (authentifié)
- `POST /api/documents` - Ajouter un document (authentifié)
- `PUT /api/documents/{id}` - Modifier un document (authentifié)
- `DELETE /api/documents/{id}` - Supprimer un document (authentifié)
- `GET /api/documents/download/{id}` - Télécharger un document (authentifié)

## Authentification

L'API utilise JWT (JSON Web Tokens) pour l'authentification. Inclure le token dans l'en-tête Authorization :

```
Authorization: Bearer votre_token_jwt
```

## Format des données

### Inscription/Connexion

```json
{
  "email": "user@example.com",
  "password": "motdepasse",
  "firstName": "Jean",
  "lastName": "Dupont",
  "phone": "+2250102030405"
}
```

### Contact d'urgence

```json
{
  "name": "Marie Dupont",
  "relationship": "Conjoint",
  "phone": "+2250607080910",
  "email": "marie@example.com",
  "priority": 2
}
```

### Alerte

```json
{
  "latitude": 5.316667,
  "longitude": -4.033333,
  "message": "Besoin d'aide urgente"
}
```

## Codes de réponse

- `200` : Succès
- `201` : Créé avec succès
- `400` : Requête invalide
- `401` : Non authentifié
- `403` : Interdit
- `404` : Non trouvé
- `500` : Erreur serveur

## Sécurité

- Mots de passe hashés avec bcrypt
- Tokens JWT avec expiration (24h)
- Validation des entrées utilisateur
- Protection contre les injections SQL avec PDO
- Headers CORS configurés

## Développement

### Tests

Créer un fichier de test pour vérifier les endpoints :

```php
// test_api.php
<?php
// Tests des endpoints API
```

### Logs

Les erreurs sont loggées dans les fichiers d'erreur PHP. Pour des logs personnalisés :

```php
error_log("Message d'erreur", 3, "logs/error.log");
```

## Déploiement en production

1. Changer la clé JWT secrète
2. Configurer HTTPS
3. Optimiser la configuration PHP
4. Mettre en place des sauvegardes automatiques
5. Configurer la surveillance des logs

## Support

Pour toute question ou problème, contacter l'équipe de développement SafeGuardian CI.
