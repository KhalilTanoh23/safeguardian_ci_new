# 🚀 Guide d'Installation et Déploiement - SafeGuardian CI

## Table des matières
1. [Installation locale](#installation-locale)
2. [Configuration](#configuration)
3. [Déploiement](#déploiement)
4. [Troubleshooting](#troubleshooting)

---

## Installation Locale

### Prérequis
- **PHP**: 8.0 ou supérieur
- **MySQL**: 5.7 ou supérieur
- **Flutter**: 3.0+ (pour le frontend)
- **Composer** (optionnel, pour la gestion des dépendances PHP)
- **Git**

### Étapes Backend

#### 1. Cloner le projet
```bash
git clone <votre-repo> safeguardian_ci_new
cd safeguardian_ci_new/backend
```

#### 2. Créer la base de données
```bash
# Accéder à MySQL
mysql -u root -p

# Créer la base de données
CREATE DATABASE safeguardian_ci;
USE safeguardian_ci;

# Importer le schéma
source database/schema.sql;

# Vérifier les tables
SHOW TABLES;
```

#### 3. Configurer les variables d'environnement
Éditer `config/config.php`:
```php
const DB_HOST = 'localhost';
const DB_NAME = 'safeguardian_ci';
const DB_USER = 'root';
const DB_PASS = 'votre_mot_de_passe';
const JWT_SECRET = 'votre-clé-secrète-unique';
```

#### 4. Configurer JWT
Éditer `config/jwt.php`:
```php
private static $secret = 'votre-clé-secrète-unique';
// Générer une clé sécurisée:
// echo bin2hex(random_bytes(32));
```

#### 5. Vérifier les permissions
```bash
# Backend
chmod 755 backend/
chmod 755 backend/uploads/ (si existe)

# Frontend
chmod 755 lib/
```

#### 6. Démarrer le serveur PHP
```bash
cd backend
php -S localhost:8000

# Ou avec Apache (if configured)
# Redémarrer Apache: sudo systemctl restart apache2
```

**Test**: Ouvrir http://localhost:8000 - devrait retourner du JSON

---

### Étapes Frontend

#### 1. Installer les dépendances Flutter
```bash
cd ..
flutter pub get
```

#### 2. Configurer l'URL API
Éditer `lib/core/services/api_service.dart`:
```dart
static const String baseUrl = 'http://localhost:8000/api';
```

#### 3. Configurer Firebase (optionnel mais recommandé)
- Créer un projet Firebase
- Copier `google-services.json` dans `android/app/`
- Copier `GoogleService-Info.plist` dans `ios/Runner/`

#### 4. Lancer l'app
```bash
# Pour mobile
flutter run

# Pour web
flutter run -d chrome

# Pour Windows
flutter run -d windows
```

---

## Configuration

### Variables d'environnement importantes

| Variable | Valeur | Environnement |
|----------|--------|---------------|
| `JWT_SECRET` | Clé sécurisée (32+ caractères) | Production |
| `DB_HOST` | Serveur MySQL | Production |
| `API_URL` | URL de l'API | Frontend |
| `FIREBASE_API_KEY` | Clé Firebase | Production |

### Générer une clé JWT sécurisée
```bash
# Utiliser PHP
php -r 'echo bin2hex(random_bytes(32));'

# Utiliser OpenSSL
openssl rand -hex 32
```

### Créer un utilisateur administrateur
```sql
INSERT INTO users (email, password, first_name, last_name, phone, created_at)
VALUES (
    'admin@safeguardian.ci',
    '$2y$10$...',  -- Hash du mot de passe
    'Admin',
    'SafeGuardian',
    '+22500000000',
    NOW()
);
```

---

## Déploiement

### Déploiement Backend (Hébergement Web)

#### Option 1: Shared Hosting (cPanel/Plesk)

1. **FTP Upload**
   ```bash
   # Zipper le backend
   zip -r safeguardian_backend.zip backend/

   # Uploader via FTP
   ftp votre-serveur.com
   > put safeguardian_backend.zip
   > quit

   # Extraire sur le serveur
   unzip safeguardian_backend.zip
   ```

2. **Configurer SSL**
   - Activer HTTPS via le panneau de contrôle
   - Générer un certificat Let's Encrypt

3. **Configurer le domaine**
   - Mettre à jour les DNS
   - Configurer le `.htaccess` pour les routes

4. **Mettre à jour la config**
   - Éditer `config/config.php` avec les données de production
   - Changer `ENV = 'production'`

#### Option 2: VPS/Serveur Dédié

1. **SSH Connection**
   ```bash
   ssh user@ip_serveur
   
   # Cloner le repo
   git clone <repo> /var/www/safeguardian
   cd /var/www/safeguardian/backend
   ```

2. **Installer les dépendances**
   ```bash
   # PHP
   sudo apt install php8.1 php8.1-mysql php8.1-json

   # MySQL
   mysql -u root -p < database/schema.sql
   ```

3. **Configurer Nginx/Apache**
   ```nginx
   server {
       listen 80;
       server_name api.safeguardian.ci;
       root /var/www/safeguardian/backend;
       
       location / {
           try_files $uri $uri/ /index.php?$query_string;
       }
       
       location ~ \.php$ {
           fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
           fastcgi_index index.php;
           include fastcgi_params;
       }
   }
   ```

4. **Configurer HTTPS**
   ```bash
   sudo certbot certonly --nginx -d api.safeguardian.ci
   ```

#### Option 3: Docker

```dockerfile
# Dockerfile
FROM php:8.1-fpm

# Installer les extensions
RUN docker-php-ext-install pdo pdo_mysql

# Copier le code
COPY backend/ /var/www/html/

# Permissions
RUN chown -R www-data:www-data /var/www/html

EXPOSE 9000
```

```yaml
# docker-compose.yml
version: '3'
services:
  web:
    build: .
    ports:
      - "8000:9000"
    environment:
      DB_HOST: db
      DB_NAME: safeguardian_ci
    depends_on:
      - db
  
  db:
    image: mysql:5.7
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: safeguardian_ci
    volumes:
      - ./database/schema.sql:/docker-entrypoint-initdb.d/schema.sql
```

### Déploiement Frontend

#### Déploiement Web
```bash
flutter build web --release

# Uploader le dossier build/web sur le serveur
# Configurer le domaine vers ce dossier
```

#### Déploiement Mobile
```bash
# Android
flutter build apk --release
# Fichier: build/app/outputs/flutter-apk/app-release.apk

# iOS
flutter build ios --release
# Ouvrir dans Xcode pour l'archive finale
```

---

## Checklist de Déploiement

### Avant la mise en production
- [ ] Changer les mots de passe par défaut
- [ ] Générer une clé JWT sécurisée
- [ ] Mettre à jour `config/config.php`
- [ ] Vérifier les permissions des fichiers
- [ ] Configurer les backups de la base de données
- [ ] Mettre en place le logging
- [ ] Configurer HTTPS/SSL
- [ ] Tester tous les endpoints API
- [ ] Tester l'authentification
- [ ] Mettre à jour les URLs frontend

### Après la mise en production
- [ ] Surveiller les logs d'erreurs
- [ ] Configurer les alertes
- [ ] Effectuer les backups réguliers
- [ ] Maintenir les dépendances à jour
- [ ] Monitorer les performances

---

## Troubleshooting

### Problème: "Connection refused" à MySQL
```bash
# Vérifier que MySQL est démarré
sudo systemctl status mysql

# Ou pour MacOS
brew services list

# Redémarrer MySQL
sudo systemctl restart mysql
```

### Problème: "Undefined variable" dans PHP
```php
// Vérifier que bootstrap.php est inclus
// Dans api.php ou index.php
require_once __DIR__ . '/bootstrap.php';
```

### Problème: CORS errors
```php
// Vérifier les headers dans index.php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
```

### Problème: Token JWT invalide
```php
// Vérifier que la clé secrète est identique dans:
// - config/jwt.php (backend)
// - Token généré
```

### Problème: Fichiers uploadés non trouvés
```bash
# Vérifier le répertoire uploads
ls -la backend/uploads/

# Donner les permissions
chmod 775 backend/uploads/
```

---

## Logs et Monitoring

### Activer les logs PHP
```php
// Dans config/config.php
ini_set('log_errors', 1);
ini_set('error_log', __DIR__ . '/../logs/php_errors.log');
```

### Consulter les logs
```bash
# Logs PHP
tail -f backend/logs/php_errors.log

# Logs base de données
tail -f /var/log/mysql/error.log

# Logs serveur
tail -f /var/log/apache2/error.log
```

---

## Support

Pour plus d'aide, consultez:
- [Documentation Flutter](https://flutter.dev/docs)
- [Documentation PHP](https://www.php.net)
- [Documentation MySQL](https://dev.mysql.com/doc)

---

**Déploiement réussi! 🎉**
