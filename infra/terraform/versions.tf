terraform {
  required_version = ">= 1.5.0"

  cloud {
    organization = "devops-course-varild-jennha"
  }

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 4.6"
    }
  }


}

provider "docker" {
  host = "ssh://deploy@92.222.25.69:22"
}
