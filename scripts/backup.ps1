#Läser config.json, säkerhetskopierar till zip, rensar o veriferar.

param(
    #sökväg till config.json
    [string]$ConfigPath = "$PSScriptRoot\..\miljo\config.json",

    #antal backuper o spara.
    [int]$AntalBackuper = 0
)

#Stop & try & catch
$ErrorActionPreference = "Stop"

#Läser config.json o gör om till pwsh objekt
function Read-Config {
    param(
        [string]$Path
    )
    if (-Not (Test-Path $Path)) {
        throw "Hittar ej $Path. Har du kört 'Terraform Apply'?"
    }
    return Get-Content $Path -Raw | ConvertFrom-Json
}

#Skapar zip med filerna i källan.

function New-Backup {
    param([string]$Kalla, [string]$Mal)

    #Sakapa backup-mappen om den itne finns.
    if (-not (Test-Path $Mal)) {
        New-Item -ItemType Directory -Path $Mal | Out-Null
        Write-Host "Skapade backup-mappen $Mal"
    }

    $filer = Get-ChildItem -Path $Kalla -File
    if ($filer.Count -eq 0) {
        throw "Källmappen $Kalla är tom, inget att säkerhetskopiera."
    }

    #visar fler som tas med
    foreach ($fil in $filer) {
        Write-Host "  + $($fil.Name) ($($fil.Length) byte)"
    }

    $datum = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $zipFil = Join-Path $Mal "backup_$datum.zip"
    Compress-Archive -Path $filer.FullName -DestinationPath $zipFil
    return $zipFil
}

#Tar bort älder backuper

function Remove-OldBackups {
    param([string]$Mal, [int]$Antal)

    $backuper = Get-ChildItem -Path $Mal -Filter "backup_*.zip" | Sort-Object LastWriteTime -Descending
    
    if ($backuper.Count -gt $Antal) {
        $attTaBort = $backuper | Select-Object -Skip $Antal
        foreach ($gammal in $attTaBort) {
            Remove-Item $gammal.FullName
            Write-Host "Tog bort gammal backup: $($gammal.Name)" -ForegroundColor Yellow
        }
       
    }
}

#Backup kontroll

function Test-Backup {
    param([string]$ZipFil, [string]$Mal, [int]$Antal)

    $ok = $true

    if ((Test-Path $ZipFil) -and ((Get-Item $ZipFil).Length -gt 0 )) {
        Write-Host "[OK] Zip-Filen finns och är inte tom" -ForegroundColor Green
    }
    else {
        Write-Host "[FEL] Zip-Filen finns ej eller är tom" -ForegroundColor Red
        $ok = $false
    }

    $antalNu = (Get-ChildItem -Path $Mal -Filter "backup_*.zip").Count
    if ($antalNu -le $Antal) {
        Write-Host "[OK] $antalNu av max $Antal backuper sparade" -ForegroundColor Green
    }
    else {
        Write-Host "[FEL] För många backuper: $antalNu (max $Antal)" -ForegroundColor Red
        $ok = $false
    }
    return $ok    
}

#Huvudprogram
try {
    Write-Host "=== Startar backup ===" -ForegroundColor Cyan

    $config = Read-Config -Path $ConfigPath
    Write-Host "Projekt: $($config.projekt_namn)"

    #Om ingen parameter, config.json.
    if ($AntalBackuper -le 0) {
        $AntalBackuper = $config.antal_backuper
    }
    
    $zip = New-Backup -Kalla $config.kalla_mapp -Mal $config.backup_mapp
    Write-Host "Backup skapad : $zip" -ForegroundColor Green

    Remove-OldBackups -Mal $config.backup_mapp -Antal $AntalBackuper

    Write-Host "=== Verifierar ===" -ForegroundColor Cyan
    if (Test-Backup -ZipFil $zip -Mal $config.backup_mapp -Antal $AntalBackuper) {
        Write-Host "Backup lyckades!" -ForegroundColor Green
        exit 0
    }
    else {
        Write-Host "Veriferingen misslyckades." -ForegroundColor Red
        exit 1
    }
}
catch {
    Write-Host "FEL: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}