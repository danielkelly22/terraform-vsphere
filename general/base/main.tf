provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_admin_password
  vsphere_server = var.vsphere_server

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data  "vsphere_compute_cluster" "cluster" {
  name            = var.vsphere_compute_cluster
  datacenter_id   = data.vsphere_datacenter.dc.id 
}

data "vsphere_network" "network" {
  name          = var.vsphere_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name             = var.vsphere_machine_template
  datacenter_id    = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "vm_01" {
  wait_for_guest_net_timeout = "15"
  count                    = var.vm_count
  name                     = "${var.vm_name_01}${format("%02d", count.index+01)}"
  resource_pool_id         = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id 
  folder                   = var.vsphere_vm_folder 
  annotation		       = var.vm_annotation
  guest_id                 = data.vsphere_virtual_machine.template.guest_id
  scsi_type                = data.vsphere_virtual_machine.template.scsi_type
  num_cpus                 = 2
  memory                   = 4096
  firmware                 = "efi"
  efi_secure_boot_enabled  = true
  nested_hv_enabled        = true
  network_interface {
            network_id    = data.vsphere_network.network.id
            #adapter_type  = data.vsphere_virtual_machine.template.network_interface_type[0]
  }
  disk {      
      label 	= "${var.vm_name_01}${format("%02d", count.index+01)}.vmdk"
      size      = data.vsphere_virtual_machine.template.disks.0.size    
      thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }
  
  clone {
      template_uuid = "${data.vsphere_virtual_machine.template.id}"
      timeout = "600"
      customize {
        windows_options {
            computer_name         = "${var.vm_name_01}${format("%02d", count.index+01)}"
            workgroup             = "workgroup"
            admin_password        = var.windows_password
            auto_logon			  = true
			      auto_logon_count      = 3
			      time_zone             = 035
            run_once_command_list = [                   
              "winrm quickconfig -force",
              "winrm set winrm/config @{MaxEnvelopeSizekb=\"100000\"}",
              "winrm set winrm/config/Service @{AllowUnencrypted=\"true\"}",
              "winrm set winrm/config/Service/Auth @{Basic=\"true\"}",
              "netsh advfirewall set allprofiles state off",
              "net stop winrm",
              "sc.exe config winrm start=auto",
              "net start winrm",
              "reg add HKLM\\Software\\Policies\\Microsoft\\Windows\\WinRM\\Client /v AllowBasic /t REG_DWORD /d 1 /f",
			        "reg add HKLM\\Software\\Policies\\Microsoft\\Windows\\WinRM\\Client /v AllowUnencryptedTraffic /t REG_DWORD /d 1 /f",
              "reg add HKLM\\Software\\Policies\\Microsoft\\Windows\\WinRM\\Service /v AllowBasic /t REG_DWORD /d 1 /f",
              "reg add HKLM\\Software\\Policies\\Microsoft\\Windows\\WinRM\\Service /v AllowUnencryptedTraffic /t REG_DWORD /d 1 /f",			
              "powershell.exe -Command Start-Process powershell -Verb runAs",              
              "powershell.exe -Command Install-WindowsFeature -name Web-Server -IncludeManagementTools", 
              "powershell.exe -Command Import-Module WebAdministration",
              "powershell.exe -Command mkdir C:\\Project",
              "powershell.exe -Command Get-WebSite -Name 'Default Web Site' | Remove-WebSite -Confirm:$false -Verbose",
              "powershell.exe -Command New-Website -Name demo -ApplicationPool DefaultAppPool -IPAddress * -PhysicalPath C:\\Project -Port 80",
              "powershell.exe -Command iisreset"
            ]
        }
        network_interface {
            ipv4_address = "10.10.214.${22 + count.index}"
            ipv4_netmask = "24"
            dns_server_list = var.virtual_machine_dns_servers             
        }
        ipv4_gateway = "10.10.214.1" 
        #timeout = "600"       
      }
  }          

}


output "vsphere_private_ip" {
  value = vsphere_virtual_machine.vm_01.*.default_ip_address
}