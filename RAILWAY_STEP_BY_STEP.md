# 📖 GUIDE PAS-À-PAS RAILWAY - ÉTAPE PAR ÉTAPE

## ⚠️ PRÉ-REQUIS

- ✅ Compte GitHub
- ✅ Code pushé sur la branche (déjà fait)
- ✅ Supabase configuré

---

## ÉTAPE 1️⃣ : CRÉER UN COMPTE RAILWAY

### 1.1 Aller sur Railway

```
URL: https://railway.app
```

### 1.2 Cliquer sur "Login with GitHub"

```
Bouton en haut à droite: "Login with GitHub"
```

### 1.3 Autoriser l'accès

```
GitHub vous demande si vous autorisez Railway à accéder à vos repos
→ Cliquez "Authorize railway-app"
```

### 1.4 Vérifier que vous êtes connecté

```
Vous devez voir votre nom/avatar en haut à droite
```

---

## ÉTAPE 2️⃣ : CRÉER UN NOUVEAU PROJET RAILWAY

### 2.1 Cliquer sur "Create a New Project"

```
Page d'accueil → Bouton bleu "Create a New Project"
```

### 2.2 Choisir "Deploy from GitHub"

```
Options proposées:
- Deploy from GitHub ← CLIQUEZ ICI
- Use a template
- GitHub
- Docker
```

### 2.3 Sélectionner le repo GitHub

```
Cherchez: safeguardian_ci_new
Cliquez dessus pour le sélectionner
```

### 2.4 Railway détecte automatiquement le Dockerfile

```
Railway vous dit:
"Dockerfile detected in ./backend"
→ C'est correct! Il va utiliser notre Dockerfile
```

### 2.5 Nommer le projet (optionnel)

```
Par défaut: safeguardian_ci_new
Vous pouvez le renommer si vous voulez
```

### 2.6 Cliquer sur "Deploy"

```
Bouton bleu "Deploy"
Railway commence le déploiement
Vous verrez:
- "Building..."
- Puis "Deploying..."
- Puis "Running ✓"
```

---

## ÉTAPE 3️⃣ : CONFIGURER LES VARIABLES D'ENVIRONNEMENT

### 3.1 Attendre que le déploiement finisse

```
Attendez que le statut passe à "Running ✓"
(Cela prend 2-3 min environ)
```

### 3.2 Aller dans "Variables"

```
Dans le panneau du projet, vous verrez:
- Deployments
- Builds
- Variables ← CLIQUEZ ICI
```

### 3.3 Ajouter les variables une par une

**Variable 1: DATABASE_URL**

```
Clé: DATABASE_URL
Valeur: postgresql://postgres.nkfglqobowihkfkcozlt:%40silentOPS6789%23@aws-1-eu-west-2.pooler.supabase.com:6543/postgres?pgbouncer=true

Cliquez "Add"
```

**Variable 2: DB_DRIVER**

```
Clé: DB_DRIVER
Valeur: pgsql

Cliquez "Add"
```

**Variable 3: JWT_SECRET**

```
Clé: JWT_SECRET
Valeur: e8f3a2c9d4b7f1e6a3c8d2f5b9a1e4c7d0f3a6b9e2c5f8a1d4e7a0c3f6b9

Cliquez "Add"
```

**Variable 4: CORS_ORIGINS**

```
Clé: CORS_ORIGINS
Valeur: http://localhost:3000,https://app.safeguardian.ci

Cliquez "Add"
```

**Variable 5: APP_ENV**

```
Clé: APP_ENV
Valeur: production

Cliquez "Add"
```

**Variable 6: APP_DEBUG**

```
Clé: APP_DEBUG
Valeur: false

Cliquez "Add"
```

### 3.4 Redéployer avec les variables

```
Après avoir ajouté les variables, Railway redéploie automatiquement
Attendez "Running ✓" à nouveau
```

---

## ÉTAPE 4️⃣ : IMPORTER LE SCHÉMA SUPABASE

### 4.1 Aller sur Supabase

```
URL: https://nkfglqobowihkfkcozlt.supabase.co
```

### 4.2 Cliquer sur "SQL Editor"

```
Menu gauche → SQL Editor
```

### 4.3 Cliquer sur "New Query"

```
Bouton "+ New Query"
```

### 4.4 Copier-coller le schéma PostgreSQL

```
1. Ouvrez le fichier: backend/database/schema_postgresql.sql
2. Sélectionnez TOUT (Ctrl+A)
3. Copiez (Ctrl+C)
4. Dans Supabase SQL Editor, collez (Ctrl+V)
```

### 4.5 Exécuter la requête

```
Bouton bleu "Execute" ou Ctrl+Enter
```

### 4.6 Vérifier que les tables sont créées

```
Allez dans: Database → Tables (menu gauche)
Vous devez voir:
- users
- emergency_contacts
- alerts
- alert_notifications
- items
- documents
- document_shares
- user_settings
- emergency_info
- devices
- activity_logs
```

---

## ÉTAPE 5️⃣ : RÉCUPÉRER L'URL DE VOTRE API

### 5.1 Retourner sur Railway

```
Onglet Railway (gardé ouvert)
```

### 5.2 Chercher l'URL du service

```
Dans le panneau du projet, vous verrez:
- "Domains" section
- Votre URL ressemble à: https://safeguardian-ci-xxx.railway.app
```

### 5.3 Copier cette URL

```
Elle sera utilisée pour connecter votre app Flutter
```

---

## ÉTAPE 6️⃣ : TESTER QUE TOUT FONCTIONNE

### 6.1 Ouvrir un terminal/PowerShell

```
Sur votre machine locale
```

### 6.2 Tester l'API

```powershell
curl https://[votre-app].railway.app/api/users
```

### 6.3 Vérifier la réponse

```
Vous devez voir:
- Soit un JSON avec les utilisateurs
- Soit une erreur 401 (authentification requise) - c'est OK aussi!
- Ne doit PAS être: erreur 500 ou connexion refusée
```

---

## ÉTAPE 7️⃣ : CONNECTER LE FRONTEND FLUTTER

### 7.1 Ouvrir le fichier Flutter

```
lib/core/constants/api_constants.dart
```

### 7.2 Mettre à jour l'URL de base

```dart
// AVANT:
const String API_BASE_URL = 'http://localhost:8000/api';

// APRÈS:
const String API_BASE_URL = 'https://[votre-app].railway.app/api';
```

### 7.3 Rebuild l'app Flutter

```powershell
flutter pub get
flutter run
```

---

## ✅ CHECKLIST FINALE

Cochez chaque étape:

```
□ 1. Compte Railway créé
□ 2. Repo connecté à Railway
□ 3. Dockerfile détecté (Dockerfile)
□ 4. Déploiement terminé ("Running ✓")
□ 5. Variables d'env configurées (DATABASE_URL, JWT_SECRET, etc.)
□ 6. Redéploiement fait après variables
□ 7. Schéma Supabase importé (11 tables créées)
□ 8. URL API copiée
□ 9. Test curl réussi (pas d'erreur 500)
□ 10. Frontend Flutter mis à jour avec URL
```

---

## 🆘 DÉPANNAGE RAPIDE

### Erreur: "Dockerfile not found"

```
→ Vérifiez que backend/Dockerfile existe
→ Sinon, créez-le manuellement
```

### Erreur: "Cannot connect to database"

```
→ Vérifiez DATABASE_URL est correcte
→ Vérifiez les caractères spéciaux: @ → %40
```

### Erreur 500 sur l'API

```
→ Cliquez "Logs" dans Railway
→ Cherchez le message d'erreur
→ Vérifiez que le schéma Supabase est importé
```

### L'app Flutter ne se connecte pas

```
→ Vérifiez CORS_ORIGINS inclut votre domaine
→ Vérifiez l'URL API (pas localhost!)
```

---

## 📞 SUPPORT

Si vous êtes bloqué à une étape:

1. Consultez les logs Railway ("Logs" tab)
2. Vérifiez les variables d'env
3. Testez la base Supabase directement
