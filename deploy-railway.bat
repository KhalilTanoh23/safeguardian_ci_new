@echo off
REM Script de configuration Railway sur Windows

echo.
echo ===============================================================
echo 🚀 CONFIGURATION RAILWAY - SAFEGUARDIAN CI
echo ===============================================================
echo.

REM Vérifier si Railway CLI est installé
where railway >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo 📦 Railway CLI non trouvé. Installation...
    npm install -g @railway/cli
)

echo ✅ Railway CLI trouvé
echo.

REM Vérifier la connexion
echo 🔐 Vérification de la connexion Railway...
railway whoami >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ⚠️  Vous devez vous connecter à Railway
    echo    Exécutez: railway login
    pause
    exit /b 1
)

echo ✅ Connecté à Railway
echo.

REM Initialiser le projet
echo 📝 Initialisation du projet Railway...
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c%%a%%b)
for /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set mytime=%%a%%b)
set PROJECT_NAME=safeguardian-ci-%mydate%-%mytime%

railway init --name "%PROJECT_NAME%"

echo ✅ Projet créé: %PROJECT_NAME%
echo.

REM Déployer
echo 🐳 Déploiement en cours...
railway up

echo.
echo ===============================================================
echo 📋 PROCHAINES ÉTAPES
echo ===============================================================
echo.
echo 1. Importer le schéma Supabase (SQL Editor)
echo 2. Configurer les variables d'env: railway variables set KEY=VALUE
echo 3. Tester: curl https://your-app.railway.app/api/users
echo.
echo ===============================================================
pause
