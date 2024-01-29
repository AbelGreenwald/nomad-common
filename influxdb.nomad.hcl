job "influxdb" {
  datacenters = ["dc1"]
  type        = "service"
  priority = 100

  group "influxdb" {
    network {
      port "backend" {
        to = 8086
      }
      port "frontend" {
        static = 8087
      }
    }

   service {
      name     = "influx"
      port     = "frontend"
      provider = "nomad"
    }

    reschedule {
      delay          = "30s"
      delay_function = "constant"
      max_delay      = "90s"
      unlimited      = true
    }

    task "influxdb" {
      driver = "podman"

      config {
        image = "docker://influxdb"
        network_mode = "task:nginx"
        ports = ["backend"]
        volumes = ["/mnt/nomad/influxdb:/var/lib/influxdb2"]
      }
      resources {
        cpu    = 1000
        memory = 4096
      }
    }

    task "nginx" {
      driver = "podman"
      leader = false
      config {
        image = "localhost/abelgreenwald/nomad-nginx:1705306811"
        ports = ["frontend"]
      }

      env {
        NGINX_SERVER_NAME = "influx.abelswork.net"
      }
      restart {
        delay    = "30s"
        mode     = "delay"
      }
      resources {
        cpu    = 250
        memory = 128
      }
    }

    #task "telegraf" {
    #  driver = "podman"
    #  user = "telegraf"
    #  leader = false
    #  config {
    #    image = "localhost/abelgreenwald/nomad-telegraf:1704052493"
    #    network_mode = "task:nginx"
    #    args  = ["--config", "http://127.0.0.1:8086/api/v2/telegrafs/0c3f3b011218f000"]
    #  }
#
    #  vault {}
    #  template {
    #    data = <<EOF
    #      INFLUX_TOKEN={{with secret "kv/data/default/jupyter/config"}}{{.Data.data.INFLUX_TOKEN}}{{ end }}
    #    EOF
    #    destination = "secrets/env"
    #    env         = true
    #  }
    #  #restart {
    #  #  delay    = "15s"
    #  #  mode     = "delay"
    #  #}
    #  resources {
    #    cpu    = 250
    #    memory = 128
    #  }
    #}

    #task "fail2ban" {
    #  driver = "podman"
    #  leader = false
    #  config {
    #    image = "localhost/abelgreenwald/jupyter-fail2ban:1704123070"
    #  }
#
    #  env {
    #    F2B_LOG_TARGET = "/alloc/logs/fail2ban.stdout.0"
    #    F2B_LOG_LEVEL = "INFO"
    #    TZ = "US/Central"
    #  }
    #  vault {}
#
    #  template {
    #    data = <<EOF
    #      OPNSENSE_USERNAME={{with secret "kv/data/default/fail2ban/config"}}{{.Data.data.OPNSENSE_USERNAME}}{{ end }}
    #      OPNSENSE_PASSWORD={{with secret "kv/data/default/fail2ban/config"}}{{.Data.data.OPNSENSE_PASSWORD}}{{ end }}
    #    EOF
    #    destination = "secrets/env"
    #    env         = true
    #  }
#
    #  lifecycle {
    #    hook    = "poststart"
    #    sidecar = true
    #  }
    #  restart {
    #    delay    = "30s"
    #    mode     = "delay"
    #  }
    #  resources {
    #    cpu    = 250
    #    memory = 512
    #  }
    #}
  }
}
