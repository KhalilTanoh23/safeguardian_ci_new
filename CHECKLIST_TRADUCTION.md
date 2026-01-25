# ✅ CHECKLIST DE TRADUCTION INTERACTIVE - SafeGuardian

## 🎯 AVANT DE COMMENCER

### Setup Initial
- [ ] Créer branche Git : `git checkout -b traduction/francais-complet`
- [ ] Sauvegarder local : Copier dossier projet ailleurs (backup)
- [ ] Vérifier Git status : `git status` (doit être clean)
- [ ] Tester build actuel : `flutter analyze` (0 erreurs)
- [ ] Lancer app : `flutter run` (fonctionne)
- [ ] Lire [`TRADUCTION_DEMARRAGE_RAPIDE.md`](TRADUCTION_DEMARRAGE_RAPIDE.md)

---

## 📋 PHASE 1: TRADUCTION COMMENTAIRES (2-3 jours)

### Priorité 1 - Fichiers Critiques
- [ ] `lib/presentation/screens/dashboard/dashboard_screen.dart`
  - [ ] Remplacer `///` (commentaires doc) en français
  - [ ] Remplacer `//` (commentaires ligne) en français
  - [ ] Vérifier aucune modification de code
  - [ ] Test : `flutter analyze`
  
- [ ] `lib/presentation/widgets/custom_hamburger_menu.dart`
  - [ ] Mêmes opérations
  - [ ] Test : `flutter analyze`
  
- [ ] `lib/data/models/alert.dart`
- [ ] `lib/data/models/emergency_contact.dart`
- [ ] `lib/data/models/item.dart`
- [ ] `lib/data/models/user.dart`
- [ ] `lib/data/models/device.dart`
- [ ] `lib/core/services/bluetooth_service.dart`
- [ ] `lib/core/services/location_service.dart`
- [ ] `lib/core/services/notification_service.dart`
- [ ] `lib/presentation/bloc/auth_bloc/auth_bloc.dart`
- [ ] `lib/presentation/bloc/emergency_bloc/emergency_bloc.dart`

### Priorité 2 - Autres Fichiers
- [ ] Tous les fichiers dans `lib/presentation/screens/`
- [ ] Tous les fichiers dans `lib/presentation/widgets/`
- [ ] Tous les fichiers dans `lib/core/services/`
- [ ] Tous les fichiers dans `lib/data/repositories/`

### Validation Phase 1
Après terminaison :
```bash
flutter analyze    # ✅ 0 erreurs
flutter pub get    # ✅ OK
flutter run        # ✅ App fonctionne
```

**Commit** :
```bash
git add .
git commit -m "Traduction Phase 1: Commentaires en français (600+ lignes)"
```

---

## 🔤 PHASE 2: TRADUCTION CLASSES & ENUMS (1-2 jours)

### Enums à Traduire
**Fichier : `lib/data/models/alert.dart`**
- [ ] `enum AlertStatus { pending, resolved, cancelled }`
  - Nouveau nom : `StatutAlerte`
  - Valeurs : `en_attente, resolu, annule`
  - Mettre à jour tous les usages

**Fichier : `lib/core/constants/routes.dart` ou autre**
- [ ] `enum UserRole { user, guardian, admin }`
  - Nouveau nom : `RoleUtilisateur`
  - Valeurs : `utilisateur, gardien, administrateur`

**Fichier : `lib/data/models/item.dart`**
- [ ] `enum ItemCategory { wallet, keys, phone, jewelry, documents, other }`
  - Nouveau nom : `CategorieObjet`
  - Traduire toutes les valeurs en français

### Classes à Traduire
- [ ] `EmergencyAlert` → `AlerteUrgence`
  - Remplacer dans tous les fichiers (grep search)
  - Mettre à jour imports
  
- [ ] `EmergencyContact` → `ContactUrgence`
  - Mêmes opérations
  
- [ ] `ValuedItem` → `ObjetValorise`
  - Mêmes opérations
  
- [ ] `User` → `Utilisateur`
  - Mêmes opérations
  
- [ ] `Device` → `Appareil`
  - Mêmes opérations

### Services à Traduire (Noms Seulement)
- [ ] `NotificationService` → `ServiceNotification`
- [ ] `BluetoothService` → `ServiceBluetooth`
- [ ] `LocationService` → `ServiceLocalisation`
- [ ] `AuthService` → `ServiceAuthentification`

### Validation Phase 2
```bash
flutter analyze    # ✅ 0 erreurs
flutter pub get    # ✅ OK
flutter run        # ✅ App fonctionne
```

**Commit** :
```bash
git add .
git commit -m "Traduction Phase 2: Classes et Enums en français"
```

---

## 📝 PHASE 3: TRADUCTION VARIABLES & FONCTIONS (2-3 jours)

### Variables Critiques à Traduire

**Dans `dashboard_screen.dart`** :
- [ ] `_selectedIndex` → `_indexSelectionne`
- [ ] `_pageController` → `_controleurPage`
- [ ] `_pulseController` → `_controleurPulsation`
- [ ] `_slideController` → `_controleurGlissement`
- [ ] `_pulseAnimation` → `_animationPulsation`
- [ ] `_slideAnimation` → `_animationGlissement`
- [ ] `_isFullscreen` → `_estPleinEcran`
- [ ] `_recentAlerts` → `_alertesRecentes`
- [ ] `_recentItems` → `_objetsRecents`
- [ ] `_contacts` → `_contacts` (déjà OK)
- [ ] `_isMenuOpen` → `_menuOuvert`

### Fonctions Critiques à Traduire
- [ ] `_toggleMenu()` → `_basculerMenu()`
- [ ] `_selectItem()` → `_selectionnerElement()`
- [ ] `_handleEmergency()` → `_gererUrgence()`
- [ ] `_pairDevice()` → `_appareillerAppareil()`
- [ ] `_scanQRCode()` → `_scannerCodeQR()`
- [ ] `_goToAlerts()` → `_allerAuxAlertes()`
- [ ] `_goToContacts()` → `_allerAuxContacts()`
- [ ] `_goToItems()` → `_allerAuxObjets()`
- [ ] `_buildHomePage()` → `_construirePageAccueil()`
- [ ] `_buildModernAppBar()` → `_construireBarreAppModerne()`
- [ ] `_buildFloatingEmergencyButton()` → `_construireBoutonUrgenceFlottant()`

### Booléens à Traduire
- [ ] `isConnected` → `estConnecte`
- [ ] `isLoading` → `estEnChargement`
- [ ] `isValid` → `estValide`
- [ ] `isEmpty` → `estVide`

### Validation Phase 3
```bash
flutter analyze    # ✅ 0 erreurs
flutter pub get    # ✅ OK
flutter run        # ✅ App fonctionne
```

**Commit** :
```bash
git add .
git commit -m "Traduction Phase 3: Variables et Fonctions en français"
```

---

## 📁 PHASE 4: RENOMMAGE FICHIERS DART (2-3 jours)

### Modèles (`lib/data/models/`)
- [ ] `alert.dart` → `alerte.dart`
- [ ] `emergency_contact.dart` → `contact_urgence.dart`
- [ ] `item.dart` → `objet.dart`
- [ ] `user.dart` → `utilisateur.dart`
- [ ] `device.dart` → `appareil.dart`
- [ ] `document.dart` → `document.dart` (déjà OK)

**Après chaque renommage** :
- Trouver tous les imports de l'ancien fichier
- Remplacer par nouveau chemin
- Test : `flutter analyze`

### Écrans (`lib/presentation/screens/`)
- [ ] `login_screen.dart` → `ecran_connexion.dart`
- [ ] `register_screen.dart` → `ecran_inscription.dart`
- [ ] `dashboard_screen.dart` → `ecran_tableau_de_bord.dart`
- [ ] `emergency_screen.dart` → `ecran_urgence.dart`
- [ ] `contacts_screen.dart` → `ecran_contacts.dart`
- [ ] `items_screen.dart` → `ecran_objets.dart`
- [ ] `documents_screen.dart` → `ecran_documents.dart`

**Après chaque renommage** :
- Trouver tous les imports
- Remplacer
- Test : `flutter analyze`

### Widgets (`lib/presentation/widgets/`)
- [ ] `custom_hamburger_menu.dart` → `menu_hamburger_personnalise.dart`
- [ ] `emergency_button.dart` → `bouton_urgence.dart`
- [ ] `auth_wrapper.dart` → `enveloppe_authentification.dart`
- [ ] Autres widgets...

### Services (`lib/core/services/`)
- [ ] `bluetooth_service.dart` → `service_bluetooth.dart`
- [ ] `location_service.dart` → `service_localisation.dart`
- [ ] `notification_service.dart` → `service_notification.dart`
- [ ] `auth_service.dart` → `service_authentification.dart`

### BLoCs (`lib/presentation/bloc/`)
- [ ] `auth_bloc/auth_bloc.dart` → `auth_bloc/bloc_authentification.dart`
- [ ] `emergency_bloc/emergency_bloc.dart` → `emergency_bloc/bloc_urgence.dart`

### Validation Phase 4
```bash
flutter clean      # ✅ Nettoyer cache
flutter pub get    # ✅ OK
flutter analyze    # ✅ 0 erreurs
flutter run        # ✅ App fonctionne
```

**Commit** :
```bash
git add .
git commit -m "Traduction Phase 4: Renommage fichiers Dart en français"
```

---

## 📂 PHASE 5: RENOMMAGE RÉPERTOIRES (1-2 jours)

### Préparation
- [ ] Sauvegarder projet avec Git : `git add . && git commit`
- [ ] Vérifier tous les imports avant renommage

### Renommage Par Terminal

**Option 1: Via Terminal PowerShell**
```powershell
# NOYAU (core)
mv lib\core lib\noyau

# DONNÉES (data)
mv lib\data lib\donnees

# RESSOURCES (assets)
mv lib\assets lib\ressources

# PRÉSENTATION - sous-dossiers
mv lib\presentation\screens lib\presentation\ecrans
mv lib\presentation\widgets lib\presentation\composants
mv lib\presentation\bloc lib\presentation\bloc_etat

# NOYAU - sous-dossiers
mv lib\noyau\config lib\noyau\configuration
mv lib\noyau\services lib\noyau\services (OK)
mv lib\noyau\utils lib\noyau\utilitaires
mv lib\noyau\constants lib\noyau\constantes

# DONNÉES - sous-dossiers
mv lib\donnees\models lib\donnees\modeles
mv lib\donnees\repositories lib\donnees\depots
```

### Mise à Jour Imports Massifs
- [ ] Ouvrir Find & Replace (Ctrl+H)
- [ ] Chercher : `'package:safeguardian_ci_new/core/`
- [ ] Remplacer : `'package:safeguardian_ci_new/noyau/`
- [ ] Remplacer tout

- [ ] Chercher : `'package:safeguardian_ci_new/data/`
- [ ] Remplacer : `'package:safeguardian_ci_new/donnees/`
- [ ] Remplacer tout

- [ ] Chercher : `'package:safeguardian_ci_new/presentation/screens/`
- [ ] Remplacer : `'package:safeguardian_ci_new/presentation/ecrans/`
- [ ] Remplacer tout

- [ ] Chercher : `'package:safeguardian_ci_new/presentation/widgets/`
- [ ] Remplacer : `'package:safeguardian_ci_new/presentation/composants/`
- [ ] Remplacer tout

(Et tous les autres patterns...)

### Validation Phase 5
```bash
flutter clean      # ✅ Nettoyer cache
flutter pub get    # ✅ OK
flutter analyze    # ✅ 0 erreurs (peut prendre 2-3 min)
flutter run        # ✅ App fonctionne
```

**Commit** :
```bash
git add .
git commit -m "Traduction Phase 5: Renommage répertoires en français"
```

---

## 🎉 FINITION

### Vérification Finale
- [ ] `flutter analyze` - 0 erreurs
- [ ] `flutter run` - App fonctionne correctement
- [ ] Navigation fonctionne
- [ ] Tous les écrans s'affichent
- [ ] Aucune modification de fonctionnalité
- [ ] Code complet en français

### Nettoyage
```bash
flutter clean
flutter pub get
dart fix --apply
flutter format .
```

### Git - Fusionner dans Main
```bash
git add .
git commit -m "Traduction: Application SafeGuardian 100% francisée"
git checkout main
git merge traduction/francais-complet
git push origin main
```

---

## 📊 RÉSUMÉ TRADUCTION

| Phase | Durée | Fichiers | Status |
|-------|-------|----------|--------|
| 1. Commentaires | 2-3 j | 50+ | ⬜ |
| 2. Classes/Enums | 1-2 j | 20+ | ⬜ |
| 3. Variables | 2-3 j | 80+ | ⬜ |
| 4. Fichiers | 2-3 j | 70+ | ⬜ |
| 5. Répertoires | 1-2 j | 10+ | ⬜ |
| **TOTAL** | **8-13 j** | **230+** | **⬜** |

---

## 🆘 HELP! Quelque Chose Ne Va Pas?

### Build échoue après renommage
```bash
flutter clean
flutter pub get
flutter analyze
```

### Imports cassés
- Utilisez Ctrl+Shift+F pour Find/Replace
- Cherchez ancien chemin, remplacez par nouveau

### App crash au démarrage
- Vérifiez routes.dart est correct
- Vérifiez tous les imports de models

### "Cannot find class X"
- Cherchez avec Ctrl+F le nom ancien de la classe
- Vérifiez que tous les usages sont renommés

---

## ✨ VOUS AVEZ TERMINÉ!

Félicitations ! 🎉

Votre application SafeGuardian est maintenant :
- ✅ 100% en français
- ✅ Code lisible et maintenable
- ✅ Commentaires traduits
- ✅ Noms professionnels
- ✅ Prête pour la production

**Prochaines étapes** :
1. Relaser en production
2. Optionnel : Ajouter support multi-langue (i18n)
3. Documenter la traduction pour l'équipe

---

*Créé : 21 janvier 2026*
*Projet SafeGuardian - Équipe SILENTOPS*
