#!/bin/bash

# Script d'installation automatisée sur Railway
# Usage: ./deploy-railway.sh

set -e

echo "═══════════════════════════════════════════════════════════════"
echo "🚀 DÉPLOIEMENT AUTOMATISÉ SAFEGUARDIAN CI SUR RAILWAY"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Vérifier si Railway CLI est installé
if ! command -v railway &> /dev/null; then
    echo "📦 Installation de Railway CLI..."
    npm install -g @railway/cli
fi

echo "✅ Railway CLI trouvé"
echo ""

# Vérifier si l'utilisateur est connecté à Railway
echo "🔐 Vérification de la connexion Railway..."
if ! railway whoami &> /dev/null; then
    echo "⚠️  Vous devez vous connecter à Railway"
    echo "   Exécutez: railway login"
    exit 1
fi

echo "✅ Connecté à Railway"
echo ""

# Créer un nouveau projet
echo "📝 Création d'un nouveau projet Railway..."
PROJECT_NAME="safeguardian-ci-$(date +%s)"
railway init --name "$PROJECT_NAME"

echo "✅ Projet créé: $PROJECT_NAME"
echo ""

# Déployer depuis le Dockerfile
echo "🐳 Déploiement du Dockerfile..."
railway up

echo ""
echo "✅ Déploiement lancé!"
echo ""

# Obtenir l'URL du service
echo "🔗 URL de votre application:"
railway open

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "📋 PROCHAINES ÉTAPES"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "1️⃣  Importer le schéma Supabase:"
echo "   - Ouvrez Supabase → SQL Editor → New Query"
echo "   - Copiez backend/database/schema_postgresql.sql"
echo "   - Exécutez la requête"
echo ""
echo "2️⃣  Configurer les variables d'env Railway:"
echo "   - railway variables set DATABASE_URL=postgresql://..."
echo "   - railway variables set JWT_SECRET=..."
echo ""
echo "3️⃣  Tester l'API:"
echo "   - curl https://your-railway-app.railway.app/api/users"
echo ""
echo "═══════════════════════════════════════════════════════════════"
