# 🚀 GUIDE DE DÉPLOIEMENT COMPLET - SAFEGUARDIAN CI

## État actuel

✅ **Backend PHP** configuré pour PostgreSQL
✅ **Dockerfile** prêt pour Railway
✅ **Schema PostgreSQL** créé (184 lignes)
✅ **Variables d'env** configurées
✅ **Code commité** sur GitHub

---

## 📋 Checklist de déploiement (5 min)

### 1. **Importer le schéma Supabase** (1 min)

```
1. Allez sur: https://nkfglqobowihkfkcozlt.supabase.co
2. Cliquez: SQL Editor → New Query
3. Collez tout le contenu de: backend/database/schema_postgresql.sql
4. Exécutez la requête
5. Vérifiez: les tables apparaissent dans le sidebar
```

### 2. **Créer un compte Railway** (2 min)

```
1. Allez sur: https://railway.app
2. Cliquez: "Login with GitHub"
3. Autorisez l'accès au repo safeguardian_ci_new
```

### 3. **Déployer le backend** (1 min)

```
Sur Railway:
1. "New Project" → "Deploy from GitHub"
2. Sélectionnez: safeguardian_ci_new
3. Railway détecte le Dockerfile automatiquement
4. Attendez ~2-3 min le déploiement
```

### 4. **Configurer les variables d'env Railway** (1 min)

```
Dans Railway (Variables tab):

DATABASE_URL=postgresql://postgres.nkfglqobowihkfkcozlt:%40silentOPS6789%23@aws-1-eu-west-2.pooler.supabase.com:6543/postgres?pgbouncer=true

DB_DRIVER=pgsql

JWT_SECRET=e8f3a2c9d4b7f1e6a3c8d2f5b9a1e4c7d0f3a6b9e2c5f8a1d4e7a0c3f6b9

CORS_ORIGINS=http://localhost:3000,https://app.safeguardian.ci

APP_ENV=production

APP_DEBUG=false
```

### 5. **Tester l'API** (redéploiement auto)

```
Une fois Railway déploie avec les variables, testez:

curl https://[votre-app].railway.app/api/users
```

---

## 🔗 Liens importants

| Service         | URL                                                     |
| --------------- | ------------------------------------------------------- |
| **Supabase**    | https://nkfglqobowihkfkcozlt.supabase.co                |
| **Railway**     | https://railway.app                                     |
| **GitHub**      | https://github.com/[votre-username]/safeguardian_ci_new |
| **Backend API** | https://[your-railway-app].railway.app                  |

---

## 📱 Connecter le frontend Flutter

Quand le backend est déployé sur Railway, mettez à jour le fichier:

**`lib/core/constants/api_constants.dart`**

```dart
const String API_BASE_URL = 'https://[votre-app].railway.app/api';
```

Puis rebuild l'app Flutter.

---

## ✅ Vérification finale

Une fois déployé, vérifiez que:

```bash
# 1. API répond
curl https://[votre-app].railway.app/api/users

# 2. Base de données connectée (pas d'erreur 500)

# 3. CORS configured (requêtes du frontend autorisées)

# 4. JWT fonctionnel (tester login)
```

---

## 🆘 Dépannage

| Problème                  | Solution                                                  |
| ------------------------- | --------------------------------------------------------- |
| **Erreur 500**            | Vérifiez les logs Railway (Logs tab)                      |
| **DATABASE_URL invalide** | Vérifiez l'encoding du mot de passe (`@` → `%40`)         |
| **Schéma vide**           | Importez `schema_postgresql.sql` dans Supabase SQL Editor |
| **CORS bloqué**           | Mettez à jour `CORS_ORIGINS` dans Railway                 |

---

## 📝 Fichiers modifiés

- ✅ `backend/config/database.php` — support pgsql
- ✅ `backend/database/schema_postgresql.sql` — schéma Postgres (NEW)
- ✅ `backend/Dockerfile` — image PHP Alpine (NEW)
- ✅ `railway.toml` — config Railway (NEW)
- ✅ `backend/.env` — DATABASE_URL configurée
- ✅ `deploy-railway.sh` — script auto (Linux/Mac)
- ✅ `deploy-railway.bat` — script auto (Windows)

---

## 🎯 Prochaines étapes après déploiement

1. **Configurer Firebase** (si utilisé)
2. **Tester les endpoints API**
3. **Connecter Flutter au backend**
4. **Mettre en place CI/CD** (Actions GitHub)
5. **Configurer les domaines personnalisés** (optionnel)

---

**✨ Vous êtes prêt! Commencez par importer le schéma Supabase, puis lancez le déploiement Railway.**
