resource "docker_network" "front" {
  name = var.front_network_name
}

resource "docker_network" "data" {
  name     = var.data_network_name
  internal = true
}
