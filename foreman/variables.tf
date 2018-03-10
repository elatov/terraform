variable "vsphere_server" {}
variable "vsphere_user" {}
variable "vsphere_password" {}
variable "vsphere_network" {
  type = "string"
  default = "VM_VLAN3"
}
variable "vm_name" {}
