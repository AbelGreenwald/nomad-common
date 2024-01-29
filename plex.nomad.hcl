job "plex" {
  datacenters = ["dc1"]
  type        = "service"

  group "plex" {
    network {
      port "plex" {
        to = 32400
        static = 32400
      }
    }

    service {
      name     = "plex"
      port     = "plex"
      provider = "nomad"
    }

    task "plex" {
      driver = "podman"

      config {
        image = "docker://plexinc/pms-docker:latest"
        network_mode = "host"
        ports = [
          "plex"
        ]
        volumes = [
          "/mnt/plex/config:/config",
          "/mnt/plex/transcode:/transcode",
          "/mnt/plex/data:/data",
        ]
      }
      env {
        ADVERTISE_IP = "http://epimetheus:32400/"
        PLEX_UID = 955
        PLEX_GID = 955
      }

      resources {
        cpu    = 1000
        memory = 2048
        device "nvidia/gpu" {
            affinity {
              attribute = "${device.model}"
              value     = "GeForce GTX 1080"
              weight    = 100
            }
          count = 1
        }
      }

      vault {}

      template {
        data = <<EOF
          PLEX_CLAIM={{with secret "kv/data/default/plex/config"}}{{.Data.data.PLEX_CLAIM}}{{ end }}
        EOF
        destination = "secrets/env"
        env         = true
      }

      restart {
        delay    = "30s"
        mode     = "delay"
      }
    }

    task "telegraf" {
      driver = "podman"
      user = "telegraf"
      config {
        image = "docker://telegraf:1.25"
        args  = ["--config", "https://influx.abelswork.net/api/v2/telegrafs/0abf36d156954000"]
      }

      vault {}

      template {
        data = <<EOF
          INFLUX_TOKEN={{with secret "kv/data/default/plex/config"}}{{.Data.data.INFLUX_TOKEN}}{{ end }}
        EOF
        destination = "secrets/env"
        env         = true
      }
      lifecycle {
        sidecar = true
      }
      restart {
        delay    = "30s"
        mode     = "delay"
      }
    }
  }
}
