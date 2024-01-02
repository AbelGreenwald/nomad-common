im broken, do I really want grafana?
job "drawio" {
  datacenters = ["dc1"]
  type        = "service"

  group "drawio" {
    network {
      port "drawio" {
        to = 8080
        static = 8080
        }
    }

    task "drawio" {
      driver = "podman"

      config {
        image = "docker://jgraph/drawio"
        ports = ["drawio"]
      }
      resources {
        cpu    = 500
        memory = 1024
      }
      restart {
        delay    = "30s"
        mode     = "delay"
      }
    }
  }
}
