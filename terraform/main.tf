# Create shared Docker network for this environment
resource "docker_network" "environment" {
  name = "network-${var.environment}"
}

# Create Docker volume for PostgreSQL database persistence
resource "docker_volume" "database" {
  name = "database-${var.environment}"
}

# Create Docker image resource for PostgreSQL database
resource "docker_image" "database" {
  name         = var.database_image
  keep_locally = true
}

# Create Docker container for PostgreSQL database
resource "docker_container" "database" {
  name    = "database-${var.environment}"
  image   = docker_image.database.image_id
  restart = "unless-stopped"

  env = [
    "POSTGRES_USER=${var.db_user}",
    "POSTGRES_PASSWORD=${var.db_password}",
    "POSTGRES_DB=${var.db_name}",
  ]

  networks_advanced {
    name    = docker_network.environment.name
    aliases = ["database"]
  }

  volumes {
    volume_name    = docker_volume.database.name
    container_path = "/var/lib/postgresql/data"
  }

  healthcheck {
    test         = ["CMD-SHELL", "pg_isready -U \"$POSTGRES_USER\" -d \"$POSTGRES_DB\""]
    interval     = "5s"
    timeout      = "3s"
    retries      = 20
    start_period = "5s"
  }

  wait         = true
  wait_timeout = 120
}

# Create Docker image resource for the Next.js application
resource "docker_image" "app" {
  name         = var.app_image
  keep_locally = true
}

# Create Docker container for the Next.js application
resource "docker_container" "app" {
  name    = "app-${var.environment}"
  image   = docker_image.app.image_id
  restart = "unless-stopped"

  env = [
    "NODE_ENV=production",
    "DB_HOST=database",
    "DB_PORT=5432",
    "DB_USER=${var.db_user}",
    "DB_PASSWORD=${var.db_password}",
    "DB_NAME=${var.db_name}",
    "SESSION_SECRET=${var.session_secret}",
    "APP_VERSION=${substr(element(reverse(split(":", var.app_image)), 0), 0, 7)}",
    "VIRTUAL_HOST=${var.hostname}",
    "VIRTUAL_PORT=3000",
    "LETSENCRYPT_HOST=${var.hostname}"
  ]

  networks_advanced {
    name = docker_network.environment.name
  }

  networks_advanced {
    name = var.proxy_network
  }

  depends_on = [
    docker_container.database
  ]
}
