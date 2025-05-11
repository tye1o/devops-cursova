# terraform/local/main.tf
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {
  host = "npipe:////.//pipe//docker_engine"
}

resource "docker_image" "python_app" {
  name = var.container_name
  build {
    context = "../.."
    dockerfile = "Dockerfile"
  }
}

resource "docker_container" "python_app" {
  name  = var.container_name
  image = docker_image.python_app.image_id

  ports {
    internal = var.container_port_internal
    external = var.container_port_external
  }

  env = [
    "FLASK_ENV=${var.app_environment}"
  ]
}

variable "container_name" {
  description = "The name of the Docker container"
  default     = "python-app"
}

variable "container_port_internal" {
  description = "The internal port of the container"
  default     = 3000
}

variable "container_port_external" {
  description = "The external port of the container"
  default     = 3000
}

variable "app_environment" {
  description = "The environment for the app"
  default     = "production"
}

output "container_id" {
  description = "ID of the Docker container"
  value       = docker_container.python_app.id
}

output "container_name" {
  description = "Name of the Docker container"
  value       = docker_container.python_app.name
}

output "image_id" {
  description = "ID of the Docker image"
  value       = docker_image.python_app.id
}

output "access_url" {
  description = "URL to access the application"
  value       = "http://localhost:${var.container_port_external}"
} 