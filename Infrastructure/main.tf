resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.tags
}
resource "azurerm_shared_image_gallery" "main" {
  name                = var.gallery_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = local.tags
}
resource "azurerm_shared_image" "main" {
  name                = "w11_demo"
  gallery_name        = azurerm_shared_image_gallery.main.name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Windows"
  hyper_v_generation  = "V2"

  identifier {
    publisher = "microsoftwindowsdesktop"
    offer     = "office-365"
    sku       = "win11-23h2-avd-m365"
  }
}
resource "azuread_application" "main" {
  display_name            = "SP-GitHub-Automated-Image-Build-Demo"
  sign_in_audience        = "AzureADMyOrg"
  prevent_duplicate_names = true
}
resource "azuread_service_principal" "main" {
  client_id = azuread_application.main.client_id
}
resource "azurerm_role_assignment" "main" {
  scope                            = azurerm_resource_group.main.id
  role_definition_name             = "Contributor"
  principal_id                     = azuread_service_principal.main.id
  skip_service_principal_aad_check = true
}
resource "azuread_application_password" "main" {
  application_id = azuread_application.main.id
}
output "client_id" {
  value = azuread_application.main.client_id
}
output "password" {
  value = nonsensitive(azuread_application_password.main.value)
}