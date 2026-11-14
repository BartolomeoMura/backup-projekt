# Skapandet av miljön för pwsh

terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

provider "local" {}

#Resurs 1: konf fil till pwsh

resource "local_file" "config" {
  filename = "${path.module}/../miljo/config.json"
  content = jsonencode({
    projekt_namn   = var.projekt_namn
    kalla_mapp     = abspath("${path.module}/../miljo/data")
    backup_mapp    = abspath("${path.module}/../miljo/backup")
    antal_backuper = var.antal_backuper
  })
}

#Resurs 2: fil att kopieras.

resource "local_file" "rapport" {
  filename = "${path.module}/../miljo/data/rapport.txt"
  content  = "Månadsrapport för ${var.projekt_namn}. Skapad av Terraform."
}

#Resurs 3: andra filen. 

resource "local_file" "anteckningar" {
  filename = "${path.module}/../miljo/data/anteckningar.txt"
  content  = "Anteckningar för ${var.projekt_namn}. Skapad av Terraform."
}

