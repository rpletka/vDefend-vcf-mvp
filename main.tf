# vcf-mfp.tf

# Configure the VMware NSX-T Provider using variables
provider "nsxt" {
  host                 = var.nsxIP
  username             = var.nsxUser
  password             = var.nsxPassword
  allow_unverified_ssl = true
}
