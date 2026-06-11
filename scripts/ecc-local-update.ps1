#Requires -Version 5.1
<#
.SYNOPSIS
    Aktualisiert ECC lokal vom persönlichen Fork und reinstalliert alle Targets.

.NOTES
    Wird wöchentlich via Windows Task Scheduler ausgeführt.
    Repo:   D:\Claude\Dev\Ecc-install
    Fork:   https://github.com/Floppy5004/ECC
    Log:    D:\Claude\Dev\Ecc-install\scripts\ecc-update.log
#>

$RepoPath = "D:\Claude\Dev\Ecc-install"
$LogFile  = "D:\Claude\Dev\Ecc-install\scripts\ecc-update.log"
$Now      = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $line = "[$Now] [$Level] $Message"
    Add-Content -Path $LogFile -Value $line -Encoding UTF8
    Write-Host $line
}

Write-Log "=== ECC Local Update gestartet ==="

Set-Location $RepoPath

# Git Pull vom Fork
Write-Log "Git pull von Floppy5004/ECC..."
$pullResult = git pull origin main 2>&1
Write-Log "git pull: $pullResult"

if ($LASTEXITCODE -ne 0) {
    Write-Log "git pull fehlgeschlagen – Abbruch." "ERROR"
    exit 1
}

# Prüfen ob es Änderungen gab
if ($pullResult -match "Already up to date") {
    Write-Log "Keine Änderungen – Reinstall übersprungen."
    Write-Log "=== ECC Local Update abgeschlossen (keine Änderungen) ==="
    exit 0
}

Write-Log "Änderungen gefunden – starte Reinstall..."

# ECC für Claude neu installieren
Write-Log "Reinstall: --target claude..."
$claudeResult = node scripts/auto-update.js --target claude 2>&1
Write-Log "claude: $claudeResult"

# ECC für Codex neu installieren
Write-Log "Reinstall: --target codex..."
$codexResult = node scripts/auto-update.js --target codex 2>&1
Write-Log "codex: $codexResult"

Write-Log "=== ECC Local Update abgeschlossen ==="
