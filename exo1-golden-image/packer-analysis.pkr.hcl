packer {
  required_plugins {
    docker = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/docker"
    }
  }
}

source "docker" "ubuntu-smart-city-analysis" {
  image  = "ubuntu:22.04"
  commit = true
}

build {
  name    = "smart-city-analysis-image"
  sources = ["source.docker.ubuntu-smart-city-analysis"]

  provisioner "shell" {
    inline = [
      "apt-get update",
      "DEBIAN_FRONTEND=noninteractive apt-get install -y python3 python3-pip git curl ca-certificates",
      "pip3 install pika fastapi uvicorn",
      "python3 --version",
      "python3 -c \"import pika; print('pika', pika.__version__)\"",
      "python3 -c \"import fastapi; print('fastapi', fastapi.__version__)\""
    ]
  }

  post-processor "docker-tag" {
    repository = "smart-city-analysis"
    tags       = ["1.0"]
  }
}
