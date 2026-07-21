output "vpn_id" {
  value = try(aws_ec2_client_vpn_endpoint.vss[0].id, "")
}
output "vpn_arn" {
  value = try(aws_ec2_client_vpn_endpoint.vss[0].arn, "")
}
output "vpn_dns_name" {
  value = try(aws_ec2_client_vpn_endpoint.vss[0].dns_name, "")
}
output "vpn_client_cidr" {
  value = try(aws_ec2_client_vpn_endpoint.vss[0].client_cidr_block, "")
}
output "vpn_association_id" {
  value = try(aws_ec2_client_vpn_network_association.vss[0].id, "")
}
output "vpn_auth_rule_ids" {
  value = aws_ec2_client_vpn_authorization_rule.vss[*].id
}
output "vpn_route_ids" {
  value = aws_ec2_client_vpn_route.vss[*].id
}