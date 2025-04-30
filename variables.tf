variable "nsxIP" {
    type = string
    sensitive = true
    default = "nsx-mgr"
}
variable "nsxUser" {
    type = string
    sensitive = true
    default = "admin"
}
variable "nsxPassword" {
    type = string
    sensitive = true
    default = "VMware1!VMware1!"
}

# Define CIDR Variables
variable "bastion_cidrs" {
  description = "CIDR(s) for Jump Hosts external to VCF"
  type        = list(string)
  #               VDI, VPN CIDRs
  default     = ["10.1.6.0/24", "192.168.3.0/24"]  # Replace with actual CIDRs
}

variable "vcf01_cidrs" {
  description = "CIDR(s) for VCF01"
  type        = list(string)
  default     = ["10.1.1.0/24"]  # Replace with actual IP addresses or CIDRs
}

variable "automation_tools_cidrs" {
  description = "CIDR(s) for Automation Tools outside VCF"
  type        = list(string)
#                   Horizon Connection Server, vRNI Proxy, vROps, SSP/Security Intelligence
  default     = ["10.1.4.30", "10.1.4.21", "10.1.4.10"]  # Replace with actual CIDRs
}



variable "ssp_workload_dvpg" {default =  "Raxus_Prime_VDS.Workload"}
variable "vm_management_dvpg" {default = "Raxus_Prime_VDS.S1-Management-VDS"}
variable "aria_segment" {default = "S1-Servers"}
variable m01_hosts_range {default = ["10.1.1.10-10.1.1.13"]}
variable "m01_edges_range" {default = ["10.1.1.200-10.1.1.207"]}
variable "m01_ssp_dvpg"  {default = "m01-cl01-vds01.vlan-1640"}
variable nsx_sddc_vm {default = ["sddc-mgr"]}
variable nsx_vCenter_vms {default = ["vcva"]}
variable nsx_manager_vms {default = ["nsx-t-mgr"]}
variable sspi_vms {default = ["sspi"]}