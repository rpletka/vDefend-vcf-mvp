variable "nsxIP" {
    type = string
    sensitive = true
}
variable "nsxUser" {
    type = string
    sensitive = true
}
variable "nsxPassword" {
    type = string
    sensitive = true
}

variable "bastion_cidrs" {
  description = "CIDR(s) for Jump Hosts external to VCF"
  type        = list(string)
  default     = ["172.61.71.0/24", "10.1.6.0/24"]
}

variable "vcf01_cidrs" {
  description = "CIDR(s) for VCF01"
  type        = list(string)
  default     = ["10.1.1.1/24"]
}

variable "automation_tools_cidrs" {
  description = "CIDR(s) for Automation Tools outside VCF"
  type        = list(string)
  default     = ["192.168.3.0/24"]
}
variable "ssp_workload_net" {default =  "Raxus_Prime_VDS.Workload"}
variable "vm_management_dvpg" {default = "Raxus_Prime_VDS.S1-Management-VDS"}