<#
Script PowerShell d'aide pour déployer via la CLI Railway.
Usage:
  .\scripts\deploy_railway.ps1
#>
Set-StrictMode -Version Latest

if (Get-Command railway -ErrorAction SilentlyContinue) {
    Write-Host "railway CLI détecté — lancement de 'railway up'..."
    $proc = Start-Process -FilePath railway -ArgumentList 'up', '--yes' -NoNewWindow -Wait -PassThru
    if ($proc.ExitCode -ne 0) {
        Write-Error "railway up a échoué (code $($proc.ExitCode)). Consultez la sortie de la CLI pour plus de détails."
        exit $proc.ExitCode
    }
    Write-Host "Déploiement Railway terminé (vérifiez l'URL fournie par Railway)."
}
else {
    Write-Warning "railway CLI non trouvée. Installez-la depuis https://railway.app/docs/cli ou utilisez l'UI web."
    Write-Host "Alternativement, poussez votre repo sur GitHub et connectez-le via l'UI Railway."
}
