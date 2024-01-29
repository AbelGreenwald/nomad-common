job "postgres-backup" {
  datacenters = ["dc1"]
  type        = "service"

  group "postgres-backup" {
    network {
      port "postgres-backup" {
        to = 5432
        static = 8432
        }
    }

    task "postgres-backup" {
      driver = "podman"

      config {
        image = "docker://postgres:10.3"
        volumes = [
          "/mnt/nomad/odoo-backup/efs/postgres/pgdata:/var/lib/postgresql/data/pgdata",
        ]
        ports = ["postgres-backup"]
      }
      env {
        POSTGRES_USER = "odoo"
        POSTGRES_DB = "odoo"
        PGDATA = "/var/lib/postgresql/data/pgdata"
      }
      resources {
        cpu    = 2000
        memory = 2048
      }
      restart {
        delay    = "30s"
        mode     = "delay"
      }
    }
  }
}
