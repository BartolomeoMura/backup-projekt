# Skapandet av miljön för pwsh

terraform {
    required_providers {
        local = {
            source = "hashicorp/local"
            version = "~> 2.5"
        }
    }
}

provider "local" {}

#Resurs 1 konf fil till pwsh

resource "local_file" "config" {
    filename = "${path.module}/../miljo/config.json"
    content = jsonencode({
        projekt_namn = var.projekt_namn
        kalla_mapp = abspath("${path.module}/../miljo/data")
        backup_mapp = abspath("${path.module}/../miljo/backup")
        antal_backuper = var.antal_backuper
    })
}