resource "aws_ec2_client_vpn_endpoint" "vss" {
  count = var.vpn_create ? 1 : 0

  description            = var.vpn_name
  server_certificate_arn = var.vpn_acm_arn
  client_cidr_block      = var.vpn_client_cidr
  split_tunnel           = var.vpn_split_tunnel

  vpc_id             = var.vpn_vpc_id
  security_group_ids = var.vpn_security_groups

  authentication_options {
    type              = "federated-authentication"
    saml_provider_arn = var.vpn_saml_arn
  }

  connection_log_options {
    enabled               = var.vpn_logging_enabled
    cloudwatch_log_group  = var.vpn_cw_group
    cloudwatch_log_stream = var.vpn_cw_stream
  }

  tags = {
    Name = var.vpn_name
  }
}

resource "aws_ec2_client_vpn_network_association" "vss" {
  count = var.vpn_create && var.vpn_association_enabled ? 1 : 0

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vss[0].id
  subnet_id              = var.vpn_association_subnet_id
}

resource "aws_ec2_client_vpn_authorization_rule" "vss" {
  count = var.vpn_create ? length(var.vpn_target_networks) : 0

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vss[0].id
  target_network_cidr    = var.vpn_target_networks[count.index]
  authorize_all_groups   = true
}

resource "aws_ec2_client_vpn_route" "vss" {
  count = (var.vpn_create && var.vpn_association_enabled) ? length(var.vpn_target_networks) : 0

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vss[0].id
  target_vpc_subnet_id   = var.vpn_association_subnet_id
  destination_cidr_block = var.vpn_target_networks[count.index]

  lifecycle {
    ignore_changes = [
      description,
    ]
  }
}
