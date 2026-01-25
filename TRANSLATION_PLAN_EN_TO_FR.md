# Plan de Traduction Complet: English → French
## SafeGuardian CI - Application Flutter

**Date**: 21 janvier 2026
**Projet**: SafeGuardian CI (Application de sécurité personnelle)
**Portée**: Traduction complète de l'anglais vers le français
**Approche**: Traduction système (fichiers, dossiers, classes, variables, constantes, commentaires)

---

## 📋 TABLE DES MATIÈRES

1. [Résumé Exécutif](#résumé-exécutif)
2. [Architecture du Projet](#architecture-du-projet)
3. [Renommage des Répertoires](#renommage-des-répertoires)
4. [Traduction des Fichiers](#traduction-des-fichiers)
5. [Traduction des Classes et Énumérations](#traduction-des-classes-et-énumérations)
6. [Traduction des Fonctions et Méthodes](#traduction-des-fonctions-et-méthodes)
7. [Traduction des Constantes et Routes](#traduction-des-constantes-et-routes)
8. [Chaînes Utilisateur (UI/UX)](#chaînes-utilisateur)
9. [Commentaires et Documentation](#commentaires-et-documentation)
10. [Chronologie de Mise en Œuvre](#chronologie-de-mise-en-œuvre)

---

## 🎯 Résumé Exécutif

### Statistiques du Projet
- **Répertoires principaux**: 17
- **Répertoires secondaires**: 45+
- **Fichiers Dart**: 70+
- **Fichiers de ressources**: 3 répertoires (fonts, icons, images)
- **Fichiers de configuration**: 3 (pubspec.yaml, analysis_options.yaml, devtools_options.yaml)

### Complexité de Traduction
- **Très Élevée**: 25 éléments critiques
- **Élevée**: 120+ éléments importants
- **Moyenne**: 200+ éléments secondaires
- **Faible**: 500+ commentaires/documentation

### Risque d'Impact
- ⚠️ **CRITIQUE**: Les routes et les imports doivent être mis à jour dans tous les fichiers
- ⚠️ **ÉLEVÉ**: Les noms de classes affectent la sérialisation JSON et les bases de données
- ⚠️ **ÉLEVÉ**: Les noms de variables affectent les références dans tout le code

### Dépendances d'Ordre
1. **Phase 1**: Traduction des répertoires principaux
2. **Phase 2**: Traduction des noms de fichiers
3. **Phase 3**: Traduction des imports et chemins
4. **Phase 4**: Traduction des classes, énumérations, variables
5. **Phase 5**: Traduction des constantes et routes
6. **Phase 6**: Traduction des chaînes UI/UX
7. **Phase 7**: Traduction des commentaires

---

## 🏗️ Architecture du Projet

```
lib/
├── assets/                  → ressources/
│   ├── fonts/
│   ├── icons/
│   └── images/
├── core/                    → noyau/
│   ├── config/             → configuration/
│   ├── constants/          → constantes/
│   ├── mixins/             → mélanges/
│   ├── services/           → services/
│   ├── theme/              → thème/
│   └── utils/              → utilitaires/
├── data/                    → données/
│   ├── models/             → modèles/
│   └── repositories/       → dépôts/
├── presentation/            → présentation/
│   ├── bloc/               → bloc/ (keep as-is - BLoC pattern convention)
│   ├── screens/            → écrans/
│   ├── theme/              → thème/
│   └── widgets/            → widgets/ (keep as-is - Flutter convention)
├── firebase_options.dart
└── main.dart
```

---

## 📂 RENOMMAGE DES RÉPERTOIRES

### Répertoires Principaux de lib/

| # | Chemin Actuel | Nouveau Chemin | Priorité | Notes |
|---|---|---|---|---|
| 1 | `lib/assets/` | `lib/ressources/` | **HAUTE** | Contient fonts, icons, images |
| 2 | `lib/assets/fonts/` | `lib/ressources/polices/` | HAUTE | Polices typographiques |
| 3 | `lib/assets/icons/` | `lib/ressources/icones/` | HAUTE | Icônes de l'application |
| 4 | `lib/assets/images/` | `lib/ressources/images/` | HAUTE | Images et médias |
| 5 | `lib/core/` | `lib/noyau/` | **HAUTE** | Code fondamental |
| 6 | `lib/core/config/` | `lib/noyau/configuration/` | HAUTE | Configuration d'application |
| 7 | `lib/core/constants/` | `lib/noyau/constantes/` | **HAUTE** | Constantes globales |
| 8 | `lib/core/mixins/` | `lib/noyau/mélanges/` | MOYENNE | Mixins Dart |
| 9 | `lib/core/services/` | `lib/noyau/services/` | **HAUTE** | Services métier |
| 10 | `lib/core/theme/` | `lib/noyau/thème/` | MOYENNE | Thème visuel |
| 11 | `lib/core/utils/` | `lib/noyau/utilitaires/` | MOYENNE | Fonctions utilitaires |
| 12 | `lib/data/` | `lib/donnees/` | **HAUTE** | Couche données |
| 13 | `lib/data/models/` | `lib/donnees/modeles/` | **HAUTE** | Modèles de données |
| 14 | `lib/data/repositories/` | `lib/donnees/depots/` | **HAUTE** | Dépôts de données |
| 15 | `lib/presentation/` | `lib/presentation/` | **HAUTE** | Couche présentation (garder) |
| 16 | `lib/presentation/bloc/` | `lib/presentation/bloc/` | MOYENNE | BLoC (convention standard Flutter) |
| 17 | `lib/presentation/screens/` | `lib/presentation/ecrans/` | **HAUTE** | Écrans (pages) |
| 18 | `lib/presentation/theme/` | `lib/presentation/theme/` | MOYENNE | Thème (garder pour clarté) |
| 19 | `lib/presentation/widgets/` | `lib/presentation/widgets/` | MOYENNE | Widgets (convention standard Flutter) |

### Sous-répertoires des Écrans

| # | Chemin Actuel | Nouveau Chemin | Priorité | Notes |
|---|---|---|---|---|
| 20 | `lib/presentation/screens/admin/` | `lib/presentation/ecrans/administration/` | HAUTE | Écran d'administration |
| 21 | `lib/presentation/screens/auth/` | `lib/presentation/ecrans/authentification/` | **HAUTE** | Authentification (critique) |
| 22 | `lib/presentation/screens/community/` | `lib/presentation/ecrans/communaute/` | MOYENNE | Communauté |
| 23 | `lib/presentation/screens/contacts/` | `lib/presentation/ecrans/contacts/` | **HAUTE** | Gestion des contacts |
| 24 | `lib/presentation/screens/dashboard/` | `lib/presentation/ecrans/tableau_de_bord/` | **HAUTE** | Tableau de bord principal |
| 25 | `lib/presentation/screens/device/` | `lib/presentation/ecrans/appareil/` | HAUTE | Gestion des appareils |
| 26 | `lib/presentation/screens/documents/` | `lib/presentation/ecrans/documents/` | MOYENNE | Gestion des documents |
| 27 | `lib/presentation/screens/emergency/` | `lib/presentation/ecrans/urgence/` | **HAUTE** | Gestion des urgences |
| 28 | `lib/presentation/screens/items/` | `lib/presentation/ecrans/articles/` | MOYENNE | Gestion des articles/objets |
| 29 | `lib/presentation/screens/main/` | `lib/presentation/ecrans/principal/` | HAUTE | Écrans principaux (splash, etc) |
| 30 | `lib/presentation/screens/onboarding/` | `lib/presentation/ecrans/onboarding/` | HAUTE | Onboarding (garder si commun) |
| 31 | `lib/presentation/screens/profile/` | `lib/presentation/ecrans/profil/` | MOYENNE | Profil utilisateur |
| 32 | `lib/presentation/screens/settings/` | `lib/presentation/ecrans/parametres/` | MOYENNE | Paramètres |

### Sous-répertoires des Widgets

| # | Chemin Actuel | Nouveau Chemin | Priorité | Notes |
|---|---|---|---|---|
| 33 | `lib/presentation/widgets/cards/` | `lib/presentation/widgets/cartes/` | MOYENNE | Cartes de contenu |
| 34 | `lib/presentation/widgets/common/` | `lib/presentation/widgets/commun/` | MOYENNE | Widgets communs |
| 35 | `lib/presentation/widgets/dialogs/` | `lib/presentation/widgets/dialogues/` | MOYENNE | Boîtes de dialogue |
| 36 | `lib/presentation/widgets/responsive/` | `lib/presentation/widgets/reactif/` | MOYENNE | Widgets réactifs |

### Sous-répertoires des BLoCs

| # | Chemin Actuel | Nouveau Chemin | Priorité | Notes |
|---|---|---|---|---|
| 37 | `lib/presentation/bloc/auth_bloc/` | `lib/presentation/bloc/bloc_authentification/` | **HAUTE** | Bloc authentification |
| 38 | `lib/presentation/bloc/device_bloc/` | `lib/presentation/bloc/bloc_appareil/` | HAUTE | Bloc appareil |
| 39 | `lib/presentation/bloc/emergency_bloc/` | `lib/presentation/bloc/bloc_urgence/` | **HAUTE** | Bloc urgence |
| 40 | `lib/presentation/bloc/items_bloc/` | `lib/presentation/bloc/bloc_articles/` | MOYENNE | Bloc articles |

---

## 📄 TRADUCTION DES FICHIERS

### Phase 1: Fichiers Racine

| # | Fichier Actuel | Nouveau Fichier | Priorité | Type | Notes |
|---|---|---|---|---|---|
| 1 | `lib/main.dart` | `lib/principal.dart` | **HAUTE** | Entry Point | Renommer fichier + classe interne |
| 2 | `lib/firebase_options.dart` | `lib/options_firebase.dart` | HAUTE | Configuration | Firebase config |

### Phase 2: Fichiers Core (noyau/)

| # | Fichier Actuel | Nouveau Fichier | Priorité | Type | Notes |
|---|---|---|---|---|---|
| 3 | `core/config/responsive_config.dart` | `noyau/configuration/configuration_reactif.dart` | MOYENNE | Config | Configuration réactive |
| 4 | `core/constants/app_constants.dart` | `noyau/constantes/constantes_application.dart` | **HAUTE** | Constantes | Constantes générales |
| 5 | `core/constants/routes.dart` | `noyau/constantes/routes.dart` | **HAUTE** | Routes | ⚠️ Garder nom (référence partout) |
| 6 | `core/services/api_service.dart` | `noyau/services/service_api.dart` | HAUTE | Service | Service API REST |
| 7 | `core/services/auth_service.dart` | `noyau/services/service_authentification.dart` | **HAUTE** | Service | Service d'authentification |
| 8 | `core/services/bluetooth_service.dart` | `noyau/services/service_bluetooth.dart` | HAUTE | Service | Service Bluetooth |
| 9 | `core/services/location_service.dart` | `noyau/services/service_localisation.dart` | HAUTE | Service | Service de géolocalisation |
| 10 | `core/services/notification_service.dart` | `noyau/services/service_notifications.dart` | HAUTE | Service | Service de notifications |
| 11 | `core/utils/responsive_helper.dart` | `noyau/utilitaires/aide_reactif.dart` | MOYENNE | Utilitaire | Fonctions réactives |
| 12 | `core/utils/responsive_exports.dart` | `noyau/utilitaires/exports_reactifs.dart` | MOYENNE | Utilitaire | Exports réactifs |

### Phase 3: Fichiers Data (donnees/)

| # | Fichier Actuel | Nouveau Fichier | Priorité | Type | Notes |
|---|---|---|---|---|---|
| 13 | `data/models/alert.dart` | `donnees/modeles/alerte.dart` | **HAUTE** | Modèle | Modèle d'alerte |
| 14 | `data/models/contact.dart` | `donnees/modeles/contact.dart` | **HAUTE** | Modèle | Modèle contact (garder) |
| 15 | `data/models/device.dart` | `donnees/modeles/appareil.dart` | HAUTE | Modèle | Modèle d'appareil |
| 16 | `data/models/document.dart` | `donnees/modeles/document.dart` | MOYENNE | Modèle | Modèle document (garder) |
| 17 | `data/models/emergency_contact.dart` | `donnees/modeles/contact_urgence.dart` | **HAUTE** | Modèle | Contact d'urgence |
| 18 | `data/models/item.dart` | `donnees/modeles/article.dart` | MOYENNE | Modèle | Modèle article |
| 19 | `data/models/user.dart` | `donnees/modeles/utilisateur.dart` | **HAUTE** | Modèle | Modèle utilisateur |
| 20 | `data/repositories/alert_repository.dart` | `donnees/depots/depot_alerte.dart` | **HAUTE** | Dépôt | Dépôt d'alertes |
| 21 | `data/repositories/contact_repository.dart` | `donnees/depots/depot_contact.dart` | HAUTE | Dépôt | Dépôt des contacts |

### Phase 4: Fichiers Screens (ecrans/)

#### Authentification
| # | Fichier Actuel | Nouveau Fichier | Priorité | Notes |
|---|---|---|---|---|
| 22 | `screens/auth/login_screen.dart` | `ecrans/authentification/ecran_connexion.dart` | **HAUTE** | Écran de connexion |
| 23 | `screens/auth/register_screen.dart` | `ecrans/authentification/ecran_inscription.dart` | **HAUTE** | Écran d'inscription |

#### Tableau de Bord
| # | Fichier Actuel | Nouveau Fichier | Priorité | Notes |
|---|---|---|---|---|
| 24 | `screens/dashboard/dashboard_screen.dart` | `ecrans/tableau_de_bord/ecran_tableau_de_bord.dart` | **HAUTE** | Tableau principal |

#### Urgence
| # | Fichier Actuel | Nouveau Fichier | Priorité | Notes |
|---|---|---|---|---|
| 25 | `screens/emergency/emergency_screen.dart` | `ecrans/urgence/ecran_urgence.dart` | **HAUTE** | Urgence |
| 26 | `screens/emergency/alert_map_screen.dart` | `ecrans/urgence/ecran_carte_alerte.dart` | HAUTE | Carte alertes |
| 27 | `screens/emergency/alert_history_screen.dart` | `ecrans/urgence/ecran_historique_alerte.dart` | HAUTE | Historique |

#### Contacts
| # | Fichier Actuel | Nouveau Fichier | Priorité | Notes |
|---|---|---|---|---|
| 28 | `screens/contacts/contacts_screen.dart` | `ecrans/contacts/ecran_contacts.dart` | HAUTE | Liste contacts |
| 29 | `screens/contacts/add_contact_screen.dart` | `ecrans/contacts/ecran_ajouter_contact.dart` | HAUTE | Ajouter contact |

#### Articles
| # | Fichier Actuel | Nouveau Fichier | Priorité | Notes |
|---|---|---|---|---|
| 30 | `screens/items/items_screen.dart` | `ecrans/articles/ecran_articles.dart` | MOYENNE | Liste articles |
| 31 | `screens/items/add_item_screen.dart` | `ecrans/articles/ecran_ajouter_article.dart` | MOYENNE | Ajouter article |
| 32 | `screens/items/lost_found_screen.dart` | `ecrans/articles/ecran_perdu_trouve.dart` | MOYENNE | Perdu/Trouvé |

#### Documents
| # | Fichier Actuel | Nouveau Fichier | Priorité | Notes |
|---|---|---|---|---|
| 33 | `screens/documents/documents_screen.dart` | `ecrans/documents/ecran_documents.dart` | MOYENNE | Documents |
| 34 | `screens/documents/add_document_screen.dart` | `ecrans/documents/ecran_ajouter_document.dart` | MOYENNE | Ajouter document |

#### Appareils
| # | Fichier Actuel | Nouveau Fichier | Priorité | Notes |
|---|---|---|---|---|
| 35 | `screens/device/pair_device_screen.dart` | `ecrans/appareil/ecran_appairer_appareil.dart` | HAUTE | Appairer |
| 36 | `screens/device/device_settings_screen.dart` | `ecrans/appareil/ecran_parametres_appareil.dart` | HAUTE | Paramètres |

#### Autres Écrans
| # | Fichier Actuel | Nouveau Fichier | Priorité | Notes |
|---|---|---|---|---|
| 37 | `screens/admin/admin_dashboard.dart` | `ecrans/administration/tableau_de_bord_admin.dart` | MOYENNE | Admin |
| 38 | `screens/community/community_alerts_screen.dart` | `ecrans/communaute/ecran_alertes_communaute.dart` | MOYENNE | Alertes communauté |
| 39 | `screens/community/help_center_screen.dart` | `ecrans/communaute/ecran_centre_aide.dart` | MOYENNE | Centre d'aide |
| 40 | `screens/profile/profile_screen.dart` | `ecrans/profil/ecran_profil.dart` | MOYENNE | Profil |
| 41 | `screens/settings/settings_screen.dart` | `ecrans/parametres/ecran_parametres.dart` | MOYENNE | Paramètres |
| 42 | `screens/main/splash_screen.dart` | `ecrans/principal/ecran_demarrage.dart` | HAUTE | Splash screen |
| 43 | `screens/main/qr_scanner_screen.dart` | `ecrans/principal/ecran_lecteur_qr.dart` | HAUTE | Scanner QR |
| 44 | `screens/onboarding/onboarding_screen.dart` | `ecrans/onboarding/ecran_onboarding.dart` | MOYENNE | Onboarding (garder nom?) |

### Phase 5: Fichiers Widgets

#### Cartes (Cards)
| # | Fichier Actuel | Nouveau Fichier | Priorité | Notes |
|---|---|---|---|---|
| 45 | `widgets/cards/alert_card.dart` | `widgets/cartes/carte_alerte.dart` | MOYENNE | Carte alerte |
| 46 | `widgets/cards/contact_card.dart` | `widgets/cartes/carte_contact.dart` | MOYENNE | Carte contact |
| 47 | `widgets/cards/item_card.dart` | `widgets/cartes/carte_article.dart` | MOYENNE | Carte article |

#### Widgets Communs
| # | Fichier Actuel | Nouveau Fichier | Priorité | Notes |
|---|---|---|---|---|
| 48 | `widgets/common/emergency_button.dart` | `widgets/commun/bouton_urgence.dart` | **HAUTE** | Bouton urgence |

#### Dialogues
| # | Fichier Actuel | Nouveau Fichier | Priorité | Notes |
|---|---|---|---|---|
| 49 | `widgets/dialogs/emergency_dialog.dart` | `widgets/dialogues/dialogue_urgence.dart` | **HAUTE** | Dialogue urgence |

#### Widgets Généraux
| # | Fichier Actuel | Nouveau Fichier | Priorité | Notes |
|---|---|---|---|---|
| 50 | `widgets/auth_wrapper.dart` | `widgets/enveloppe_auth.dart` | **HAUTE** | Wrapper auth |
| 51 | `widgets/custom_hamburger_menu.dart` | `widgets/menu_hamburger_personnalise.dart` | MOYENNE | Menu hamburger |

### Phase 6: Fichiers BLoCs

| # | Fichier Actuel | Nouveau Fichier | Priorité | Notes |
|---|---|---|---|---|
| 52 | `bloc/auth_bloc/auth_bloc.dart` | `bloc/bloc_authentification/bloc_authentification.dart` | **HAUTE** | Bloc auth |
| 53 | `bloc/emergency_bloc/emergency_bloc.dart` | `bloc/bloc_urgence/bloc_urgence.dart` | **HAUTE** | Bloc urgence |

---

## 🏛️ TRADUCTION DES CLASSES ET ÉNUMÉRATIONS

### Énumérations (Enums)

| # | Nom Actuel | Nouveau Nom | Fichier | Priorité | Notes |
|---|---|---|---|---|---|
| 1 | `AlertStatus` | `StatutAlerte` | alert.dart | **HAUTE** | Énumération du statut d'alerte |
| 2 | `UserRole` | `RoleUtilisateur` | user.dart | **HAUTE** | Rôles utilisateur |
| 3 | `UserStatus` | `StatutUtilisateur` | user.dart | **HAUTE** | Statut utilisateur |
| 4 | `DeviceStatus` | `StatutAppareil` | device.dart | HAUTE | Statut de l'appareil |
| 5 | `DocumentType` | `TypeDocument` | document.dart | MOYENNE | Types de documents |
| 6 | `ItemCategory` | `CategorieArticle` | item.dart | MOYENNE | Catégories d'articles |

### Classes Principales (Modèles)

| # | Nom Actuel | Nouveau Nom | Fichier | Priorité | Notes |
|---|---|---|---|---|---|
| 1 | `User` | `Utilisateur` | user.dart | **HAUTE** | Modèle utilisateur principal |
| 2 | `UserSettings` | `ParametresUtilisateur` | user.dart | HAUTE | Paramètres utilisateur |
| 3 | `EmergencyInfo` | `InfoUrgence` | user.dart | HAUTE | Informations d'urgence |
| 4 | `Contact` | `Contact` | contact.dart | HAUTE | Garder (très utilisé) |
| 5 | `EmergencyContact` | `ContactUrgence` | emergency_contact.dart | **HAUTE** | Contact d'urgence |
| 6 | `EmergencyAlert` | `AlerteUrgence` | alert.dart | **HAUTE** | Alerte d'urgence |
| 7 | `AlertResponse` | `ReponseAlerte` | alert.dart | HAUTE | Réponse à alerte |
| 8 | `BraceletDevice` | `AppareillBracelet` | device.dart | HAUTE | Appareil bracelet |
| 9 | `DeviceSettings` | `ParametresAppareil` | device.dart | HAUTE | Paramètres appareil |
| 10 | `DeviceEvent` | `EvenementAppareil` | device.dart | MOYENNE | Événement appareil |
| 11 | `Document` | `Document` | document.dart | MOYENNE | Garder (très utilisé) |
| 12 | `Item` | `Article` | item.dart | MOYENNE | Article/Objet |

### Classes des Écrans (Widgets)

| # | Nom Actuel | Nouveau Nom | Fichier | Priorité | Notes |
|---|---|---|---|---|---|
| 1 | `LoginScreen` | `EcranConnexion` | login_screen.dart | **HAUTE** | Écran de connexion |
| 2 | `_LoginScreenState` | `_EtatEcranConnexion` | login_screen.dart | **HAUTE** | État de l'écran |
| 3 | `RegisterScreen` | `EcranInscription` | register_screen.dart | **HAUTE** | Écran d'inscription |
| 4 | `_RegisterScreenState` | `_EtatEcranInscription` | register_screen.dart | **HAUTE** | État inscription |
| 5 | `DashboardScreen` | `EcranTableauDeBord` | dashboard_screen.dart | **HAUTE** | Écran principal |
| 6 | `_DashboardScreenState` | `_EtatTableauDeBord` | dashboard_screen.dart | **HAUTE** | État tableau de bord |
| 7 | `EmergencyScreen` | `EcranUrgence` | emergency_screen.dart | **HAUTE** | Écran urgence |
| 8 | `ContactsScreen` | `EcranContacts` | contacts_screen.dart | HAUTE | Écran contacts |
| 9 | `AddContactScreen` | `EcranAjouterContact` | add_contact_screen.dart | HAUTE | Ajouter contact |
| 10 | `SplashScreen` | `EcranDemarrage` | splash_screen.dart | **HAUTE** | Écran de démarrage |
| 11 | `OnboardingScreen` | `EcranOnboarding` | onboarding_screen.dart | MOYENNE | Onboarding |

### Classes des BLoCs

| # | Nom Actuel | Nouveau Nom | Fichier | Priorité | Notes |
|---|---|---|---|---|---|
| 1 | `AuthEvent` | `EvenementAuth` | auth_bloc.dart | **HAUTE** | Événement base d'auth |
| 2 | `AuthCheckStatus` | `VerifierStatutAuth` | auth_bloc.dart | **HAUTE** | Vérifier le statut |
| 3 | `AuthLoginRequested` | `ConnexionDemandee` | auth_bloc.dart | **HAUTE** | Connexion demandée |
| 4 | `AuthRegisterRequested` | `InscriptionDemandee` | auth_bloc.dart | **HAUTE** | Inscription demandée |
| 5 | `AuthLogoutRequested` | `DeconnexionDemandee` | auth_bloc.dart | **HAUTE** | Déconnexion demandée |
| 6 | `AuthGoogleLoginRequested` | `ConnexionGoogleDemandee` | auth_bloc.dart | HAUTE | Connexion Google |
| 7 | `AuthAppleLoginRequested` | `ConnexionAppleDemandee` | auth_bloc.dart | HAUTE | Connexion Apple |
| 8 | `AuthState` | `EtatAuth` | auth_bloc.dart | **HAUTE** | État base d'auth |
| 9 | `AuthInitial` | `AuthInitial` | auth_bloc.dart | **HAUTE** | État initial (garder?) |
| 10 | `AuthLoading` | `AuthChargement` | auth_bloc.dart | **HAUTE** | Chargement |
| 11 | `AuthAuthenticated` | `AuthAuthentifie` | auth_bloc.dart | **HAUTE** | Authentifié |
| 12 | `AuthUnauthenticated` | `AuthNonAuthentifie` | auth_bloc.dart | **HAUTE** | Non authentifié |
| 13 | `AuthError` | `AuthErreur` | auth_bloc.dart | **HAUTE** | Erreur d'authentification |
| 14 | `AuthBloc` | `BlocAuth` | auth_bloc.dart | **HAUTE** | Bloc d'authentification |

### Classes de Widgets

| # | Nom Actuel | Nouveau Nom | Fichier | Priorité | Notes |
|---|---|---|---|---|---|
| 1 | `AuthWrapper` | `EnveloppeAuth` | auth_wrapper.dart | **HAUTE** | Wrapper d'authentification |
| 2 | `CustomHamburgerMenu` | `MenuHamburgerPersonnalise` | custom_hamburger_menu.dart | MOYENNE | Menu hamburger |
| 3 | `AlertCard` | `CarteAlerte` | alert_card.dart | MOYENNE | Carte d'alerte |
| 4 | `ContactCard` | `CarteContact` | contact_card.dart | MOYENNE | Carte contact |
| 5 | `ItemCard` | `CarteArticle` | item_card.dart | MOYENNE | Carte article |
| 6 | `EmergencyButton` | `BoutonUrgence` | emergency_button.dart | **HAUTE** | Bouton urgence |
| 7 | `EmergencyDialog` | `DialogueUrgence` | emergency_dialog.dart | **HAUTE** | Dialogue urgence |

### Classes de Services

| # | Nom Actuel | Nouveau Nom | Fichier | Priorité | Notes |
|---|---|---|---|---|---|
| 1 | `ApiService` | `ServiceApi` | api_service.dart | HAUTE | Service API |
| 2 | `AuthService` | `ServiceAuthentification` | auth_service.dart | **HAUTE** | Service auth |
| 3 | `BluetoothService` | `ServiceBluetooth` | bluetooth_service.dart | HAUTE | Service Bluetooth |
| 4 | `LocationService` | `ServiceLocalisation` | location_service.dart | HAUTE | Service localisation |
| 5 | `NotificationService` | `ServiceNotifications` | notification_service.dart | HAUTE | Service notifications |

### Classes de Dépôts

| # | Nom Actuel | Nouveau Nom | Fichier | Priorité | Notes |
|---|---|---|---|---|---|
| 1 | `AlertRepository` | `DepotAlerte` | alert_repository.dart | **HAUTE** | Dépôt alertes |
| 2 | `ContactRepository` | `DepotContact` | contact_repository.dart | HAUTE | Dépôt contacts |

---

## ⚙️ TRADUCTION DES FONCTIONS ET MÉTHODES

### Méthodes de Classe Principales

| # | Classe | Méthode Actuelle | Nouvelle Méthode | Priorité | Notes |
|---|---|---|---|---|---|
| 1 | `User` | `get fullName` | `get nomComplet` | MOYENNE | Getter nom complet |
| 2 | `User` | `toJson()` | `versJson()` | MOYENNE | Sérialisation |
| 3 | `User` | `fromJson()` | `depuisJson()` | MOYENNE | Désérialisation |
| 4 | `EmergencyAlert` | `get confirmedContacts` | `get contactsConfirmes` | MOYENNE | Contacts confirmés |
| 5 | `EmergencyAlert` | `get isActive` | `get estActif` | MOYENNE | Vérifie si actif |
| 6 | `EmergencyAlert` | `toJson()` | `versJson()` | MOYENNE | Sérialisation |
| 7 | `EmergencyAlert` | `fromJson()` | `depuisJson()` | MOYENNE | Désérialisation |
| 8 | `BraceletDevice` | `toJson()` | `versJson()` | MOYENNE | Sérialisation |
| 9 | `BraceletDevice` | `fromJson()` | `depuisJson()` | MOYENNE | Désérialisation |

### Méthodes BLoC

| # | Classe | Méthode Actuelle | Nouvelle Méthode | Priorité | Notes |
|---|---|---|---|---|---|
| 1 | `AuthBloc` | `_onAuthCheckStatus` | `_surVerifierStatut` | MOYENNE | Gestionnaire événement |
| 2 | `AuthBloc` | `_onAuthLoginRequested` | `_surConnexionDemandee` | MOYENNE | Gestionnaire connexion |
| 3 | `AuthBloc` | `_onAuthRegisterRequested` | `_surInscriptionDemandee` | MOYENNE | Gestionnaire inscription |
| 4 | `AuthBloc` | `_onAuthLogoutRequested` | `_surDeconnexionDemandee` | MOYENNE | Gestionnaire déconnexion |

### Fonctions Globales (Utilitaires)

| # | Fonction Actuelle | Nouvelle Fonction | Fichier | Priorité | Notes |
|---|---|---|---|---|---|
| 1 | `getResponsiveValue()` | `obtenirValeurReactive()` | responsive_helper.dart | MOYENNE | Valeur réactive |
| 2 | `buildResponsiveWidget()` | `construireWidgetReactif()` | responsive_helper.dart | MOYENNE | Widget réactif |
| 3 | `calculateScreenSize()` | `calculerTailleEcran()` | responsive_helper.dart | MOYENNE | Taille écran |

---

## 📍 TRADUCTION DES CONSTANTES ET ROUTES

### Routes (AppRoutes)

| # | Route Actuelle | Nouvelle Route | Valeur | Priorité | Notes |
|---|---|---|---|---|---|
| 1 | `AppRoutes.splash` | `RouteApp.demarrage` | `/` | **HAUTE** | Garder valeur |
| 2 | `AppRoutes.authWrapper` | `RouteApp.enveloppeAuth` | `/auth-wrapper` | HAUTE | Garder valeur |
| 3 | `AppRoutes.onboarding` | `RouteApp.onboarding` | `/onboarding` | HAUTE | Garder valeur |
| 4 | `AppRoutes.login` | `RouteApp.connexion` | `/login` | **HAUTE** | Garder valeur |
| 5 | `AppRoutes.register` | `RouteApp.inscription` | `/register` | **HAUTE** | Garder valeur |
| 6 | `AppRoutes.dashboard` | `RouteApp.tableauDeBord` | `/dashboard` | **HAUTE** | Garder valeur |
| 7 | `AppRoutes.emergency` | `RouteApp.urgence` | `/emergency` | **HAUTE** | Garder valeur |
| 8 | `AppRoutes.alertMap` | `RouteApp.carteAlerte` | `/alert-map` | HAUTE | Garder valeur |
| 9 | `AppRoutes.alertHistory` | `RouteApp.historiqueAlerte` | `/alert-history` | HAUTE | Garder valeur |
| 10 | `AppRoutes.contacts` | `RouteApp.contacts` | `/contacts` | HAUTE | Garder valeur |
| 11 | `AppRoutes.addContact` | `RouteApp.ajouterContact` | `/add-contact` | HAUTE | Garder valeur |
| 12 | `AppRoutes.items` | `RouteApp.articles` | `/items` | MOYENNE | Garder valeur |
| 13 | `AppRoutes.addItem` | `RouteApp.ajouterArticle` | `/add-item` | MOYENNE | Garder valeur |
| 14 | `AppRoutes.lostFound` | `RouteApp.perduTrouve` | `/lost-found` | MOYENNE | Garder valeur |
| 15 | `AppRoutes.documents` | `RouteApp.documents` | `/documents` | MOYENNE | Garder valeur |
| 16 | `AppRoutes.addDocument` | `RouteApp.ajouterDocument` | `/add-document` | MOYENNE | Garder valeur |
| 17 | `AppRoutes.pairDevice` | `RouteApp.appairerAppareil` | `/pair-device` | HAUTE | Garder valeur |
| 18 | `AppRoutes.deviceSettings` | `RouteApp.parametresAppareil` | `/device-settings` | HAUTE | Garder valeur |
| 19 | `AppRoutes.communityAlerts` | `RouteApp.alertesCommunaute` | `/community-alerts` | MOYENNE | Garder valeur |
| 20 | `AppRoutes.helpCenter` | `RouteApp.centreAide` | `/help-center` | MOYENNE | Garder valeur |
| 21 | `AppRoutes.admin` | `RouteApp.administration` | `/admin` | MOYENNE | Garder valeur |
| 22 | `AppRoutes.settings` | `RouteApp.parametres` | `/settings` | MOYENNE | Garder valeur |
| 23 | `AppRoutes.profile` | `RouteApp.profil` | `/profile` | MOYENNE | Garder valeur |
| 24 | `AppRoutes.qrScanner` | `RouteApp.lecteurQr` | `/qr-scanner` | HAUTE | Garder valeur |

### Classe AppRoutes (Renommage)

| Élément | Ancien Nom | Nouveau Nom | Priorité |
|---|---|---|---|
| Classe | `AppRoutes` | `RouteApp` | **HAUTE** |
| Constante Statique | `navigatorKey` | `cleNavigateur` | MOYENNE |

### Constantes d'Application (AppConstants)

| # | Constante Actuelle | Nouvelle Constante | Type | Priorité | Notes |
|---|---|---|---|---|---|
| 1 | `API_BASE_URL` | `URL_BASE_API` | String | HAUTE | URL de base API |
| 2 | `FIREBASE_PROJECT_ID` | `ID_PROJET_FIREBASE` | String | HAUTE | ID Firebase |
| 3 | `COMMUNITY_RADIUS_DEFAULT` | `RAYON_COMMUNAUTE_DEFAUT` | int | MOYENNE | Rayon par défaut |
| 4 | `EMERGENCY_TIMEOUT_MINUTES` | `DELAI_URGENCE_MINUTES` | int | MOYENNE | Délai urgence |
| 5 | `MAX_CONTACTS` | `MAX_CONTACTS` | int | MOYENNE | Garder (clair) |
| 6 | `MIN_PASSWORD_LENGTH` | `LONGUEUR_MOT_DE_PASSE_MIN` | int | MOYENNE | Longueur min mot de passe |
| 7 | `LOCATION_PRECISION` | `PRECISION_LOCALISATION` | double | MOYENNE | Précision localisation |

---

## 💬 CHAÎNES UTILISATEUR (UI/UX)

### Textes des Écrans d'Authentification

| # | Texte Actuel | Texte Français | Contexte | Priorité |
|---|---|---|---|---|
| 1 | "Login" | "Connexion" | Titre d'écran | **HAUTE** |
| 2 | "Register" | "S'inscrire" | Titre d'écran | **HAUTE** |
| 3 | "Email" | "Adresse e-mail" | Label input | HAUTE |
| 4 | "Password" | "Mot de passe" | Label input | HAUTE |
| 5 | "Confirm Password" | "Confirmer le mot de passe" | Label input | HAUTE |
| 6 | "Full Name" | "Nom complet" | Label input | HAUTE |
| 7 | "Phone Number" | "Numéro de téléphone" | Label input | HAUTE |
| 8 | "Login with Google" | "Se connecter avec Google" | Bouton | HAUTE |
| 9 | "Login with Apple" | "Se connecter avec Apple" | Bouton | HAUTE |
| 10 | "Don't have an account?" | "Vous n'avez pas de compte?" | Texte suggestion | HAUTE |
| 11 | "Already have an account?" | "Vous avez déjà un compte?" | Texte suggestion | HAUTE |
| 12 | "Forgot Password?" | "Mot de passe oublié?" | Lien | HAUTE |
| 13 | "Sign Up" | "S'inscrire" | Bouton | **HAUTE** |
| 14 | "Sign In" | "Se connecter" | Bouton | **HAUTE** |
| 15 | "Logout" | "Se déconnecter" | Bouton/Menu | HAUTE |

### Textes du Tableau de Bord

| # | Texte Actuel | Texte Français | Contexte | Priorité |
|---|---|---|---|---|
| 16 | "Dashboard" | "Tableau de bord" | Titre | **HAUTE** |
| 17 | "Recent Alerts" | "Alertes récentes" | Section | **HAUTE** |
| 18 | "Emergency Contacts" | "Contacts d'urgence" | Section | **HAUTE** |
| 19 | "My Items" | "Mes articles" | Section | MOYENNE |
| 20 | "Device Status" | "État de l'appareil" | Section | HAUTE |
| 21 | "Connected" | "Connecté" | Statut | HAUTE |
| 22 | "Disconnected" | "Déconnecté" | Statut | HAUTE |
| 23 | "Battery: {level}%" | "Batterie: {level}%" | Statut | HAUTE |

### Textes des Urgences

| # | Texte Actuel | Texte Français | Contexte | Priorité |
|---|---|---|---|---|
| 24 | "Emergency" | "Urgence" | Titre d'écran | **HAUTE** |
| 25 | "Send Emergency Alert" | "Envoyer une alerte d'urgence" | Bouton | **HAUTE** |
| 26 | "Alert Sent" | "Alerte envoyée" | Message | **HAUTE** |
| 27 | "Alert History" | "Historique des alertes" | Section | HAUTE |
| 28 | "Alert Map" | "Carte des alertes" | Titre | HAUTE |
| 29 | "Status: Pending" | "Statut: En attente" | Statut | HAUTE |
| 30 | "Status: Confirmed" | "Statut: Confirmé" | Statut | HAUTE |
| 31 | "Status: Resolved" | "Statut: Résolu" | Statut | HAUTE |
| 32 | "Responses" | "Réponses" | Section | HAUTE |

### Textes de Gestion des Contacts

| # | Texte Actuel | Texte Français | Contexte | Priorité |
|---|---|---|---|---|
| 33 | "Contacts" | "Contacts" | Titre | HAUTE |
| 34 | "Add Contact" | "Ajouter un contact" | Bouton | HAUTE |
| 35 | "Edit Contact" | "Modifier le contact" | Bouton | HAUTE |
| 36 | "Delete Contact" | "Supprimer le contact" | Bouton | HAUTE |
| 37 | "No contacts yet" | "Aucun contact pour le moment" | Message vide | HAUTE |
| 38 | "Relationship" | "Relation" | Label | HAUTE |
| 39 | "Emergency Contact" | "Contact d'urgence" | Checkbox | HAUTE |
| 40 | "Priority" | "Priorité" | Label | MOYENNE |

### Textes de Gestion des Appareils

| # | Texte Actuel | Texte Français | Contexte | Priorité |
|---|---|---|---|---|
| 41 | "Pair Device" | "Appairer un appareil" | Titre | HAUTE |
| 42 | "Device Settings" | "Paramètres de l'appareil" | Titre | HAUTE |
| 43 | "Available Devices" | "Appareils disponibles" | Section | HAUTE |
| 44 | "Paired Devices" | "Appareils appairés" | Section | HAUTE |
| 45 | "Vibration" | "Vibration" | Option | MOYENNE |
| 46 | "Sound" | "Son" | Option | MOYENNE |
| 47 | "Sleep Mode" | "Mode veille" | Option | MOYENNE |
| 48 | "Removal Detection" | "Détection de retrait" | Option | MOYENNE |

### Textes de Paramètres et Profil

| # | Texte Actuel | Texte Français | Contexte | Priorité |
|---|---|---|---|---|
| 49 | "Settings" | "Paramètres" | Titre | MOYENNE |
| 50 | "Profile" | "Profil" | Titre | MOYENNE |
| 51 | "Personal Information" | "Informations personnelles" | Section | MOYENNE |
| 52 | "Notifications" | "Notifications" | Section | MOYENNE |
| 53 | "Privacy & Security" | "Confidentialité & Sécurité" | Section | MOYENNE |
| 54 | "Language" | "Langue" | Option | MOYENNE |
| 55 | "Dark Mode" | "Mode sombre" | Option | MOYENNE |
| 56 | "Community Alerts" | "Alertes communautaires" | Option | MOYENNE |

### Messages d'Erreur et Validation

| # | Texte Actuel | Texte Français | Contexte | Priorité |
|---|---|---|---|---|
| 57 | "Invalid email" | "Adresse e-mail invalide" | Validation | HAUTE |
| 58 | "Password too short" | "Mot de passe trop court" | Validation | HAUTE |
| 59 | "Passwords don't match" | "Les mots de passe ne correspondent pas" | Validation | HAUTE |
| 60 | "Network error" | "Erreur réseau" | Erreur | HAUTE |
| 61 | "Please try again" | "Veuillez réessayer" | Suggestion | HAUTE |
| 62 | "Something went wrong" | "Une erreur s'est produite" | Erreur générale | HAUTE |
| 63 | "Loading..." | "Chargement..." | État | MOYENNE |
| 64 | "No internet connection" | "Pas de connexion Internet" | Erreur | HAUTE |

### Autres Textes

| # | Texte Actuel | Texte Français | Contexte | Priorité |
|---|---|---|---|---|
| 65 | "Yes" | "Oui" | Bouton | MOYENNE |
| 66 | "No" | "Non" | Bouton | MOYENNE |
| 67 | "Cancel" | "Annuler" | Bouton | MOYENNE |
| 68 | "Save" | "Enregistrer" | Bouton | MOYENNE |
| 69 | "Delete" | "Supprimer" | Bouton | MOYENNE |
| 70 | "Close" | "Fermer" | Bouton | MOYENNE |
| 71 | "OK" | "OK" | Bouton | MOYENNE |
| 72 | "Back" | "Retour" | Bouton | MOYENNE |
| 73 | "Next" | "Suivant" | Bouton | MOYENNE |
| 74 | "Skip" | "Ignorer" | Bouton | MOYENNE |

---

## 📝 COMMENTAIRES ET DOCUMENTATION

### Priorité de Traduction des Commentaires

| Type de Commentaire | Priorité | Stratégie |
|---|---|---|
| Commentaires de classe | MOYENNE | Traduire |
| Commentaires de fonction | MOYENNE | Traduire |
| Commentaires en ligne | FAIBLE | Traduire |
| TODO/FIXME/HACK | FAIBLE | Conserver structure, traduire description |
| URLs et références externes | NON | Ne pas traduire |
| Code d'exemple | FAIBLE | Adapter contexte si nécessaire |
| Noms de propriétés en commentaires | HAUTE | Synchroniser avec nouveau nom |

### Modèles de Commentaires

**Avant:**
```dart
/// This class represents an emergency alert sent by a user
/// Validates location and timestamps
class EmergencyAlert {
  /// List of contacts to notify
  final List<String> notifiedContacts;
  
  /// Get confirmed contacts count
  int get confirmedContacts => /* ... */;
}
```

**Après:**
```dart
/// Cette classe représente une alerte d'urgence envoyée par un utilisateur
/// Valide la localisation et les horodatages
class AlerteUrgence {
  /// Liste des contacts à notifier
  final List<String> contactsANotifier;
  
  /// Obtenir le nombre de contacts confirmés
  int get contactsConfirmes => /* ... */;
}
```

---

## 🔄 TRADUCTION DES VARIABLES ET PROPRIÉTÉS

### Variables de Classe

| # | Variable Actuelle | Nouvelle Variable | Classe | Priorité | Notes |
|---|---|---|---|---|---|
| 1 | `_emailController` | `_controleurEmail` | LoginScreen | MOYENNE | Contrôleur de texte |
| 2 | `_passwordController` | `_controleurMotDePasse` | LoginScreen | MOYENNE | Contrôleur de texte |
| 3 | `_animationController` | `_controleurAnimation` | LoginScreen | MOYENNE | Contrôleur animation |
| 4 | `_fadeAnimation` | `_animationOpacite` | LoginScreen | MOYENNE | Animation d'opacité |
| 5 | `_slideAnimation` | `_animationGlissement` | LoginScreen | MOYENNE | Animation de glissement |
| 6 | `_selectedIndex` | `_indexSelectionne` | DashboardScreen | MOYENNE | Index sélectionné |
| 7 | `_pageController` | `_controleurPage` | DashboardScreen | MOYENNE | Contrôleur de page |
| 8 | `_isFullscreen` | `_estPleinEcran` | DashboardScreen | MOYENNE | Plein écran |
| 9 | `_recentAlerts` | `_alertesRecentes` | DashboardScreen | MOYENNE | Alertes récentes |
| 10 | `_pulseController` | `_controleurPulsation` | DashboardScreen | MOYENNE | Contrôleur pulsation |

### Paramètres de Fonction

| # | Paramètre Actuel | Nouveau Paramètre | Priorité | Notes |
|---|---|---|---|---|
| 1 | `firstName` | `prenom` | MOYENNE | Prénom |
| 2 | `lastName` | `nom` | MOYENNE | Nom |
| 3 | `email` | `adresseEmail` ou `email` | MOYENNE | Garder ou traduire |
| 4 | `password` | `motDePasse` | MOYENNE | Mot de passe |
| 5 | `phoneNumber` | `numeroTelephone` | MOYENNE | Numéro téléphone |
| 6 | `userId` | `idUtilisateur` | MOYENNE | ID utilisateur |
| 7 | `deviceName` | `nomAppareil` | MOYENNE | Nom appareil |
| 8 | `macAddress` | `adresseMac` | MOYENNE | Garder (technique) |
| 9 | `latitude` | `latitude` | FAIBLE | Garder (technique) |
| 10 | `longitude` | `longitude` | FAIBLE | Garder (technique) |

---

## 🗂️ FICHIERS DE CONFIGURATION ET RESSOURCES

### Configuration (pubspec.yaml)

**Sections à adapter:**
- `name`: `safeguardian_ci_new` (garder)
- `description`: Traduire description
- `assets`: Adapter chemins si les répertoires sont renommés
  ```yaml
  assets:
    - ressources/images/
    - ressources/icones/
    - ressources/polices/
  ```

### Importation des Ressources

**Avant:**
```dart
Image.asset('assets/images/logo.png')
Icon(Icons.warning) // Garder
Theme.of(context).data // Garder
```

**Après:**
```dart
Image.asset('ressources/images/logo.png')
Icon(Icons.warning) // Garder
Theme.of(context).data // Garder
```

---

## 📊 TRADUCTION DES ÉNUMÉRATIONS (Détail Complet)

### Énumération AlertStatus

**Avant:**
```dart
enum AlertStatus {
  pending,     // En attente
  confirmed,   // Confirmée
  resolved,    // Résolue
  cancelled,   // Annulée
}
```

**Après:**
```dart
enum StatutAlerte {
  enAttente,     // En attente
  confirmee,     // Confirmée
  resolue,       // Résolue
  annulee,       // Annulée
}
```

### Énumération UserRole

**Avant:**
```dart
enum UserRole {
  user,       // Utilisateur
  guardian,   // Gardien
  admin,      // Administrateur
  moderator,  // Modérateur
}
```

**Après:**
```dart
enum RoleUtilisateur {
  utilisateur,    // Utilisateur
  gardien,        // Gardien
  administrateur, // Administrateur
  moderateur,     // Modérateur
}
```

### Énumération DeviceStatus

**Avant:**
```dart
enum DeviceStatus {
  connected,       // Connecté
  disconnected,    // Déconnecté
  pairing,         // Appairage
  error,           // Erreur
}
```

**Après:**
```dart
enum StatutAppareil {
  connecte,        // Connecté
  deconnecte,      // Déconnecté
  appairage,       // Appairage
  erreur,          // Erreur
}
```

---

## 📋 IMPORTATIONS ET RÉFÉRENCES - IMPACT D'ANALYSE

### Fichiers à Haute Dépendance (Critique)

Ces fichiers ont de nombreuses références d'autres fichiers:

1. **routes.dart** → Référencé dans TOUS les fichiers pour la navigation
   - ⚠️ CRITIQUE: Tous les imports doivent être mis à jour
   - ⚠️ Toutes les références à `AppRoutes` doivent changer en `RouteApp`

2. **User.dart** → Modèle utilisateur fondamental
   - ⚠️ Référencé dans AuthBloc, AuthService, plusieurs screens
   - Changement nom classe affecte: serialization, deserialization, typages

3. **Contact.dart** → Modèle très utilisé
   - Référencé dans ContactsScreen, ContactRepository, DashboardScreen
   - Nombreuses listes et collections

4. **AlerteUrgence (EmergencyAlert)** → Modèle critique
   - Utilisé dans EmergencyScreen, DashboardScreen, AlertRepository, BLoC
   - Sérialisation JSON critique pour Firebase

5. **auth_bloc.dart** → Centre de l'authentification
   - Tous les écrans l'utilisent
   - Changements affectent: BLoC pattern, États, Événements

### Graphe de Dépendances (Résumé)

```
main.dart
├── firebase_options.dart
├── routes.dart (CRITIQUE)
├── services/ (5 fichiers)
├── auth_bloc.dart (CRITIQUE)
├── models/user.dart (CRITIQUE)
└── auth_wrapper.dart
    └── presentation/screens (tous les écrans)
        ├── models/contact.dart (CRITIQUE)
        ├── models/alert.dart (CRITIQUE)
        ├── models/device.dart
        ├── repositories/ (2 fichiers)
        └── widgets/
            ├── cards/ (3 fichiers)
            ├── common/ (5+ fichiers)
            └── dialogs/ (3+ fichiers)
```

---

## ⏱️ CHRONOLOGIE DE MISE EN ŒUVRE

### Phase 1: Préparation (Jour 1)
- [x] Analyse complète du projet ✅
- [x] Création du plan de traduction ✅
- [ ] Créer script de renommage automatique des fichiers
- [ ] Sauvegarde de la branche Git
- [ ] Documenter tous les changements

**Durée estimée:** 4 heures

### Phase 2: Traduction des Répertoires (Jour 1-2)

**Ordre critique:**
1. Renommer `lib/assets/` → `lib/ressources/`
   - Sous-dossiers: `polices/`, `icones/`, `images/`
   - Mettre à jour pubspec.yaml

2. Renommer `lib/core/` → `lib/noyau/`
   - Sous-dossiers: `configuration/`, `constantes/`, `services/`, etc.

3. Renommer `lib/data/` → `lib/donnees/`
   - Sous-dossiers: `modeles/`, `depots/`

4. Renommer `lib/presentation/screens/` → `lib/presentation/ecrans/`
   - Sous-dossiers spécifiques

5. Renommer `lib/presentation/widgets/` sous-dossiers
   - `cartes/`, `dialogues/`, `reactif/`, `commun/`

**Durée estimée:** 8 heures

### Phase 3: Traduction des Fichiers (Jour 2-3)

**Ordre par dépendance:**
1. Fichiers critiques (sans dépendances externes):
   - `models/` (7 fichiers)
   - `services/` (5 fichiers)
   - `repositories/` (2 fichiers)

2. Fichiers BLoC:
   - `auth_bloc.dart`
   - `emergency_bloc.dart`

3. Fichiers de configuration:
   - `routes.dart`
   - `constants/`
   - `main.dart`

4. Fichiers d'écrans (dépendent de tout)
5. Fichiers de widgets

**Durée estimée:** 12 heures

### Phase 4: Traduction des Classes (Jour 3-4)

1. Énumérations dans les modèles
2. Classes de modèles
3. Classes de BLoC (Events, States)
4. Classes de services
5. Classes de screens
6. Classes de widgets

**Durée estimée:** 16 heures

### Phase 5: Traduction des Fonctions/Méthodes (Jour 4)

1. Méthodes de modèles (toJson, fromJson)
2. Méthodes de services
3. Getters et setters
4. Gestionnaires d'événements BLoC
5. Fonctions utilitaires

**Durée estimée:** 8 heures

### Phase 6: Mise à Jour des Imports (Jour 5)

1. Mettre à jour tous les imports dans tous les fichiers
2. Mettre à jour les références de classe
3. Tester que tout compile

⚠️ **CRITIQUE:** Cette étape doit être semi-automatisée

**Durée estimée:** 12 heures

### Phase 7: Traduction des Constantes (Jour 5)

1. Routes (AppRoutes → RouteApp)
2. Constantes d'application
3. Énumérations d'état/événement

**Durée estimée:** 4 heures

### Phase 8: Traduction des Chaînes UI (Jour 6-7)

1. Créer fichier de localisation (i18n) OU
2. Remplacer les chaînes hard-codées
3. Traduire tous les `"texte"` en `"texte français"`

**Durée estimée:** 16 heures

### Phase 9: Traduction des Commentaires (Jour 7-8)

1. Commentaires de classe
2. Commentaires de fonction
3. Commentaires en ligne
4. Documentation

**Durée estimée:** 12 heures

### Phase 10: Tests et Validation (Jour 8-9)

1. Vérifier que le projet compile
2. Tests unitaires
3. Tests d'intégration
4. Tests manuels des écrans
5. Vérifier la sérialisation JSON

**Durée estimée:** 12 heures

### Phase 11: Git et Finalisation (Jour 9)

1. Commit et push
2. Créer release notes
3. Documenter changements

**Durée estimée:** 4 heures

---

## 📊 RÉSUMÉ STATISTIQUES

| Catégorie | Nombre d'Éléments | Priorité | Durée Est. |
|---|---|---|---|
| Répertoires | 40+ | HAUTE | 8h |
| Fichiers Dart | 70+ | HAUTE | 12h |
| Classes | 100+ | HAUTE | 16h |
| Énumérations | 6 | HAUTE | 2h |
| Fonctions/Méthodes | 200+ | MOYENNE | 8h |
| Constantes | 50+ | HAUTE | 4h |
| Chaînes UI | 75+ | HAUTE | 16h |
| Commentaires | 500+ | FAIBLE | 12h |
| **TOTAL** | **1000+** | **HAUTE** | **78 heures** |

---

## ⚠️ RISQUES ET MITIGATION

### Risques Critiques

| Risque | Impact | Mitigation |
|---|---|---|
| Imports cassés | 🔴 BLOQUANT | Script automatique + tests de compilation |
| Sérialisation JSON | 🔴 CRITIQUE | Adapter toJson/fromJson en parallèle |
| Routes non trouvées | 🔴 BLOQUANT | Centraliser tous les noms de route |
| Perte de données | 🔴 CRITIQUE | Branche Git, sauvegarde locale |
| Incohérence de noms | 🟠 ÉLEVÉ | Convention de nommage stricte |

### Recommandations

1. **Utiliser Git aggressivement**
   - Commit après chaque phase
   - Branche dédiée pour traduction

2. **Automatisation recommandée**
   - Script pour renommer fichiers
   - Regex find/replace pour imports
   - Search/replace pour constantes

3. **Testing intensif**
   - Vérifier compilation après chaque phase
   - Tests automatisés de sérialisation JSON
   - Tests manuels des écrans critiques

4. **Documentation vivante**
   - Tenir à jour ce document
   - Créer mapping complet import ancien/nouveau

---

## 📚 RESSOURCES SUPPLÉMENTAIRES

### Conventions de Nommage en Français

- **Classes**: PascalCase → `MonClasse`, `MaClasse`
- **Variables**: camelCase → `maVariable`, `monObjet`
- **Constantes**: UPPER_SNAKE_CASE → `MA_CONSTANTE`
- **Enums**: PascalCase → `MonEtat`, `MonType`
- **Dossiers**: snake_case → `mon_dossier`, `mon_module`
- **Fichiers**: snake_case → `mon_fichier.dart`, `mon_service.dart`

### Glossaire de Traduction

**Termes Techniques (Garder):**
- BLoC
- Widget
- State
- Event
- Firebase
- API
- JSON
- QR
- Bluetooth
- GPS
- UUID
- MAC Address (adresse MAC)

**Termes Métier à Traduire:**
- Alert → Alerte
- Emergency → Urgence
- Contact → Contact (garder)
- Device → Appareil
- Item → Article
- Dashboard → Tableau de bord
- Settings → Paramètres
- Profile → Profil

---

## ✅ CHECKLIST DE VALIDATION

- [ ] Tous les répertoires renommés
- [ ] Tous les fichiers renommés
- [ ] Tous les imports mis à jour
- [ ] Toutes les classes renommées
- [ ] Toutes les énumérations renommées
- [ ] Tous les routes renommées
- [ ] Toutes les constantes renommées
- [ ] Toutes les fonctions renommées
- [ ] Toutes les chaînes UI traduites
- [ ] Tous les commentaires traduits
- [ ] Compilation réussie (flutter pub get)
- [ ] Aucune erreur de type
- [ ] Tests passants
- [ ] Sérialisation JSON valide
- [ ] Commit Git réussi
- [ ] Documentation mise à jour

---

**Plan créé par:** GitHub Copilot  
**Date:** 21 janvier 2026  
**Version:** 1.0  
**Statut:** ✅ Prêt pour implémentation
