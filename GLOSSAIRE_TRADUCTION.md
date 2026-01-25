# 🔤 GLOSSAIRE DE TRADUCTION - SafeGuardian

## 📚 DICTIONNAIRE COMPLET ANGLAIS → FRANÇAIS

### DOSSIERS / RÉPERTOIRES

```
assets/           → ressources/
core/             → noyau/
data/             → donnees/
lib/              → lib/ (garder)
presentation/     → presentation/ (garder globalement)
  └─ bloc/        → bloc_etat/
  └─ screens/     → ecrans/
  └─ theme/       → theme/ (garder)
  └─ widgets/     → composants/

noyau/ (core/)
  ├─ config/      → configuration/
  ├─ constants/   → constantes/
  ├─ mixins/      → mixtes/
  ├─ services/    → services/
  ├─ theme/       → theme/
  └─ utils/       → utilitaires/

donnees/ (data/)
  ├─ models/      → modeles/
  └─ repositories/ → depots/
```

---

### CLASSES & STRUCTURES

#### Models / Modèles
```
User                          → Utilisateur
EmergencyAlert                → AlerteUrgence
EmergencyContact              → ContactUrgence
ValuedItem                    → ObjetValorise
Device                        → Appareil
Document                      → Document (no change)
Contact                       → Contact (no change)
```

#### Services
```
NotificationService           → ServiceNotification
BluetoothService              → ServiceBluetooth
LocationService               → ServiceLocalisation
AuthService                   → ServiceAuthentification
LocationService               → ServiceLocalisation
```

#### Widgets
```
CustomHamburgerMenu           → MenuHamburgerPersonnalise
EmergencyButton               → BoutonUrgence
AuthWrapper                   → EnveloppeAuthentification
AlertCard                     → CarteAlerte
ContactCard                   → CarteContact
ItemCard                      → CarteObjet
```

#### BLoCs
```
AuthBloc                      → BlocAuthentification
EmergencyBloc                 → BlocUrgence
AuthEvent                     → EvenementAuth
AuthState                     → EtatAuth
EmergencyEvent                → EvenementUrgence
EmergencyState                → EtatUrgence
```

---

### ENUMS & ÉNUMÉRATIONS

#### Statuts
```
AlertStatus {
  pending                     → en_attente
  resolved                    → resolu
  cancelled                   → annule
}
→ StatutAlerte

UserRole {
  user                        → utilisateur
  guardian                    → gardien
  admin                       → administrateur
}
→ RoleUtilisateur

ItemCategory {
  wallet                      → portefeuille
  keys                        → cles
  phone                       → telephone
  jewelry                     → bijoux
  documents                   → documents
  other                       → autre
}
→ CategorieObjet
```

---

### FICHIERS DART

#### `lib/data/models/`
```
alert.dart                    → alerte.dart
emergency_contact.dart        → contact_urgence.dart
item.dart                     → objet.dart
user.dart                     → utilisateur.dart
device.dart                   → appareil.dart
document.dart                 → document.dart (no change)
contact.dart                  → contact.dart (no change)
```

#### `lib/presentation/screens/`
```
auth/
  login_screen.dart           → ecran_connexion.dart
  register_screen.dart        → ecran_inscription.dart

dashboard/
  dashboard_screen.dart       → ecran_tableau_de_bord.dart

emergency/
  emergency_screen.dart       → ecran_urgence.dart
  alert_map_screen.dart       → ecran_carte_alerte.dart
  alert_history_screen.dart   → ecran_historique_alerte.dart

contacts/
  contacts_screen.dart        → ecran_contacts.dart
  add_contact_screen.dart     → ecran_ajouter_contact.dart

items/
  items_screen.dart           → ecran_objets.dart
  add_item_screen.dart        → ecran_ajouter_objet.dart
  lost_found_screen.dart      → ecran_perdu_trouve.dart

documents/
  documents_screen.dart       → ecran_documents.dart
  add_document_screen.dart    → ecran_ajouter_document.dart

device/
  pair_device_screen.dart     → ecran_appairer_appareil.dart
  device_settings_screen.dart → ecran_parametres_appareil.dart

community/
  community_alerts_screen.dart → ecran_alertes_communaute.dart
  help_center_screen.dart      → ecran_centre_aide.dart

admin/
  admin_dashboard.dart        → tableau_de_bord_admin.dart

settings/
  settings_screen.dart        → ecran_parametres.dart

profile/
  profile_screen.dart         → ecran_profil.dart

main/
  splash_screen.dart          → ecran_demarrage.dart (no change)
  qr_scanner_screen.dart      → ecran_scanner_qr.dart
  onboarding_screen.dart      → ecran_demarrage.dart
```

#### `lib/presentation/widgets/`
```
common/
  emergency_button.dart       → bouton_urgence.dart
  responsive_widgets.dart     → composants_responsifs.dart

cards/
  alert_card.dart             → carte_alerte.dart
  contact_card.dart           → carte_contact.dart
  item_card.dart              → carte_objet.dart
  document_card.dart          → carte_document.dart

dialogs/
  emergency_dialog.dart       → dialogue_urgence.dart

responsive/
  responsive_widgets.dart     → composants_responsifs.dart
  responsive_screen_wrapper.dart → enveloppe_ecran_responsif.dart

custom_hamburger_menu.dart    → menu_hamburger_personnalise.dart
auth_wrapper.dart             → enveloppe_authentification.dart
```

#### `lib/core/services/`
```
bluetooth_service.dart        → service_bluetooth.dart
location_service.dart         → service_localisation.dart
notification_service.dart     → service_notification.dart
auth_service.dart             → service_authentification.dart
```

#### `lib/core/constants/`
```
routes.dart                   → routes.dart (keep values as is)
app_constants.dart            → constantes_app.dart
```

---

### VARIABLES & PROPRIÉTÉS

#### Sélections & Index
```
_selectedIndex                → _indexSelectionne
selectedContact               → contactSelectionne
selectedItem                  → objetSelectionne
currentIndex                  → indexCourant
```

#### Controllers & Animation
```
_pageController               → _controleurPage
_animationController          → _controleurAnimation
_pulseController              → _controleurPulsation
_slideController              → _controleurGlissement
_tabController                → _controleurTab
_pulseAnimation               → _animationPulsation
_slideAnimation               → _animationGlissement
_menuExpandAnimation          → _animationExpansionMenu
```

#### Listes & Collections
```
_recentAlerts                 → _alertesRecentes
_recentItems                  → _objetsRecents
_recentContacts               → _contactsRecents
_filteredList                 → _listeFiltre
_searchResults                → _resultatsRecherche
```

#### États Booléens
```
_isMenuOpen                   → _menuOuvert
_isFullscreen                 → _estPleinEcran
_isLoading                    → _estEnChargement
_isConnected                  → _estConnecte
_isValid                      → _estValide
_isEmpty                      → _estVide
_isVisible                    → _estVisible
_hasError                     → _aUneErreur
```

#### Autres Propriétés
```
itemCount                     → nombreElements
errorMessage                  → messageErreur
successMessage                → messageSucces
loadingMessage                → messageChargement
emptyMessage                  → messageVide
timestamp                     → horodatage
userId                        → idUtilisateur
contactId                     → idContact
itemId                        → idObjet
deviceId                      → idAppareil
```

---

### FONCTIONS & MÉTHODES

#### Navigation
```
_goToAlerts(context)          → _allerAuxAlertes(context)
_goToContacts(context)        → _allerAuxContacts(context)
_goToItems(context)           → _allerAuxObjets(context)
_goToDashboard(context)       → _allerAuTableauDeBord(context)
navigateToHome()              → naviguerVersAccueil()
navigateBack()                → naviguerEnArriere()
```

#### Interaction
```
_toggleMenu()                 → _basculerMenu()
_selectItem(index)            → _selectionnerElement(index)
_handleEmergency()            → _gererUrgence()
_handleLogout()               → _gererDeconnexion()
_handleLogin()                → _gererConnexion()
_pairDevice()                 → _appareillerAppareil()
_scanQRCode()                 → _scannerCodeQR()
_showError()                  → _afficherErreur()
_showSuccess()                → _afficherSucces()
_openDialog()                 → _ouvrirDialogue()
_closeDialog()                → _fermerDialogue()
```

#### Construction (Build)
```
_buildHomePage()              → _construirePageAccueil()
_buildModernAppBar()          → _construireBarreAppModerne()
_buildFloatingEmergencyButton() → _construireBoutonUrgenceFlottant()
_buildStatusHeroCard()        → _construireCarteHerosStatut()
_buildQuickStatsGrid()        → _construireGrilleStatRapide()
_buildFeatureCarousel()       → _construireCarouselFonctionnalites()
_buildAlertsSection()         → _construireSectionAlertes()
_buildContactsSection()       → _construireSectionContacts()
_buildItemsSection()          → _construireSectionObjets()
_buildEmptyState()            → _construireEtatVide()
_buildActionButton()          → _construireBoutonAction()
```

#### Chargement & Traitement
```
loadAlerts()                  → chargerAlertes()
loadContacts()                → chargerContacts()
loadItems()                   → chargerObjets()
loadDocuments()               → chargerDocuments()
fetchData()                   → telechargerDonnees()
saveData()                    → enregistrerDonnees()
deleteData()                  → supprimerDonnees()
updateData()                  → mettreAJourDonnees()
syncData()                    → synchroniserDonnees()
```

#### Validation
```
isValid()                     → estValide()
isEmpty()                     → estVide()
validateEmail()               → validerEmail()
validatePassword()            → validerMotDePasse()
validateInput()               → validerEntree()
```

---

### STRINGS & TEXTES

#### Navigation & Menu
```
"Home"                        → "Accueil"
"Contacts"                    → "Contacts"
"Items"                       → "Objets"
"Documents"                   → "Documents"
"Settings"                    → "Paramètres"
"Profile"                     → "Profil"
"Menu"                        → "Menu"
"Back"                        → "Retour"
"View All"                    → "Voir tout"
```

#### Actions
```
"Add"                         → "Ajouter"
"Edit"                        → "Modifier"
"Delete"                      → "Supprimer"
"Save"                        → "Enregistrer"
"Cancel"                      → "Annuler"
"Confirm"                     → "Confirmer"
"Search"                      → "Rechercher"
"Filter"                      → "Filtrer"
"Sort"                        → "Trier"
```

#### Auth
```
"Login"                       → "Connexion"
"Register"                    → "Inscription"
"Sign Up"                     → "S'inscrire"
"Sign In"                     → "Se connecter"
"Logout"                      → "Déconnexion"
"Email"                       → "Email"
"Password"                    → "Mot de passe"
"Forgot Password"             → "Mot de passe oublié"
```

#### States
```
"Loading..."                  → "Chargement..."
"Success"                     → "Succès"
"Error"                       → "Erreur"
"Warning"                     → "Avertissement"
"Info"                        → "Information"
"No Data"                     → "Aucune donnée"
"Empty"                       → "Vide"
```

#### Emergency
```
"Emergency"                   → "Urgence"
"SOS"                         → "SOS"
"Alert"                       → "Alerte"
"Danger"                      → "Danger"
"Safe"                        → "Sécurisé"
"Protected"                   → "Protégé"
"System Active"               → "SYSTÈME ACTIF"
"System Inactive"             → "SYSTÈME INACTIF"
```

#### Device
```
"Device"                      → "Appareil"
"Pair Device"                 → "Appairer l'appareil"
"Connect"                     → "Connecter"
"Disconnect"                  → "Déconnecter"
"Battery"                     → "Batterie"
"Bluetooth"                   → "Bluetooth"
"Connection"                  → "Connexion"
"Connected"                   → "Connecté"
"Disconnected"                → "Déconnecté"
```

---

### COMMENTAIRES (EXAMPLES)

```
// AVANT
/// Creates a user profile screen
/// Allows users to view and edit their profile information

// APRÈS
/// Crée un écran de profil utilisateur
/// Permet aux utilisateurs de voir et modifier leurs informations de profil
```

```
// AVANT
// Handle button press
void _handleButtonPress() {
  // Do something
}

// APRÈS
// Gérer l'appui sur le bouton
void _gererAppuiBouton() {
  // Faire quelque chose
}
```

---

## 🎯 RÉSUMÉ RAPIDE

### Top 20 Traductions Prioritaires
1. AlertStatus → StatutAlerte
2. EmergencyAlert → AlerteUrgence
3. EmergencyContact → ContactUrgence
4. ValuedItem → ObjetValorise
5. NotificationService → ServiceNotification
6. BluetoothService → ServiceBluetooth
7. CustomHamburgerMenu → MenuHamburgerPersonnalise
8. _recentAlerts → _alertesRecentes
9. _handleEmergency → _gererUrgence
10. isConnected → estConnecte

Plus 15 autres...

---

## ✅ COMMENT UTILISER CE GLOSSAIRE

1. **Copier-Coller** la correspondance anglais/français
2. **Find & Replace** (Ctrl+H) dans l'éditeur
3. **Tester** avec `flutter analyze`
4. **Valider** que la compilation fonctionne
5. **Commit** avec Git

---

## 🔗 RESSOURCES ASSOCIÉES

- [`CHECKLIST_TRADUCTION.md`](CHECKLIST_TRADUCTION.md) - Checklist interactive
- [`GUIDE_TRADUCTION_FRANCAIS.md`](GUIDE_TRADUCTION_FRANCAIS.md) - Guide détaillé
- [`INDEX_TRADUCTION.md`](INDEX_TRADUCTION.md) - Index complet

---

*Créé : 21 janvier 2026*
*Glossaire de Traduction - SafeGuardian*
*Équipe SILENTOPS - MIAGE*
