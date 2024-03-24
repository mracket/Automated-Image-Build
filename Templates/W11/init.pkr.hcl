packer {
  required_plugins {
    windows-update = {
      version = "0.15.0"
      source = "github.com/rgl/windows-update"
    }
    azure = {
      version = ">= 2.0.4"
      source  = "github.com/hashicorp/azure"
    }
  }
}