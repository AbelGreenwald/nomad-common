job "opnsense-backup" {
  type = "batch"
  priority = 25
  periodic {
    crons             = ["12 0 * * * *"]
    prohibit_overlap = true
    time_zone = "US/Central"
  }
  group "opnsense-backup" {
    count = 1
    task "opnsense-backup" {
      driver = "raw_exec"
      resources {
        cores  = 1
        memory = 256
      }
      config {
        command = "/usr/local/bin/opnsense-backup.sh"
      }
      env {

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
    }
  }
}