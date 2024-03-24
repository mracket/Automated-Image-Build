variable "resource_group_name" {
  description = "The name of the resource group in which the resources will be created."
  default     = "rg-automated-image-build"
}
variable "location" {
  description = "The Azure region in which the resources will be created."
  default     = "WestEurope"  
}
variable "gallery_name" {
  description = "The name of the gallery."
  default     = "gal_automated_image_build"  
}
