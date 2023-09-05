# Provision disks
data "template_file" "linux_provision_vm1" {
  template = file("./scripts/linux_provision_vm.sh")
  vars = {
    password = var.vm_password
  }
}

resource "local_sensitive_file" "linux_provision_vm1" {
  content  = <<EOF
    ${data.template_file.linux_provision_vm1.rendered}
  EOF
  filename = "./linux_provision_vm.sh"

  depends_on = [
    data.template_file.linux_provision_vm1
  ]
}

resource "azurerm_virtual_machine_extension" "provision_linux_vm1" {
  name                 = "provision-linux-ext"
  virtual_machine_id   = var.virtual_machine_id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"

  settings = <<SETTINGS
     {
         "skipDos2Unix":false
     }
 SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
        "script": "${base64encode(local_sensitive_file.linux_provision_vm1.content)}"
    }
 PROTECTED_SETTINGS

}
