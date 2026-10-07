output "app_container_name" {
  value = docker_container.app.name
}

output "database_container_name" {
  value = docker_container.database.name
}

output "database_volume_name" {
  value = docker_volume.database.name
}
