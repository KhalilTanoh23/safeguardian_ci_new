# Déploiement Backend SafeGuardian CI sur Railway

## Pré-requis

- Compte GitHub connecté à votre repo
- Compte Railway (gratuit)
- Supabase configuré avec DATABASE_URL

## Étapes de déploiement

### 1. Créer un compte Railway

- Allez sur https://railway.app
- Connectez-vous avec GitHub
- Créez un nouveau projet

### 2. Connecter le repo GitHub

- Dans Railway: "New Project" → "Deploy from GitHub"
- Sélectionnez votre repo `safeguardian_ci_new`
- Autorisez l'accès

### 3. Configurer les variables d'environnement

Dans Railway, allez dans "Variables":

```
DATABASE_URL=postgresql://postgres.nkfglqobowihkfkcozlt:%40silentOPS6789%23@aws-1-eu-west-2.pooler.supabase.com:6543/postgres?pgbouncer=true
DB_DRIVER=pgsql
JWT_SECRET=e8f3a2c9d4b7f1e6a3c8d2f5b9a1e4c7d0f3a6b9e2c5f8a1d4e7a0c3f6b9
CORS_ORIGINS=http://localhost:3000,https://app.safeguardian.ci
APP_ENV=production
APP_DEBUG=false
```

### 4. Déployer

Railway détectera automatiquement le `Dockerfile` et déploiera.

### 5. Importer le schéma Supabase (une seule fois)

- Ouvrez Supabase → SQL Editor
- Copiez le contenu de `backend/database/schema_postgresql.sql`
- Exécutez la requête
- Vérifiez que les tables sont créées

### 6. Tester

Une fois déployé, Railway vous donnera une URL :

```
https://your-app.up.railway.app
```

Testez un endpoint :

```bash
curl https://your-app.up.railway.app/api/users
```

## Dépannage

- **Erreur de connexion**: Vérifiez `DATABASE_URL` dans Railway vs Supabase
- **Erreur 500**: Vérifiez les logs Railway ("Logs" tab)
- **Schéma vide**: Importez `schema_postgresql.sql` dans Supabase

## Prochaines étapes

1. Connecter le frontend Flutter à l'URL de l'API Railway
2. Mettre à jour `CORS_ORIGINS` dans Railway si nécessaire
3. Configurer les variables Firebase (si utilisé)
