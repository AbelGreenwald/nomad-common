job "influx-backup" {
  type = "batch"
  priority = 25
  periodic {
    crons             = ["5 2 * * * *"]
    prohibit_overlap = true
    time_zone = "US/Central"
  }
  group "influx-backup" {
    count = 1
    task "influx-backup" {
      driver = "raw_exec"
      resources {
        cores  = 1
        memory = 1024
      }
      config {
        command = "/usr/local/bin/influx-backup.sh"
        args    = []
      }
      env {
        INFLUX_ORG = "self"
        INFLUX_HOST = "http://epimetheus.abelswork.net:8087"
      }
      vault {
        #role = "nomad-backup-workloads"       
      }
      template {
        data = <<EOF
          INFLUX_TOKEN={{with secret "kv/data/default/influx-backup/config"}}{{.Data.data.INFLUX_TOKEN}}{{ end }}
        EOF
        destination = "secrets/env"
        env         = true
      }
    }
  }
}