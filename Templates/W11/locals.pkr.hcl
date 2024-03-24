locals {
  image_version = formatdate("YYYYMMDD.hh.mm", timestamp())
  tags = {
    Environment = "Production"
    Owner       = "Martin"
  }
}