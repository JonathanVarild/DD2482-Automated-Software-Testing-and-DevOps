variable "hostname" {
  description = "Hostname for this deployment"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
}

variable "app_image" {
  description = "Docker image containing the Next.js application"
  type        = string
}

variable "database_image" {
  description = "Docker image containing PostgreSQL and the initial schema"
  type        = string
}

variable "db_user" {
  type      = string
  default   = "app"
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_name" {
  type      = string
  default   = "app"
  sensitive = true
}

variable "session_secret" {
  type      = string
  sensitive = true
}

variable "proxy_network" {
  type    = string
  default = "proxy"
}
