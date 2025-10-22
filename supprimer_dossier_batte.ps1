# Script PowerShell pour supprimer le dossier batte vide
# Exécute ce script APRÈS avoir fermé Cursor

Write-Host "🗑️  Suppression du dossier 'batte' vide..." -ForegroundColor Yellow
Write-Host ""

# Vérifie le chemin actuel
$currentPath = Get-Location
Write-Host "📂 Dossier actuel : $currentPath" -ForegroundColor Cyan

# Chemin du dossier à supprimer
$batteFolder = "batte"

# Vérifie si le dossier existe
if (Test-Path $batteFolder) {
    Write-Host "✅ Le dossier '$batteFolder' existe." -ForegroundColor Green
    
    # Vérifie si le dossier est vide
    $items = Get-ChildItem -Path $batteFolder -Force
    if ($items.Count -eq 0) {
        Write-Host "✅ Le dossier est vide." -ForegroundColor Green
        
        # Tente de supprimer
        try {
            Remove-Item -Path $batteFolder -Recurse -Force -ErrorAction Stop
            Write-Host "✅ Dossier '$batteFolder' supprimé avec succès !" -ForegroundColor Green
            Write-Host ""
            Write-Host "🎉 Réorganisation terminée !" -ForegroundColor Magenta
        }
        catch {
            Write-Host "❌ Erreur : Impossible de supprimer le dossier." -ForegroundColor Red
            Write-Host "💡 Le dossier est utilisé par un autre processus." -ForegroundColor Yellow
            Write-Host ""
            Write-Host "🔧 Solutions :" -ForegroundColor Yellow
            Write-Host "   1. Ferme Cursor complètement" -ForegroundColor White
            Write-Host "   2. Arrête tous les processus Flutter :" -ForegroundColor White
            Write-Host "      taskkill /F /IM flutter.exe" -ForegroundColor Gray
            Write-Host "      taskkill /F /IM dart.exe" -ForegroundColor Gray
            Write-Host "   3. Réexécute ce script" -ForegroundColor White
            Write-Host ""
            Write-Host "   Ou supprime manuellement via l'Explorateur Windows." -ForegroundColor White
        }
    }
    else {
        Write-Host "⚠️  Le dossier n'est pas vide ! Il contient $($items.Count) élément(s)." -ForegroundColor Red
        Write-Host "📋 Contenu :" -ForegroundColor Yellow
        $items | ForEach-Object { Write-Host "   - $_" -ForegroundColor Gray }
    }
}
else {
    Write-Host "✅ Le dossier '$batteFolder' n'existe pas (déjà supprimé)." -ForegroundColor Green
    Write-Host "🎉 Réorganisation terminée !" -ForegroundColor Magenta
}

Write-Host ""
Write-Host "Appuie sur une touche pour fermer..." -ForegroundColor Cyan
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

