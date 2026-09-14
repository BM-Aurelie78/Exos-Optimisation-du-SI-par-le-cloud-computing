variable "region" {
  description = "Region logique du projet Smart City"
  type        = string
  default     = "vps-local"
}

variable "instance_type" {
  description = "Type logique de l'instance Smart City"
  type        = string
  default     = "docker-small"
}
