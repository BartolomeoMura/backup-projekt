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