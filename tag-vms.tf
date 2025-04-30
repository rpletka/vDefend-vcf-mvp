# Import VMs using nsxt_policy_vm by their name
data "nsxt_policy_vm" "vc01_vms" {
  for_each = toset(var.nsx_vCenter_vms)  # Replace with the actual list of VMs for VC01 tag
  display_name = each.key
}

data "nsxt_policy_vm" "sddc_vms" {
  for_each = toset(var.nsx_sddc_vm)  # Replace with the actual list of VMs for SDDC tag
  display_name    = each.key
}

data "nsxt_policy_vm" "nsx01_vms" {
  for_each = toset(var.nsx_manager_vms)  # Replace with the actual list of VMs for NSX01 tag
  display_name     = each.key
}

data "nsxt_policy_vm" "sspi_vms" {
  for_each = toset(var.sspi_vms)  # Replace with the actual list of VMs for NSX01 tag
  display_name     = each.key
}

#Tag Virtual Machines dynamically based on VM names
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

resource "nsxt_policy_vm_tags" "sspi_tag_association" {
  for_each = data.nsxt_policy_vm.sspi_vms

  instance_id = each.value.instance_id # VM ID from the list

  tag {
    scope = "m01"
    tag   = "sspi"
  }
}