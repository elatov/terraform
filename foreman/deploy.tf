# Configure the VMware vSphere Provider
provider "vsphere" {
    vsphere_server = "${var.vsphere_server}"
    user = "${var.vsphere_user}"
    password = "${var.vsphere_password}"
    allow_unverified_ssl = true
}

## Build VM
data "vsphere_datacenter" "dc" {
  name = "ha-datacenter"
}

data "vsphere_datastore" "datastore" {
  name          = "datastore1"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_resource_pool" "pool" {}

data "vsphere_network" "vm_lan" {
  name          = "${var.vsphere_network}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_virtual_machine" "vm_1" {
  name                        = "${var.vm_name}"
  resource_pool_id            = "${data.vsphere_resource_pool.pool.id}"
  datastore_id                = "${data.vsphere_datastore.datastore.id}"
  num_cpus                    = 1
  memory                      = 1536
  wait_for_guest_net_timeout  = 0
  guest_id                    = "centos7_64Guest"
  nested_hv_enabled           = true
  boot_retry_enabled          = true
  boot_delay                  = 10000

  network_interface {
   network_id     = "${data.vsphere_network.vm_lan.id}"
   adapter_type   = "vmxnet3"
  }

  disk {
   size             = 16
   label            = "disk0"
   eagerly_scrub    = false
   thin_provisioned = true
  }
  provisioner "local-exec" {
    command = "echo ${self.network_interface.0.mac_address} > mac.txt"
  }

}

## Get the information from the above deployment (just playing around with locals)
locals {
  vm_mac = "${vsphere_virtual_machine.vm_1.network_interface.0.mac_address}"
  vm_name = "${var.vm_name}"
}

## Configure foreman to create a profile for the VM to boot from
resource "null_resource" "foreman" {
  # Connect to foreman
  connection {
    host = "fore.kar.int"
    type = "ssh"
    user = "elatov"
    timeout = "10s"
    private_key="${file("~/.ssh/id_rsa")}"
  }

  provisioner "file" {
    source      = "fore_add_vm.sh"
    destination = "/tmp/fore_add_vm.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/fore_add_vm.sh",
      "/tmp/fore_add_vm.sh ${local.vm_name} ${local.vm_mac}",
    ]
  }

  depends_on = ["vsphere_virtual_machine.vm_1"]

  ## Run during a destroy to delete the host from foreman
  provisioner "file" {
    when        = "destroy"
    source      = "fore_rm_vm.sh"
    destination = "/tmp/fore_rm_vm.sh"
  }

  provisioner "remote-exec" {
    when   = "destroy"
    inline = [
      "chmod +x /tmp/fore_rm_vm.sh",
      "/tmp/fore_rm_vm.sh ${local.vm_name}",
    ]
  }
}
