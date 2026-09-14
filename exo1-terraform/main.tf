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

resource "docker_image" "smart_city_web" {
  name         = "nginx:alpine"
  keep_locally = false
}

resource "docker_container" "smart_city_web" {
  name  = "smart-city-web"
  image = docker_image.smart_city_web.image_id

  labels {
    label = "Projet"
    value = "EADL-IaC"
  }

  labels {
    label = "Region"
    value = var.region
  }

  labels {
    label = "InstanceType"
    value = var.instance_type
  }

  ports {
    internal = 80
    external = 18080
    ip       = "127.0.0.1"
  }
}
