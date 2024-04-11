
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {}

resource "docker_image" "docker_in_docker" {
  name = "docker:dind"
}

resource "docker_container" "docker_in_docker" {
  name       = "docker-in-docker"
  image      = "docker:dind"
  privileged = true
  ports {
    internal = 2375
    external = 2375
  }
  volumes {
    volume_name    = docker_volume.miVolumen.name
    container_path = "/var/www/html"
  }
}

resource "docker_image" "jenkins" {
  name = "jenkins/jenkins:lts"
}

resource "docker_container" "jenkins" {
  name  = "jenkins"
  image = "jenkins/jenkins:lts"
  ports {
    internal = 8081
    external = 8081
  }
  depends_on = [docker_container.docker_in_docker]

  volumes {
    volume_name    = docker_volume.miVolumen.name
    container_path = "/var/www/html"
  }
}


//Creamos un recurso para el volumen de datos
resource "docker_volume" "miVolumen" {
  name = "mi-volumen-docker"
}

