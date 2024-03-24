source "azure-arm" "image" {  
  # This section defines my authentication to Azure  
  client_id       = var.client_id
  client_secret   = var.client_secret
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  
  # This section defines where I want to place my image after the build is complete. 
  shared_image_gallery_destination {
    subscription = var.subscription_id
    resource_group = var.resource_group_name
    gallery_name = var.gallery_name
    image_name = var.image_name
    image_version = local.image_version
    replication_regions = ["${var.location}"]
    storage_account_type = "Standard_LRS"
  }

  # This section defines the source image that I want to use to build my image, and also how to connect to the VM to run the build.
  build_resource_group_name = var.resource_group_name
  os_type                   = "Windows"
  image_publisher           =  "microsoftwindowsdesktop"
  image_offer               = "office-365"
  image_sku                 = "win11-23h2-avd-m365"  
  vm_size                   = "Standard_D4s_v5"
  communicator              = "winrm"
  winrm_insecure            = true
  winrm_timeout             = "5m"
  winrm_use_ssl             = true
  winrm_username            = "packer"
  azure_tags                = local.tags
}

build {
  # Here I reference the source that I defined above
  sources = ["source.azure-arm.image"]

  # Here I install the custom software I want in the image
  provisioner "powershell" {
    inline = ["New-Item -ItemType Directory -Path 'c:/Software'",
      "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12",
      "Write-Output 'Installing Visual Studio Code'",
      "Invoke-RestMethod -uri 'https://code.visualstudio.com/sha/download?build=stable&os=win32-x64' -OutFile 'c:/Software/VSCodeSetup-x64-1.87.2.exe'",
      "Start-Process c:/Software/VSCodeSetup-x64-1.87.2.exe -ArgumentList '/VERYSILENT /NORESTART /MERGETASKS=!runcode' -Wait",
      "Write-Output 'Installing Git for Windows'",
      "Invoke-RestMethod -uri 'https://github.com/git-for-windows/git/releases/download/v2.44.0.windows.1/Git-2.44.0-64-bit.exe' -OutFile 'c:/Software/Git-2.44.0-64-bit.exe'",
      "Start-Process c:/Software/Git-2.44.0-64-bit.exe -ArgumentList '/SP- /VERYSILENT /SUPPRESSMSGBOXES /NORESTART' -Wait"
    ]
  }

  # Here I run Windows update
  provisioner "windows-update" {
    search_criteria = "IsInstalled=0"
    filters = [
      "exclude:$_.Title -like '*Preview*'",
      "include:$true",
    ]
    update_limit = 25
  }

  # Here I run sysprep
  provisioner "powershell" {
    inline = ["while ((Get-Service RdAgent).Status -ne 'Running') { Start-Sleep -s 5 }",
     "while ((Get-Service WindowsAzureGuestAgent).Status -ne 'Running') { Start-Sleep -s 5 }",
     "& $env:SystemRoot\\System32\\Sysprep\\Sysprep.exe /oobe /generalize /quiet /quit",
     "while($true) { $imageState = Get-ItemProperty HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Setup\\State | Select ImageState; if($imageState.ImageState -ne 'IMAGE_STATE_GENERALIZE_RESEAL_TO_OOBE') { Write-Output $imageState.ImageState; Start-Sleep -s 10  } else { break } }"]
  }
}