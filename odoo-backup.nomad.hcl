job "odoo-backup" {
  datacenters = ["dc1"]
  type        = "service"

  group "odoo-backup" {
    network {
      port "odoo-backup" {
        to = 8069
        static = 8070
        }
    }

    task "odoo-backup" {
      driver = "podman"

      config {
        image = "806045647479.dkr.ecr.us-east-2.amazonaws.com/odoo:latest"
        ports = ["odoo-backup"]
        volumes = [
          "/mnt/nomad/odoo-backup/efs/odoo:/mnt/odoo/"
        ]
      }
      env {
        HOST = "epimetheus"
        PORT = 8432
      }
      resources {
        cpu    = 500
        memory = 200
      }

      restart {
        delay    = "30s"
        mode     = "delay"
      }
    }
  }
}
