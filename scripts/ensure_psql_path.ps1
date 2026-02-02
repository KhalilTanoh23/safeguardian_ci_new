$p = 'C:\Program Files\PostgreSQL\15\bin'
if (Test-Path $p) {
    $env:Path = $env:Path + ';' + $p
    Write-Host "Added to session PATH: $p"
    try {
        & "$p\psql.exe" --version
    }
    catch {
        Write-Error "psql executable not found at $p"
    }
}
else {
    Write-Error "Path not found: $p"
}
