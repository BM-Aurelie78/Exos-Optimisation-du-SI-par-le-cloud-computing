packer {
  required_plugins {
    docker = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/docker"
    }
  }
}

source "docker" "ubuntu-smart-city-api" {
  image  = "ubuntu:22.04"
  commit = true
}

build {
  name    = "smart-city-api-image"
  sources = ["source.docker.ubuntu-smart-city-api"]

  provisioner "shell" {
    inline = [
      "apt-get update",
      "DEBIAN_FRONTEND=noninteractive apt-get install -y python3 python3-pip git curl ca-certificates",
      "pip3 install fastapi uvicorn",
      "python3 --version",
      "python3 -c \"import fastapi; print(fastapi.__version__)\"",
      "python3 -c \"import uvicorn; print(uvicorn.__version__)\""
    ]
  }

  post-processor "docker-tag" {
    repository = "smart-city-api"
    tags       = ["1.0"]
  }
}
