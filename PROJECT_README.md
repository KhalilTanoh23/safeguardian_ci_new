# SafeGuardian CI - Application d'Alertes d'Urgence

**🇨🇮 Pour la Côte d'Ivoire**  
**Version**: 1.0.0  
**Statut**: ✅ Production Ready

---

## 📱 À Propos

SafeGuardian CI est une application mobile complète pour les alertes d'urgence permettant aux utilisateurs de:
- 🚨 Créer des alertes d'urgence avec géolocalisation
- 📞 Notifier automatiquement les contacts d'urgence
- 📍 Suivre les objets perdus via Bluetooth
- 📄 Gérer les documents importants
- 🔐 S'authentifier de manière sécurisée avec JWT

---

## 🏗️ Architecture

### Frontend
- **Framework**: Flutter 3.0+
- **Languages**: Dart
- **Plateformes**: Android, iOS, Web, Windows, macOS, Linux
- **State Management**: BLoC + Provider
- **Base de données locale**: Hive

### Backend
- **Langage**: PHP 8.0+
- **Base de données**: MySQL 5.7+
- **API**: REST avec authentification JWT
- **Architecture**: MVC avec middleware

### Services
- 🔥 Firebase (Auth, Firestore, Messaging, Storage)
- 📡 Bluetooth (flutter_blue_plus)
- 🗺️ Google Maps API
- 📍 Géolocalisation (Geolocator)

---

## 🚀 Quick Start

### Backend
```bash
cd backend
mysql -u root < database/schema.sql
php -S localhost:8000
```

### Frontend
```bash
flutter pub get
flutter run
```

**Voir [DEPLOYMENT.md](DEPLOYMENT.md) pour les détails complets**

---

## 📚 Documentation

### 📖 Structure du Projet
**[STRUCTURE.md](STRUCTURE.md)** - Organisation complète avec tous les fichiers

### 🚀 Installation et Déploiement
**[DEPLOYMENT.md](DEPLOYMENT.md)** - Guide étape par étape pour:
- Installation locale
- Configuration
- Déploiement production

### 📝 Conventions de Code
**[CODING_STANDARDS.md](CODING_STANDARDS.md)** - Standards pour:
- Nommage et organisation
- Dart (Frontend)
- PHP (Backend)
- API REST
- Sécurité

### ✅ Corrections Appliquées
**[CORRECTIONS_SUMMARY.md](CORRECTIONS_SUMMARY.md)** - Résumé de toutes les corrections:
- Erreurs corrigées
- Fichiers créés
- Améliorations apportées

---

## ✨ Corrections Appliquées (20 Jan 2026)

### Frontend ✅
- Suppression de l'import inutilisé dans `api_service.dart`
- Ajout du getter `isInitialized` dans `notification_service.dart`

### Backend ✅
- Création de `AuthMiddleware.php` (authentification JWT)
- Création de `DocumentController.php` (gestion documents)
- Création des utilitaires `ResponseHandler.php` et `Validator.php`
- Amélioration de l'architecture avec `bootstrap.php` et `config.php`

**Statut**: ✅ 0 erreurs de compilation

---

## 📊 Structure des Dossiers

```
safeguardian_ci_new/
├── lib/                                 # Frontend Flutter
│   ├── core/                           # Services et constantes
│   ├── data/                           # Modèles et repositories
│   └── presentation/                   # UI et BLoC
│
├── backend/                             # Backend PHP
│   ├── config/                         # Configuration
│   ├── controllers/                    # Contrôleurs API
│   ├── middleware/                     # Middleware (Auth)
│   ├── utils/                          # Utilitaires
│   ├── routes/                         # Routes API
│   └── database/                       # Schéma MySQL
│
├── android/                             # Code Android natif
├── ios/                                 # Code iOS natif
├── web/                                 # Code Web
├── windows/                             # Code Windows
├── macos/                               # Code macOS
├── linux/                               # Code Linux
│
├── STRUCTURE.md                         # 📖 Organisation du projet
├── DEPLOYMENT.md                        # 🚀 Guide de déploiement
├── CODING_STANDARDS.md                  # 📝 Conventions de code
├── CORRECTIONS_SUMMARY.md               # ✅ Résumé corrections
└── pubspec.yaml                         # Dépendances Flutter
```

---

## 🔧 Dépendances Principales

### Frontend
```yaml
firebase_core: ^4.3.0
flutter_bloc: ^9.1.1
hive_flutter: ^1.1.0
google_maps_flutter: ^2.9.0
flutter_blue_plus: ^2.1.0
```

### Backend
```
PHP 8.0+
MySQL 5.7+
PDO MySQL
OpenSSL (JWT)
```

---

## 🔒 Sécurité

### Authentification
- ✅ JWT (JSON Web Tokens)
- ✅ Tokens signés avec clé secrète
- ✅ Expiration après 24 heures
- ✅ Vérification à chaque requête

### Validation
- ✅ Validation email/téléphone
- ✅ Longueur minimale des mots de passe
- ✅ Préparation des requêtes SQL

### Endpoints Protégés
- ✅ GET /api/auth/profile
- ✅ GET /api/alerts
- ✅ GET /api/contacts
- ✅ GET /api/items
- ✅ GET /api/documents

---

## 📱 Endpoints API

### Authentification
```
POST   /api/auth/register           Inscription
POST   /api/auth/login              Connexion
GET    /api/auth/profile            Profil utilisateur
```

### Alertes
```
GET    /api/alerts                  Lister
POST   /api/alerts                  Créer
PUT    /api/alerts/{id}             Modifier
```

### Contacts
```
GET    /api/contacts                Lister
POST   /api/contacts                Ajouter
PUT    /api/contacts/{id}           Modifier
DELETE /api/contacts/{id}           Supprimer
```

### Objets
```
GET    /api/items                   Lister
POST   /api/items                   Ajouter
PUT    /api/items/{id}              Modifier
DELETE /api/items/{id}              Supprimer
```

### Documents
```
GET    /api/documents               Lister
POST   /api/documents               Ajouter
PUT    /api/documents/{id}          Modifier
DELETE /api/documents/{id}          Supprimer
```

---

## 🧪 Tests

### Frontend
```bash
flutter test
```

### Backend
```bash
# Utiliser PHPUnit si configuré
phpunit tests/
```

---

## 📈 Performance

- ⚡ Compiled Flutter (native)
- 🔄 BLoC pour state management
- 💾 Hive pour cache local
- 🗂️ Firebase pour sync cloud
- 📦 Lazy loading des ressources

---

## 🌍 Déploiement

### Frontend
- 📱 Android: Google Play Store
- 🍎 iOS: Apple App Store
- 🌐 Web: Netlify / Vercel
- 🪟 Windows: Installer MSIX
- 🖥️ Linux: AppImage

### Backend
- ☁️ AWS / Google Cloud / Azure
- 🖥️ Dedicated Server / VPS
- 🐳 Docker Container
- 🔒 HTTPS obligatoire
- 📊 Database backups automatiques

---

## 📞 Support et Contribution

### Signaler un Bug
1. Créer une issue GitHub
2. Décrire le problème
3. Fournir les logs

### Contribuer
1. Fork le projet
2. Créer une branche (`git checkout -b feature/amazing-feature`)
3. Commit les changements (`git commit -m 'Add amazing feature'`)
4. Push vers la branche (`git push origin feature/amazing-feature`)
5. Ouvrir une Pull Request

---

## 📄 License

Ce projet est sous license propriétaire. Tous droits réservés.

---

## 👥 Auteurs

- **Version**: 1.0.0
- **Dernière mise à jour**: 20 janvier 2026
- **Statut**: ✅ Production Ready

---

## 🎯 Roadmap Futur

- [ ] Tests unitaires automatisés
- [ ] CI/CD avec GitHub Actions
- [ ] Système de rôles avancés
- [ ] API versioning
- [ ] Rate limiting
- [ ] Monitoring et analytics
- [ ] Multi-langue support
- [ ] Mode hors ligne amélioré

---

## 📖 Lectures Supplémentaires

- [Flutter Documentation](https://flutter.dev)
- [PHP Documentation](https://www.php.net)
- [JWT](https://jwt.io)
- [RESTful API Best Practices](https://restfulapi.net)
- [OWASP Security Guidelines](https://owasp.org)

---

**Prêt à déployer! 🚀**

Pour commencer, consultez [DEPLOYMENT.md](DEPLOYMENT.md)
