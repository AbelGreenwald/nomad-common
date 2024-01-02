job "gpu-test" {
  datacenters = ["dc1"]
  type = "batch"

  group "smi" {
    task "smi" {
      driver = "podman"
      leader = true
      config {
        image = "docker://oguzpastirmaci/gpu-burn"
        command = "1200"
      }

      resources {
        device "nvidia/gpu/Tesla" {
          count = 1
          affinity {
            attribute = "${device.model}"
            value     = "P100-PCIE-16GB"
            weight    = 50
          }
        }
      }
    }


  }
}
