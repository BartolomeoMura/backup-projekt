# Automatiserad backup med Terraform & PWSH

**GitHub:** [https://github.com/BartolomeoMura/backup-projekt.git]

Kurs: infrastruktur konfigurering och deployment med programmering.

## 1. Mål

Manuella backuper är  lätta att glömma bort, därför har jag valt att automatisera processen. Backupen görs alltid på samma sätt, gamla bakuper rensas bort automatiskt och skriptet kontrollerar att allt blir rätt.

Projektet är en kedja med två verktyg.

1. **Terraform** skapar miljön: en konfigurationsfil ('config.json') och två exempelfiler som ska säkerhetskopieras.
2. **PowerShell** läser konfigurationen, gör en backup till en zip-fil, rensar gamla bakcuper och veriferar resultatet.

## 2. Tekniker

Teknik och vad jag har använt de till:

Terraform (provider 'local') -> skapar config.json och exempelfiler med variablker och outputs
PowerShell -> Läser config ,skapar backup, rensar bort gamla backuper och veriferar.
JSON -> Skickar inställningar från Terraform till PowerShell.
Git -> Versionshantering.

## 3.Projektstruktur

backup-projekt/
├── terraform/
│   ├── main.tf         # Provider och resurser (3 st local_file)
│   ├── variables.tf    # Variabler: projekt_namn, antal_backuper
│   └── outputs.tf      # Visar sökvägar och inställningar efter apply
├── scripts/
│   └── backup.ps1      # Backup + verifiering
├── .gitignore
└── README.md

Mappen 'miljo/' skapas när projektet körs och finns därför itne i repot.

## 4. Hur kedjan fungerar

1. `terraform apply` skapar 'miljo/config.json' och två textfiler i 'miljo/data'.
2. 'backup.ps1' läser 'config.json' och zippar filerna till 'miljo/backup/backup_datum.zip'.
3. Skriptet tar bort de äldsta backuperna så att det bara finns 'antal_backuper' kvar (3).
4. Skriptet veriferar att zip-filen finns, att den inte är tom och att antalet backuper stämmer.

Skriptet innehåller parametrarna ('-ConfigPath', '-AntalBackuper'), funktionerna ('Read-Config', 'New-Backup', 'Remove-OldBackups', 'Test-Backup'), loopar ('foreach'),
villkor ('if/else') och felhantering i form av ('try/catch').

## 5. Installation och körning

**Krav** Windows med PowerShell 5.1 eller senare och Terraform.

### Steg 1 - Terraform

```powershell
cd terraform
terraform init
terraform apply
```

### Steg 2 – PowerShell

```powershell
cd ..\scripts
powershell .ExecutionPolicy Bypass -File .\backup.ps1
```

### Testa felhanteringen

```powershell
powershell -ExecutionPolicy Bypass -File .\backup.ps1 -ConfigPath "C:\finnsinte.json"
```

**Städa upp:**
Kör 'terraform destroy' i terraform-mappen.

## 6. Resultat

Allt fungerar som förväntat. Efter 'terraform apply' skapas config.json och två exempelfiler. När jag kör 'backup.ps1' och skriptet visar '[OK]' för båda kontrollerna. Om jag kör skriptet fler än tre gånger tar det bort den äldsta backupen automatiskt. Om config.json saknas får man ett tydligt felmeddelande istället för att det kraschar.

## 7. Begränsningar

- Backupen sparas på samma dator som originalfilerna, så om disken går sönder försvinner båda.
- Skriptet körs manuellt och är inte schemalagd.
- Exempelfilerna är skapade av Terraform och står för riktiga filer.

## 8. Reflektion

Det jag har lärt mig mest av är hur två verktyg kan jobba ihop i en kedja. Terraform skapar config.json och PowerShell läser den. Om jag vill ändra något, till exempel antal backuper, ändrar jag bara en variabel i Terraform och behöver inte röra skriptet. Det gör det tydligt varför man skiljer på inställningar och kod. Terraform bestämmer inställningarna och PowerShell bara läser dem, så skriptet är inte hårdkodat för en viss mapp eller ett visst antal backuper.

Om jag skulle bygga vidare skulle jag schemalägga skriptet med Task Scheduler, logga till en fil och spara backuperna på en annan disk, eftersom en backup på samma disk inte skyddar mot att disken går sönder.
