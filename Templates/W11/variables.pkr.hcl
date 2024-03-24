variable "resource_group_name" {
  description = "The name of the resource group in which the resources will be created."
  default     = "rg-automated-image-build"
}
variable "location" {
  description = "The Azure region in which the resources will be created."
  default     = "WestEurope"  
}
variable "subscription_id" {
  description = "The subscription ID where the resources are located."
}
variable "gallery_name" {
  description = "The name of the gallery."
  default     = "gal_automated_image_build"  
}
variable "image_name" {
  description = "The name of the image."
  default     = "w11_demo"  
}
variable "tenant_id" {
  description = "The tenant id of my environment."
}
variable "client_id" {
  description = "The client id of the app registration."
}
variable "client_secret" {
  description = "The client secret for the app registration."
}
