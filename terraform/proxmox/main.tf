resource "proxmox_virtual_environment_vm" "fedora_vm" {
  name        = "terraform-provider-proxmox-fedora-vm"
  description = "Managed by Terraform"
  tags        = ["terraform", "fedora"]

  node_name = "first-node"
  vm_id     = 4321

  agent {
    # read 'Qemu guest agent' section, change to true only when ready
    enabled = false
  }
  # if agent is not enabled, the VM may not be able to shutdown properly, and may need to be forced off
  stop_on_destroy = true

  startup {
    order      = "3"
    up_delay   = "60"
    down_delay = "60"
  }

  cpu {
    cores        = 2
    type         = "x86-64-v2-AES"  # recommended for modern CPUs
  }

  memory {
    dedicated = 2048
    floating  = 2048 # set equal to dedicated to enable ballooning
  }

  disk {
    datastore_id = "local-lvm"
    import_from  = proxmox_virtual_environment_download_file.latest_fedora_22_jammy_qcow2_img.id
    interface    = "scsi0"
  }

  initialization {
    # uncomment and specify the datastore for cloud-init disk if default `local-lvm` is not available
    # datastore_id = "local-lvm"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      keys     = [trimspace(tls_private_key.fedora_vm_key.public_key_openssh)]
      password = random_password.fedora_vm_password.result
      username = "fedora"
    }

    user_data_file_id = proxmox_virtual_environment_file.cloud_config.id
  }

  network_device {
    bridge = "vmbr0"
  }

  operating_system {
    type = "l26"
  }

  tpm_state {
    version = "v2.0"
  }

  serial_device {}

  virtiofs {
    mapping = "data_share"
    cache = "always"
    direct_io = true
  }
}

resource "proxmox_virtual_environment_download_file" "latest_fedora_22_jammy_qcow2_img" {
  content_type = "import"
  datastore_id = "local"
  node_name    = "pve"
  url = "https://cloud-images.fedora.com/jammy/current/jammy-server-cloudimg-amd64.img"
  # need to rename the file to *.qcow2 to indicate the actual file format for import
  file_name = "jammy-server-cloudimg-amd64.qcow2"
}

resource "random_password" "fedora_vm_password" {
  length           = 16
  override_special = "_%@"
  special          = true
}

resource "tls_private_key" "fedora_vm_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

output "fedora_vm_password" {
  value     = random_password.fedora_vm_password.result
  sensitive = true
}

output "fedora_vm_private_key" {
  value     = tls_private_key.fedora_vm_key.private_key_pem
  sensitive = true
}

output "fedora_vm_public_key" {
  value = tls_private_key.fedora_vm_key.public_key_openssh
}