# vcf-mfp.tf

# Define CIDR Variables
variable "bastion_cidrs" {
  description = "CIDR(s) for Jump Hosts external to VCF"
  type        = list(string)
  default     = ["172.61.71.0/24", "10.1.6.0/24"]  # Replace with actual CIDRs
}

variable "vcf01_cidrs" {
  description = "CIDR(s) for VCF01"
  type        = list(string)
  default     = ["10.1.1.0/24"]  # Replace with actual IP addresses or CIDRs
}

variable "automation_tools_cidrs" {
  description = "CIDR(s) for Automation Tools outside VCF"
  type        = list(string)
#                       VPN CIDR ,Horizon CS1, vRNI Proxy 
  default     = ["192.168.3.0/24", "10.1.4.30", "10.1.4.21"]  # Replace with actual CIDRs
}

# Configure the VMware NSX-T Provider using variables
provider "nsxt" {
  host                 = var.nsxIP
  username             = var.nsxUser
  password             = var.nsxPassword
  allow_unverified_ssl = true
}

# Import VMs using nsxt_policy_vm by their name
data "nsxt_policy_vm" "vc01_vms" {
  for_each = toset(["vcva"])  # Replace with the actual list of VMs for VC01 tag
  display_name = each.key
}

data "nsxt_policy_vm" "sddc_vms" {
  for_each = toset(["sddc-mgr"])  # Replace with the actual list of VMs for SDDC tag
  display_name    = each.key
}

data "nsxt_policy_vm" "nsx01_vms" {
  for_each = toset(["nsx-t-mgr"])  # Replace with the actual list of VMs for NSX01 tag
  display_name     = each.key
}

data "nsxt_policy_segment" "vm_management_dvpg" {
  display_name = "Raxus_Prime_VDS.S1-Management-VDS"
}

data "nsxt_policy_service" "https" {
  display_name = "HTTPS"
}
data "nsxt_policy_service" "icmp" {
  display_name = "ICMP ALL"
}
data "nsxt_policy_service" "ssh" {
  display_name = "SSH"
}

# Tag Virtual Machines dynamically based on VM names
resource "nsxt_policy_vm_tags" "vc01_tag_association" {
  for_each = data.nsxt_policy_vm.vc01_vms
  instance_id = each.value.instance_id # VM ID from the list
  
  tag {
    scope = "m01"
    tag   = "vc01"
  }
}

resource "nsxt_policy_vm_tags" "sddc_tag_association" {
  for_each = data.nsxt_policy_vm.sddc_vms

  instance_id  = each.value.instance_id  # VM ID from the list

  tag {
    scope = "m01"
    tag   = "sddc"
  }
}

resource "nsxt_policy_vm_tags" "nsx01_tag_association" {
  for_each = data.nsxt_policy_vm.nsx01_vms

  instance_id = each.value.instance_id # VM ID from the list

  tag {
    scope = "m01"
    tag   = "nsx01"
  }
}

# Define Bastion Group
resource "nsxt_policy_group" "bastion" {
  display_name = "Bastion"
  description  = "CIDR(s) for Jump Hosts external to VCF"

  criteria {
    ipaddress_expression {
      ip_addresses = var.bastion_cidrs
    }
  }
}

# Define VCF01 Group for NSX and DVPGs
resource "nsxt_policy_group" "vcf01" {
  display_name = "VCF01"
  description  = "dvpg = VCF Mgmt WLD, NSX Seg = Aria AVN(s)"

  criteria {
    ipaddress_expression {
      ip_addresses = var.vcf01_cidrs
    }
  }
  
 conjunction {
    operator = "OR"
  }
  criteria {
    path_expression {
      member_paths = [data.nsxt_policy_segment.vm_management_dvpg.path]
    }
  }
  
  conjunction {
    operator = "OR"
  }
  criteria {
    path_expression {
      member_paths = [data.nsxt_policy_segment.ssp_workload_net.path]
    }
  }


}

# Define Critical Management Group with Tag-based Membership
resource "nsxt_policy_group" "critical_management" {
  display_name = "Critical Management"
  description  = "Tag-based membership for critical management components"

  criteria {
    condition {
      key         = "Tag"
      member_type = "VirtualMachine"
      operator    = "EQUALS"
      value       = "m01|vc01"
    }
  }

  criteria {
    condition {
      key         = "Tag"
      member_type = "VirtualMachine"
      operator    = "EQUALS"
      value       = "m01|sddc"
    }
  }

  conjunction {
    operator = "OR"
  }

  criteria {
    condition {
      key         = "Tag"
      member_type = "VirtualMachine"
      operator    = "EQUALS"
      value = "m01|nsx01"
    }
  }
  
  conjunction {
    operator = "OR"
  }
}

# Define Automation Tools Group
resource "nsxt_policy_group" "automation_tools" {
  display_name = "Automation Tools"
  description  = "CIDR(s) of tools outside VCF that need access to SDDC, Manager, vCenter & NSX"

  criteria {
    ipaddress_expression {
      ip_addresses = var.automation_tools_cidrs
    }
  }
}

#Supervizor / SSP

data "nsxt_policy_segment" "ssp_workload_net" {
  display_name = var.ssp_workload_net
}

resource "nsxt_policy_group" "vcf01_ssp" {
  nsx_id       = "VCF01_SSP"
  display_name = "VCF01_SSP"

  criteria {
    path_expression {
      member_paths = [data.nsxt_policy_segment.ssp_workload_net.path]
    }
  }
}

# Define Security Rules

resource "nsxt_policy_security_policy" "automation_tools_to_critical_management" {
  display_name   = "Secure VCF MVP"
  description   = ""
  stateful = true
  category = "Application"
  
  rule {
    display_name   = "Bastion to VCF01"
    action         = "ALLOW"
    source_groups  = [nsxt_policy_group.bastion.path]
    destination_groups = [nsxt_policy_group.vcf01.path]
    services       = [data.nsxt_policy_service.https.path, data.nsxt_policy_service.ssh.path, data.nsxt_policy_service.icmp.path]
    direction      = "IN_OUT"
  }

  rule {
    display_name   = "Automation Tools to Critical Management"
    action         = "ALLOW"
    source_groups  = [nsxt_policy_group.automation_tools.path]
    destination_groups = [nsxt_policy_group.critical_management.path]
    services       = [data.nsxt_policy_service.https.path]
    direction      = "IN_OUT"
  }

  rule {  
    display_name   = "VCF01 to VCF01"
    description = "Allow Any Service"
    action         = "ALLOW"
    source_groups  = [nsxt_policy_group.vcf01.path]
    destination_groups = [nsxt_policy_group.vcf01.path]
    direction      = "IN_OUT"
    }
  rule {
    display_name   = "Critical Management to VCF01"
    description = "Intial rule to monitor traffic to the critical management infrastructure.  Once satisfied, change to DROP."
    action         = "ALLOW"
    destination_groups = [nsxt_policy_group.critical_management.path]
    services       =  [data.nsxt_policy_service.https.path]
    direction      = "IN_OUT"
    logged = true
    log_label = "Monitor-Secure-VCF-MVP"
  }

}

