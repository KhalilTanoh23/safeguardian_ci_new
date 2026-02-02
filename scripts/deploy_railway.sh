#!/usr/bin/env bash
set -euo pipefail

# Script d'aide pour déployer sur Railway.
# Il utilise l'outil en ligne de commande `railway` si installé.

if command -v railway >/dev/null 2>&1; then
  echo "railway CLI détecté — déploiement en cours..."
  # tentative de déployer le projet actuel
  railway up --yes || { echo "railway up a échoué. Consultez les logs."; exit 1; }
  echo "Déploiement Railway terminé (vérifiez l'URL fournie par Railway)."
else
  echo "railway CLI non trouvée. Installez-la depuis https://railway.app/docs/cli ou utilisez l'UI web."
  echo "Alternativement, Railway détecte automatiquement le Dockerfile: poussez votre repo sur GitHub et connectez-le via Railway." 
fi
