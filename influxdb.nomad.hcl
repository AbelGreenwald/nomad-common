job "influxdb" {
  datacenters = ["dc1"]
  type        = "service"

  group "influxdb" {
    network {
      port "influxdb" {
        to = 8086
        static = 8086
        }
    }

    task "influxdb" {
      driver = "podman"

      config {
        image = "docker://influxdb"
        ports = ["influxdb"]
        volumes = ["/mnt/nomad/influxdb:/var/lib/influxdb2"]
      }
      resources {
        cpu    = 2000
        memory = 1024
      }
      restart {
        delay    = "30s"
        mode     = "delay"
      }
    }
  }
}
