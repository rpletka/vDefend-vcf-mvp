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

### Define Critical Management Group with Tag-based Membership
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

  criteria {
    condition {
      key         = "Tag"
      member_type = "VirtualMachine"
      operator    = "EQUALS"
      value = "m01|sspi"
    }
  }
  
  conjunction {
    operator = "OR"
  }
}

resource "nsxt_policy_group" "m01_edges" {
  nsx_id       = "M01_EDGES"
  display_name = "M01_EDGES"
  group_type   = "IPAddress"

  criteria {
    ipaddress_expression {
      ip_addresses = ["10.1.1.200-10.1.1.207"]
    }
  }
}

resource "nsxt_policy_group" "m01_hosts" {
  nsx_id       = "M01_HOSTS"
  display_name = "M01_HOSTS"
  group_type   = "IPAddress"

  criteria {
    ipaddress_expression {
      ip_addresses = var.m01_hosts_range
    }
  }
}

#SSP Security Intelligence Group
data "nsxt_policy_segment" "ssp_workload_dvpg" {
  display_name = var.ssp_workload_dvpg
}

resource "nsxt_policy_group" "vcf01_ssp" {
  nsx_id       = "VCF01_SSP"
  display_name = "VCF01_SSP"

  criteria {
    path_expression {
      member_paths = [data.nsxt_policy_segment.ssp_workload_dvpg.path]
    }
  }
}

#Define Aria AVN
data "nsxt_policy_segment" "aria_suite_segment" {
  display_name = var.aria_segment
}

resource "nsxt_policy_group" "aria_suite" {
  nsx_id       = "ARIA_SUITE"
  display_name = "ARIA_SUITE"

  criteria {
    path_expression {
      member_paths = [data.nsxt_policy_segment.aria_suite_segment.path]
    }
  }
}

# Define VCF01 Group for NSX and DVPGs
resource "nsxt_policy_group" "vcf01" {
  display_name = "VCF01"
  description  = "dvpg = VCF Mgmt WLD, NSX Seg = Aria AVN(s)"

  criteria {
    path_expression {
      member_paths = [nsxt_policy_group.critical_management.path,nsxt_policy_group.m01_edges.path,nsxt_policy_group.aria_suite.path,nsxt_policy_group.vcf01_ssp.path]
    }
  }

}
