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

variable "ssp_workload_net" {default =  "Raxus_Prime_VDS.Workload"}
variable "vm_management_dvpg" {default = "Raxus_Prime_VDS.S1-Management-VDS"}