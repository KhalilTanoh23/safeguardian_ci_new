#!/usr/bin/env bash
set -euo pipefail

# Script d'exemple: importe `backend/database/schema_postgresql.sql` dans la base indiquée par DATABASE_URL.

if [ -z "${DATABASE_URL:-}" ]; then
  echo "Erreur: la variable DATABASE_URL n'est pas définie. Exportez-la ou utilisez un fichier .env avant d'exécuter."
  echo "Ex: export DATABASE_URL=\"postgresql://user:pass@host:5432/db\""
  exit 1
fi

SQL_FILE="backend/database/schema_postgresql.sql"

if [ ! -f "$SQL_FILE" ]; then
  echo "Fichier SQL introuvable: $SQL_FILE"
  exit 1
fi

echo "Importation de $SQL_FILE vers $DATABASE_URL"
psql "$DATABASE_URL" -f "$SQL_FILE"

echo "Import terminé. Vérifiez Supabase ou les logs psql pour les erreurs."
