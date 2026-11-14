#Värdena att skrivas ut efter apply. 

output "config_fil" {
  description = "Sökväg till konfigurationsfilen"
  value       = abspath(local_file.config.filename)
}

output "kalla_mapp" {
  description = "Mappen som ska säkerhetkopieras"
  value       = abspath("${path.module}/../miljo/data")
}

output "antal_backuper" {
  description = "Antal backuper som sparas"
  value       = var.antal_backuper
}