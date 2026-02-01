<!-- Installation et Configuration Rapide -->

# 🚀 Quick Start - Développement Local

## Configuration Initiale (5 minutes)

### 1. Backend PHP

```bash
# Terminal XAMPP
cd c:\Users\Msi\safeguardian_ci_new\backend

# Lancer serveur PHP
"C:\xampp\php\php.exe" -S localhost:8000 index.php

# Vérifier: http://localhost:8000/api/test
```

### 2. Base de Données

```bash
# Dans MySQL Workbench ou phpMyAdmin
1. Import: backend/database/init_mysql.sql
2. Utilisateur: safeguardian_user / silentOps@#
3. BD: safeguardian_prod
```

### 3. Flutter Frontend

```bash
cd lib/core/constants

# Fichier: api_constants.dart
const String API_BASE_URL = 'http://localhost:8000/api';

# Lancer app
flutter run
```

---

## Tests Rapides

### API Health Check

```bash
# Test connexion DB
curl http://localhost:8000/api/test

# Register
curl -X POST http://localhost:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"Pass123!","first_name":"Test","last_name":"User"}'

# Login
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"Pass123!"}'
```

### Flutter

```bash
# Hot reload après changements
r - reload
R - restart
q - quit
```

---

## Architecture Fichiers Créés

### Backend (PHP)

```
backend/
├── controllers/
│   ├── AuthControllerImpl.php ✨ NOUVEAU
│   ├── AlertControllerImpl.php ✨ NOUVEAU
│   ├── EmergencyContactControllerImpl.php ✨ NOUVEAU
│   ├── ItemControllerImpl.php ✨ NOUVEAU
│   └── DocumentControllerImpl.php ✨ NOUVEAU
├── utils/
│   ├── Validator.php ✨ NOUVEAU
│   └── ResponseHandler.php ✨ NOUVEAU
└── middleware/
    └── AuthMiddleware.php ✅ EXISTANT

```

### Frontend (Flutter)

```
lib/
├── core/
│   ├── constants/
│   │   └── api_constants.dart ✨ NOUVEAU
│   └── services/
│       └── api_service_impl.dart ✨ NOUVEAU
└── (reste existant)
```

---

## Prochaines Étapes (UTILISATEUR)

1. **Firebase Setup**
   - Créer projet Firebase
   - Télécharger google-services.json (Android)
   - Télécharger GoogleService-Info.plist (iOS)
   - Ajouter à firebase_options.dart

2. **Tests sur Appareil Réel**
   - Android: `flutter run -d <device_id>`
   - iOS: `flutter run -d <device_id>`
   - Tester GPS, Bluetooth, Permissions

3. **Déploiement Production**
   - Suivre: DEPLOYMENT_COMPLETE_GUIDE.md
   - Configurer domaine
   - SSL avec Let's Encrypt
   - Monitoring & alertes

4. **Performance & Sécurité**
   - Load testing
   - Pentest
   - Security audit
   - Code review

---

## Fichiers de Configuration Importants

| Fichier                 | Lieu                  | Purpose                    |
| ----------------------- | --------------------- | -------------------------- |
| `.env`                  | `backend/`            | Credentials DB, JWT secret |
| `pubspec.yaml`          | `lib/`                | Flutter dependencies       |
| `api_constants.dart`    | `lib/core/constants/` | API endpoints config       |
| `firebase_options.dart` | `lib/`                | Firebase configuration     |

---

## Variables d'Environnement Production

À configurer sur serveur :

```env
# .env (Production)
DB_HOST=localhost
DB_NAME=safeguardian_prod
DB_USER=safeguardian_user
DB_PASS=YourStrongPassword123!@#$
JWT_SECRET=YourLongSecretKey456!@#$%^&*
ALLOWED_ORIGINS=https://app.safeguardian.ci
DEBUG=false
```

---

## Status Actuel

✅ **Complété:**

- [x] Backend: Controllers implémentés (Auth, Alert, Contact, Item, Document)
- [x] Validation: Validator.php avec 8 méthodes
- [x] Response handling: ResponseHandler.php standardisé
- [x] Flutter: API service complet (ApiService)
- [x] Configuration: API constants et endpoints
- [x] Database: Schema avec 13 tables
- [x] Middleware: Auth JWT implémenté

⏳ **À faire (UTILISATEUR):**

- [ ] Firebase setup (google-services.json, etc)
- [ ] Tests sur appareil réel (Android/iOS)
- [ ] Deployment serveur
- [ ] Domain + SSL
- [ ] Monitoring setup
- [ ] Publishing Play Store/App Store

---

**Pour déployer en production, voir: [DEPLOYMENT_COMPLETE_GUIDE.md](DEPLOYMENT_COMPLETE_GUIDE.md)**

Version: 1.0.0 | Dernière mise à jour: 2024-01-15
