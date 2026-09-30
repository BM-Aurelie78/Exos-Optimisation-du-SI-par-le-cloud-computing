variable "project_name" {
  description = "Nom du projet Smart City"
  type        = string
  default     = "smartcity"
}

variable "environment" {
  description = "Environnement de déploiement"
  type        = string
  default     = "exo5"
}

variable "front_network_name" {
  description = "Nom du réseau Docker destiné au front"
  type        = string
  default     = "smartcity-front-net"
}

variable "data_network_name" {
  description = "Nom du réseau Docker interne destiné aux services et aux données"
  type        = string
  default     = "smartcity-data-net"
}

variable "db_name" {
  description = "Nom de la base PostgreSQL Smart City"
  type        = string
  default     = "urbanhub"
}

variable "db_user" {
  description = "Utilisateur PostgreSQL Smart City"
  type        = string
  default     = "urbanhub_user"
}

variable "db_password" {
  description = "Mot de passe PostgreSQL"
  type        = string
  sensitive   = true
}
