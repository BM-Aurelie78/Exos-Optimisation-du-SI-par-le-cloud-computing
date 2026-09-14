output "ip_publique" {
  description = "Point d'acces HTTP du serveur Smart City en mode VPS Docker"
  value       = "http://127.0.0.1:18080"
}

output "nom_instance" {
  description = "Nom de l'instance Smart City"
  value       = docker_container.smart_city_web.name
}
