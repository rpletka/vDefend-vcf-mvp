data "nsxt_policy_service" "https" {
  display_name = "HTTPS"
}
data "nsxt_policy_service" "icmp" {
  display_name = "ICMP ALL"
}
data "nsxt_policy_service" "ssh" {
  display_name = "SSH"
}