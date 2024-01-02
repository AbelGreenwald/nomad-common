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
          "/mnt/nomad/plex/config/config:/config",
          "/mnt/nomad/plex/config/transcode:/transcode",
          "/mnt/nomad/plex/config/data:/data",
        ]
      }
      env {
        ADVERTISE_IP = "http://epimetheus:32400/"
        PLEX_UID = 955
        PLEX_GID = 955
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
        args  = ["--config", "http://172.17.69.100:8086/api/v2/telegrafs/0abf36d156954000"]
      }

      vault {}

      template {
        data = <<EOF
          INFLUX_TOKEN={{with secret "kv/data/default/jupyter/config"}}{{.Data.data.INFLUX_TOKEN}}{{ end }}
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
      #resources {
      #  cpu    = 250
      #  memory = 512
      #  device "nvidia/gpu/Tesla" {
      #    count = 1
      #    affinity {
      #      attribute = "${device.model}"
      #      value     = "P100-PCIE-16GB"
      #      weight    = 50
      #    }
      #  }
      #}
    }
  }
}
