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