packer {
  required_plugins {
    docker = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/docker"
    }
  }
}

source "docker" "ubuntu-smart-city" {
  image  = "ubuntu:22.04"
  commit = true
}

build {
  name    = "smart-city-golden-image"
  sources = ["source.docker.ubuntu-smart-city"]

  provisioner "shell" {
    inline = [
      "apt-get update",
      "DEBIAN_FRONTEND=noninteractive apt-get install -y python3 python3-pip git curl ca-certificates",
      "python3 --version",
      "pip3 --version",
      "git --version"
    ]
  }

  post-processor "docker-tag" {
    repository = "smart-city-golden"
    tags       = ["1.0"]
  }
}
