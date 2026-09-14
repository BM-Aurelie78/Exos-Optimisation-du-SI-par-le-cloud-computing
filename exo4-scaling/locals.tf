locals {
  instance_profiles = {
    small = {
      memory = 256
      cpu    = 256
    }

    medium = {
      memory = 512
      cpu    = 512
    }

    large = {
      memory = 1024
      cpu    = 1024
    }
  }

  selected_profile = local.instance_profiles[var.instance_size]
}
