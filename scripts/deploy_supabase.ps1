<#
Script PowerShell pour importer `backend/database/schema_postgresql.sql` vers la base indiquée par la variable d'environnement `DATABASE_URL`.
Usage:
  - Définir la variable d'environnement: $env:DATABASE_URL = 'postgresql://user:pass@host:5432/db'
  - Puis exécuter: .\scripts\deploy_supabase.ps1
#>
param(
    [string]$DatabaseUrl
)

Set-StrictMode -Version Latest

if (-not $DatabaseUrl) {
    $DatabaseUrl = $env:DATABASE_URL
}

if (-not $DatabaseUrl) {
    Write-Error "DATABASE_URL n'est pas défini. Passez-le en paramètre ou exportez `DATABASE_URL` dans l'environnement."
    exit 1
}

$sqlFile = Join-Path -Path (Get-Location) -ChildPath "backend\database\schema_postgresql.sql"
if (-not (Test-Path $sqlFile)) {
    Write-Error "Fichier SQL introuvable: $sqlFile"
    exit 1
}

if (-not (Get-Command psql -ErrorAction SilentlyContinue)) {
    Write-Warning "La commande psql n'a pas été trouvée dans le PATH. Installez PostgreSQL ou ajoutez psql au PATH."
    Write-Host "Tentative d'exécution via psql si disponible..."
}

$escapedUrl = $DatabaseUrl
Write-Host "Importation de $sqlFile vers $escapedUrl"

& psql $escapedUrl -f $sqlFile

Write-Host "Import terminé. Vérifiez Supabase ou les logs psql pour les erreurs."
