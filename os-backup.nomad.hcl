job "os-backup" {
  type = "batch"
  priority = 25
  periodic {
    crons             = ["3 4 * * * *"]
    prohibit_overlap = true
    time_zone = "US/Central"
  }
  group "os-backup" {
    count = 1
    task "os-backup" {
      driver = "raw_exec"
      resources {
        cores  = 1
        memory = 4096
      }
      config {
        command = "/usr/local/bin/local-backup.sh"
        args    = []
      }
    }
  }
}