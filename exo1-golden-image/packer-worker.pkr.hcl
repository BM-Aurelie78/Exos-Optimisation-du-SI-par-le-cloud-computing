packer {
  required_plugins {
    docker = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/docker"
    }
  }
}

source "docker" "ubuntu-smart-city-worker" {
  image  = "ubuntu:22.04"
  commit = true
}

build {
  name    = "smart-city-worker-image"
  sources = ["source.docker.ubuntu-smart-city-worker"]

  provisioner "shell" {
    inline = [
      "apt-get update",
      "DEBIAN_FRONTEND=noninteractive apt-get install -y python3 python3-pip git curl ca-certificates",
      "pip3 install pika",
      "python3 --version",
      "python3 -c \"import pika; print(pika.__version__)\""
    ]
  }

  post-processor "docker-tag" {
    repository = "smart-city-worker"
    tags       = ["1.0"]
  }
}
