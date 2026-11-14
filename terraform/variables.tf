#För att ändra inställningar utan o ändra main

variable "projekt_namn" {
  description = "Namnet på projektet, används i config.json och exempelfilerna"
  type        = string
  default     = "BackupProjekt"
}

variable "antal_backuper" {
  description = "Hur många backuper som ska sparas innan de äldsta tas bort"
  type        = number
  default     = 3
}