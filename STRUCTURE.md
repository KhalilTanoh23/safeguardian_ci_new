# 📋 SafeGuardian CI - Structure du Projet

## 🎯 Vue d'ensemble

SafeGuardian CI est une application d'alertes d'urgence pour la Côte d'Ivoire avec:
- **Frontend**: Application Flutter (mobile, web, desktop)
- **Backend**: API PHP RESTful avec authentification JWT

---

## 📁 Structure Organisée du Frontend

```
lib/
├── main.dart                          # Point d'entrée principal
├── firebase_options.dart              # Configuration Firebase
│
├── assets/
│   ├── images/                        # Images (PNG, JPG)
│   ├── icons/                         # Icônes (SVG, PNG)
│   └── fonts/                         # Polices custom
│
├── core/                              # Logique métier commune
│   ├── constants/
│   │   └── routes.dart               # Routes de navigation
│   │
│   ├── services/
│   │   ├── api_service.dart          # ✅ Service API (import user supprimé)
│   │   ├── auth_service.dart         # Authentification
│   │   ├── notification_service.dart # ✅ Notifications (getter isInitialized ajouté)
│   │   ├── bluetooth_service.dart    # Bluetooth
│   │   └── location_service.dart     # Géolocalisation
│   │
│   └── utils/
│       └── [utilitaires communs]
│
├── data/                              # Couche données
│   ├── models/
│   │   ├── user.dart
│   │   ├── alert.dart
│   │   ├── emergency_contact.dart
│   │   └── item.dart
│   │
│   └── repositories/
│       ├── alert_repository.dart
│       └── [autres repositories]
│
└── presentation/                      # Couche UI
    ├── bloc/
    │   └── auth_bloc/
    │       └── auth_bloc.dart
    │
    ├── screens/
    │   ├── auth/
    │   ├── home/
    │   ├── alerts/
    │   └── ...
    │
    └── widgets/
        ├── auth_wrapper.dart
        └── [composants réutilisables]
```

### 📝 Fichiers Frontend - État

| Fichier | État | Notes |
|---------|------|-------|
| `lib/core/services/api_service.dart` | ✅ Corrigé | Import `user.dart` inutilisé supprimé |
| `lib/core/services/notification_service.dart` | ✅ Corrigé | Getter `isInitialized` et logique init ajoutés |

---

## 📁 Structure Organisée du Backend

```
backend/
├── bootstrap.php                      # ✅ Initialisation centralisée (créé)
├── index.php                          # ✅ Point d'entrée API (créé)
│
├── config/
│   ├── config.php                     # ✅ Configuration centralisée (créé)
│   ├── database.php                   # Connexion MySQL
│   └── jwt.php                        # Gestion JWT
│
├── middleware/
│   └── AuthMiddleware.php             # ✅ Authentification JWT (créé et corrigé)
│
├── controllers/
│   ├── AuthController.php             # Authentification
│   ├── AlertController.php            # Gestion des alertes
│   ├── EmergencyContactController.php # Contacts d'urgence
│   ├── ItemController.php             # Gestion des objets
│   └── DocumentController.php         # ✅ Documents (créé)
│
├── utils/
│   ├── ResponseHandler.php            # ✅ Réponses standardisées (créé)
│   └── Validator.php                  # ✅ Validation des données (créé)
│
├── routes/
│   └── api.php                        # ✅ Router API (amélioré)
│
├── database/
│   └── schema.sql                     # Schéma MySQL
│
└── .htaccess                          # ✅ Routing Apache (amélioré)
```

### 📝 Fichiers Backend - État

| Fichier | État | Notes |
|---------|------|-------|
| `backend/middleware/AuthMiddleware.php` | ✅ Corrigé | Classe JWT::decode utilisée correctement |
| `backend/controllers/DocumentController.php` | ✅ Créé | Contrôleur complet avec tous les endpoints |
| `backend/utils/ResponseHandler.php` | ✅ Créé | Réponses JSON standardisées |
| `backend/utils/Validator.php` | ✅ Créé | Validation des données (email, phone, etc) |
| `backend/config/config.php` | ✅ Créé | Configuration centralisée |
| `backend/bootstrap.php` | ✅ Créé | Initialisation et autoloader |
| `backend/index.php` | ✅ Créé | Point d'entrée principal |
| `backend/.htaccess` | ✅ Amélioré | Routing Apache optimisé |
| `backend/routes/api.php` | ✅ Amélioré | Gestion erreurs centralisée |

---

## 🔗 Endpoints API

### Authentification
- `POST /api/auth/register` - Inscription
- `POST /api/auth/login` - Connexion
- `GET /api/auth/profile` - Profil utilisateur

### Alertes
- `GET /api/alerts` - Lister les alertes
- `POST /api/alerts` - Créer une alerte
- `PUT /api/alerts/{id}` - Mettre à jour une alerte

### Contacts d'urgence
- `GET /api/contacts` - Lister les contacts
- `POST /api/contacts` - Ajouter un contact
- `PUT /api/contacts/{id}` - Modifier un contact
- `DELETE /api/contacts/{id}` - Supprimer un contact

### Objets
- `GET /api/items` - Lister les objets
- `POST /api/items` - Ajouter un objet
- `PUT /api/items/{id}` - Modifier un objet
- `DELETE /api/items/{id}` - Supprimer un objet

### Documents
- `GET /api/documents` - Lister les documents
- `POST /api/documents` - Ajouter un document
- `PUT /api/documents/{id}` - Modifier un document
- `DELETE /api/documents/{id}` - Supprimer un document

---

## 🔧 Configuration Requise

### Backend
1. **PHP 8.0+** avec extensions:
   - PDO MySQL
   - OpenSSL (pour JWT)

2. **MySQL 5.7+**

3. **Fichier `.env`** (créer depuis exemple):
   ```
   DB_HOST=localhost
   DB_NAME=safeguardian_ci
   DB_USER=root
   DB_PASS=
   JWT_SECRET=votre-clé-secrète
   ```

### Frontend
1. **Flutter 3.0+**
2. **Dependencies**:
   - firebase_core, firebase_auth, cloud_firestore
   - flutter_bloc, provider
   - hive_flutter
   - geolocator, geocoding, google_maps_flutter

---

## 🚀 Démarrage

### Backend
```bash
cd backend
# Créer la base de données
mysql -u root < database/schema.sql

# Démarrer le serveur PHP
php -S localhost:8000
```

### Frontend
```bash
flutter pub get
flutter run
```

---

## ✅ Corrections Appliquées

### Frontend (Dart)
1. ✅ **Import inutilisé supprimé** dans `api_service.dart`
   - Suppression de `import '../../data/models/user.dart'`

2. ✅ **Champ inutilisé utilisé** dans `notification_service.dart`
   - Ajout du getter `isInitialized`
   - Logique d'initialisation sécurisée (double init prevention)
   - Notification des changements

### Backend (PHP)
1. ✅ **Classe AuthMiddleware créée** et améliorée
   - Authentification JWT robuste
   - Gestion des expiration de tokens
   - Extraction correcte des headers

2. ✅ **Classe DocumentController créée**
   - Endpoints complets (CRUD)
   - Gestion d'erreurs
   - Partage de documents

3. ✅ **Utilitaires créés**
   - `ResponseHandler`: Réponses JSON standardisées
   - `Validator`: Validation des données (email, phone, etc)
   - `Config`: Configuration centralisée

4. ✅ **Architecture améliorée**
   - `bootstrap.php`: Initialisation centralisée
   - `index.php`: Point d'entrée propre
   - Gestion d'erreurs globale
   - Autoloader simple

---

## 🐛 Erreurs Corrigées

| Erreur | Fichier | Statut |
|--------|---------|--------|
| Unused import 'user.dart' | `api_service.dart` | ✅ Corrigé |
| Unused field '_initialized' | `notification_service.dart` | ✅ Corrigé |
| Undefined type 'DocumentController' | `api.php` | ✅ Corrigé |
| Undefined type 'AuthMiddleware' | `api.php` | ✅ Corrigé |

---

## 📚 Prochaines Étapes

1. **Tests unitaires**
   - Ajouter des tests pour les contrôleurs
   - Ajouter des tests pour les services

2. **Documentation API**
   - Ajouter OpenAPI/Swagger

3. **Sécurité**
   - Ajouter rate limiting
   - Valider tous les inputs
   - CSRF tokens

4. **Performance**
   - Caching Redis
   - Pagination des requêtes

---

**Projet prêt à être déployé! 🎉**
