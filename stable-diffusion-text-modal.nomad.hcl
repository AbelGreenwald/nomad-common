job "influxdb" {
  datacenters = ["dc1"]
  type        = "service"

  group "stable-diffusion" {

    task "stable-diffusion-text" {
      driver = "podman"

      config {
        image = "docker://abelgreenwald/stable-diffusion-1-5-text:latest"
      }
      resources {
        cpu    = 128
        memory = 256
      }
    }
  }
}
