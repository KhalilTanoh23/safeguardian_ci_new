# Déploiement sur Supabase

Ce document explique comment préparer et initialiser la base de données Supabase pour l'application SafeGuardian CI.

Pré-requis

- Compte Supabase (https://app.supabase.com)
- `psql` installé localement (ou utilisez l'éditeur SQL intégré Supabase)
- Accès au repo contenant `backend/database/schema_postgresql.sql`

Étapes

1. Créer un projet Supabase
   - Depuis le tableau de bord Supabase, cliquez sur "New project".
   - Notez l'URL du projet (`SUPABASE_URL`) et la `anon` ou `service_role` key selon l'usage.

2. Récupérer la chaîne de connexion PostgreSQL
   - Dans Supabase, allez dans "Settings → Database" puis copiez la `Connection string` (format `postgresql://...`).
   - Mettez cette valeur dans la variable d'environnement `DATABASE_URL` (voir `backend/.env.example`).

3. Importer le schéma
   - Option A (éditeur SQL Supabase) : ouvrez "SQL Editor", collez le contenu de `backend/database/schema_postgresql.sql` et exécutez.
   - Option B (ligne de commande) : si vous avez `psql` et la variable `DATABASE_URL` :

```bash
export DATABASE_URL="postgresql://..."
psql "$DATABASE_URL" -f backend/database/schema_postgresql.sql
```

4. Configurer les variables d'environnement
   - Ajoutez les valeurs nécessaires (voir `backend/.env.example`) dans Railway ou dans la configuration de votre backend si vous l'hébergez ailleurs.

5. Vérifier
   - Connectez-vous au tableau Supabase → Table Editor et vérifiez que les tables existent.

Remarques

- Pour les environnements de production, utilisez la `service_role` key avec prudence (ne la mettez pas côté client).
- Supabase propose aussi un backup/restore pour importer un dump si nécessaire.

Scripts fournis

- `scripts/deploy_supabase.sh` : script d'exemple pour exécuter le fichier SQL vers la base indiquée par `DATABASE_URL`.
- `scripts/deploy_supabase.sh` : script d'exemple pour exécuter le fichier SQL vers la base indiquée par `DATABASE_URL`.
- `scripts/deploy_supabase.ps1` : version PowerShell (Windows) pour importer le schéma via `psql`.

Exécution (PowerShell):

```powershell
# Dans PowerShell
$env:DATABASE_URL = 'postgresql://user:pass@host:5432/db'
.\scripts\deploy_supabase.ps1
```
