
provider "docker" {
  host = "tcp://localhost:2375"
}


resource "docker_container" "docker_in_docker" {
  name  = "docker-in-docker"
  image = "docker:dind"
  privileged = true
  ports {
    internal = 2375
    external = 2375
  }
}


resource "docker_container" "jenkins" {
  name  = "jenkins"
  image = "jenkins:jenkins-blueocean" 
  ports {
    internal = 8080
    external = 8080
  }
  depends_on = [docker_container.docker_in_docker]
}

