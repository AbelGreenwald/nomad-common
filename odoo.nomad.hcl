job "odoo" {
  datacenters = ["dc1"]
  type        = "service"

  group "odoo" {
    network {
      port "backend" {
        to = 8069
        }
      port "frontend" {
        static = 8069
      }
    }

    task "odoo" {
      driver = "podman"

      config {
        image = "docker://odoo:16"
        ports = ["backend"]
        volumes = [
          "/mnt/nomad/odoo/extra-addons:/mnt/extra-addons",
          "/mnt/nomad/odoo/data:/var/lib/odoo"
        ]
      }
      env {
        HOST = "epimetheus"
      }
      resources {
        cpu    = 1000
        memory = 768
      }

      restart {
        delay    = "30s"
        mode     = "delay"
      }
    }

    task "nginx" {
      driver = "podman"
      leader = false
      config {
        image = "localhost/abelgreenwald/nomad-nginx:1704157376"
        ports = ["frontend"]
      }

      env {
        NGINX_SERVER_NAME = "odoo.abelswork.net"
      }

      resources {
        cpu    = 250
        memory = 128
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
      resources {
        cpu    = 250
        memory = 512
      }
    }
  
    task "fail2ban" {
      driver = "podman"
      leader = false
      config {
        image = "localhost/abelgreenwald/jupyter-fail2ban:1704123070"
      }

      env {
        F2B_LOG_TARGET = "/alloc/logs/fail2ban.stdout.0"
        F2B_LOG_LEVEL = "INFO"
        TZ = "US/Central"
      }
      vault {}

      template {
        data = <<EOF
          OPNSENSE_USERNAME={{with secret "kv/data/default/fail2ban/config"}}{{.Data.data.OPNSENSE_USERNAME}}{{ end }}
          OPNSENSE_PASSWORD={{with secret "kv/data/default/fail2ban/config"}}{{.Data.data.OPNSENSE_PASSWORD}}{{ end }}
        EOF
        destination = "secrets/env"
        env         = true
      }

      lifecycle {
        hook    = "poststart"
        sidecar = true
      }
      restart {
        delay    = "30s"
        mode     = "delay"
      }
      resources {
        cpu    = 250
        memory = 512
      }
    }
  }
}
