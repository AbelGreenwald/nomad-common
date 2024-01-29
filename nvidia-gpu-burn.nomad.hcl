job "gpu-test" {
  datacenters = ["dc1"]
  type = "batch"

  group "smi" {
    task "smi" {
      driver = "podman"
      leader = true
      config {
        image = "docker://oguzpastirmaci/gpu-burn"
        command = "60"
      }

      resources {
        cpu    = 1000
        memory = 2048
        device "nvidia/gpu" {
            affinity {
              attribute = "${device.model}"
              #value     = "GeForce GTX 1080"
              value     = "P100-PCIE-16GB"
              weight    = 50
            }
          count = 1
        }
      }
    }


  }
}
