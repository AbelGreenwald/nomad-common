job "postgres" {
  datacenters = ["dc1"]
  type        = "service"

  group "postgres" {
    network {
      port "postgres" {
        to = 5432
        static = 5432
        }
    }
    reschedule {
      delay          = "30s"
      delay_function = "constant"
      max_delay      = "90s"
      unlimited      = true
    }
    task "postgres" {
      driver = "podman"
      service {
        tags = ["postgres"]
        port = "postgres"
        provider = "nomad"
      }
      config {
        image = "docker://postgres:14.7"
        volumes = [
          "/mnt/nomad/postgres:/var/lib/postgresql/data",
        ]
        ports = ["postgres"]
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
    #task "telegraf" {
    #  driver = "podman"
    #  user   = "telegraf"
    #  leader = false
    #  config {
    #    image = "docker://telegraf:1.25"
    #    args  = ["--config", "http://172.17.69.100:8086/api/v2/telegrafs/0c4d384f7fd18000"]
    #  }
#
 #     vault {
 #      role = "nomad-postgres"
 #     }

 #     template {
 #       data = <<EOF
 #         INFLUX_TOKEN={{with secret "kv/data/default/postgres/telegraf/config"}}{{.Data.data.INFLUX_TOKEN}}{{ end }}
 #         PG_USER={{with secret "kv/data/default/postgres/telegraf/config"}}{{.Data.data.PG_USER}}{{ end }}
 #         PG_PASSWORD={{with secret "kv/data/default/postgres/telegraf/config"}}{{.Data.data.PG_PASSWORD}}{{ end }}
 #       EOF
 #       destination = "secrets/env"
 #       env         = true
 #     }
 #     lifecycle {
 #       sidecar = true
 #     }
 #     restart {
 #       delay    = "60s"
 #       mode     = "delay"
 #     }
 #     resources {
 #       cpu    = 250
 #       memory = 512
 #     }
 #   }
  }
}
