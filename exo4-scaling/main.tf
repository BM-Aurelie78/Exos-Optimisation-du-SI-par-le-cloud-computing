terraform {
  required_version = ">= 1.6.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

resource "docker_image" "smart_city" {
  name = "smart-city-ansible:exo4"

  build {
    context = "."
  }
}

resource "docker_container" "smart_city" {
  name  = "smart-city-web-exo4"
  image = docker_image.smart_city.image_id

  memory = local.selected_profile.memory

  cpu_shares = local.selected_profile.cpu

  ports {
    internal = 22
    external = 12226
    ip       = "127.0.0.1"
  }

  ports {
    internal = 80
    external = 18082
    ip       = "127.0.0.1"
  }

  upload {
    file    = "/home/ansible/.ssh/authorized_keys"
    content = file("${path.module}/authorized_keys")
  }

  command = ["/usr/sbin/sshd", "-D"]

  labels {
    label = "Projet"
    value = "EADL-IaC"
  }

  labels {
    label = "ManagedBy"
    value = "Terraform"
  }
}
