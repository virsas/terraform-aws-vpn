# Terraform AWS VPN Module

A Terraform module for managing an [AWS Client VPN](https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/what-is.html) endpoint with SAML federated authentication. The module creates the Client VPN endpoint, optionally associates it with a subnet, and authorizes and routes the target networks that connected clients are allowed to reach.

## Features

- **Conditional Creation**: Every resource is guarded by the `vpn_create` toggle, so the module can be included but stay inactive.
- **SAML Authentication**: Configures the endpoint for federated authentication against a SAML identity provider ARN.
- **Split Tunnel**: Enables split tunneling by default so only the authorized target networks are routed through the VPN.
- **Connection Logging**: Optionally streams connection logs to a CloudWatch Logs group and stream.
- **Network Association**: Optionally associates the endpoint with a subnet, which creates the target network required for routing.
- **Authorization and Routing**: Creates an authorization rule for every target network CIDR, and a matching route through the associated subnet when association is enabled.

---

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

---

## Usage Examples

### Basic Example

Create a Client VPN endpoint with SAML authentication and connection logging, without associating it with a subnet yet:

```hcl
module "vpn" {
  source = "git::https://github.com/virsas/terraform-aws-vpn.git?ref=v1.1"

  vpn_create      = true
  vpn_name        = "vss-client-vpn"
  vpn_client_cidr = "10.100.0.0/22"
  vpn_vpc_id      = "vpc-0abc123def4567890"

  vpn_acm_arn  = "arn:aws:acm:eu-west-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
  vpn_saml_arn = "arn:aws:iam::123456789012:saml-provider/vss-okta"

  vpn_security_groups = ["sg-0abc123def4567890"]

  vpn_logging_enabled = true
  vpn_cw_group        = "/vss/client-vpn"
  vpn_cw_stream       = "connections"
}
```

### Advanced Example (Subnet Association and Routing)

Associate the endpoint with a subnet and authorize plus route two target networks. Routes are only created when `vpn_association_enabled` is `true`:

```hcl
module "vpn_full" {
  source = "git::https://github.com/virsas/terraform-aws-vpn.git?ref=v1.1"

  vpn_create      = true
  vpn_name        = "vss-client-vpn"
  vpn_client_cidr = "10.100.0.0/22"
  vpn_vpc_id      = "vpc-0abc123def4567890"

  vpn_acm_arn  = "arn:aws:acm:eu-west-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
  vpn_saml_arn = "arn:aws:iam::123456789012:saml-provider/vss-okta"

  vpn_security_groups = ["sg-0abc123def4567890"]
  vpn_split_tunnel    = true

  vpn_logging_enabled = true
  vpn_cw_group        = "/vss/client-vpn"
  vpn_cw_stream       = "connections"

  vpn_association_enabled   = true
  vpn_association_subnet_id = "subnet-0abc123def4567890"

  vpn_target_networks = [
    "10.0.0.0/16",
    "10.1.0.0/16"
  ]
}
```

### Full Tunnel Example (No Split Tunneling)

Route all client traffic through the VPN by disabling split tunneling and authorizing the default route:

```hcl
module "vpn_full_tunnel" {
  source = "git::https://github.com/virsas/terraform-aws-vpn.git?ref=v1.1"

  vpn_create      = true
  vpn_name        = "vss-client-vpn-full"
  vpn_client_cidr = "10.100.0.0/22"
  vpn_vpc_id      = "vpc-0abc123def4567890"

  vpn_acm_arn  = "arn:aws:acm:eu-west-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
  vpn_saml_arn = "arn:aws:iam::123456789012:saml-provider/vss-okta"

  vpn_security_groups = ["sg-0abc123def4567890"]
  vpn_split_tunnel    = false

  vpn_logging_enabled = false

  vpn_association_enabled   = true
  vpn_association_subnet_id = "subnet-0abc123def4567890"

  vpn_target_networks = ["0.0.0.0/0"]
}
```

### Disabled Example

Keep the module in the configuration without creating any resources:

```hcl
module "vpn_disabled" {
  source = "git::https://github.com/virsas/terraform-aws-vpn.git?ref=v1.1"

  vpn_create = false
}
```

---

## Resources

| Name | Type |
|------|------|
| [aws_ec2_client_vpn_endpoint.vss](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_endpoint) | resource |
| [aws_ec2_client_vpn_network_association.vss](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_network_association) | resource |
| [aws_ec2_client_vpn_authorization_rule.vss](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_authorization_rule) | resource |
| [aws_ec2_client_vpn_route.vss](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_route) | resource |

---

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_vpn_create"></a> [vpn\_create](#input\_vpn\_create) | Whether to create the Client VPN endpoint and its associated resources. | `bool` | `false` | no |
| <a name="input_vpn_name"></a> [vpn\_name](#input\_vpn\_name) | Name for the VPN endpoint, used as both its description and its `Name` tag. | `string` | `""` | no |
| <a name="input_vpn_client_cidr"></a> [vpn\_client\_cidr](#input\_vpn\_client\_cidr) | Network range from which client IP addresses are assigned, which must be at least a `/22` and must not overlap with the VPC CIDR. | `string` | `""` | no |
| <a name="input_vpn_acm_arn"></a> [vpn\_acm\_arn](#input\_vpn\_acm\_arn) | ARN of the ACM certificate used as the VPN server certificate. | `string` | `""` | no |
| <a name="input_vpn_saml_arn"></a> [vpn\_saml\_arn](#input\_vpn\_saml\_arn) | ARN of the IAM SAML provider used for federated authentication. | `string` | `""` | no |
| <a name="input_vpn_vpc_id"></a> [vpn\_vpc\_id](#input\_vpn\_vpc\_id) | ID of the VPC where the VPN endpoint will be created. | `string` | `""` | no |
| <a name="input_vpn_security_groups"></a> [vpn\_security\_groups](#input\_vpn\_security\_groups) | List of security group IDs to apply to the VPN endpoint. | `list(string)` | `[]` | no |
| <a name="input_vpn_split_tunnel"></a> [vpn\_split\_tunnel](#input\_vpn\_split\_tunnel) | Whether to enable split tunneling, sending only the authorized target networks through the VPN. | `bool` | `true` | no |
| <a name="input_vpn_logging_enabled"></a> [vpn\_logging\_enabled](#input\_vpn\_logging\_enabled) | Whether to enable connection logging to CloudWatch Logs. | `bool` | `true` | no |
| <a name="input_vpn_cw_group"></a> [vpn\_cw\_group](#input\_vpn\_cw\_group) | Name of the CloudWatch Logs group that receives connection logs. Required when `vpn_logging_enabled` is `true`. | `string` | `""` | no |
| <a name="input_vpn_cw_stream"></a> [vpn\_cw\_stream](#input\_vpn\_cw\_stream) | Name of the CloudWatch Logs stream that receives connection logs. | `string` | `""` | no |
| <a name="input_vpn_association_enabled"></a> [vpn\_association\_enabled](#input\_vpn\_association\_enabled) | Whether to associate the VPN endpoint with a subnet. Routes are only created when this is enabled. | `bool` | `false` | no |
| <a name="input_vpn_association_subnet_id"></a> [vpn\_association\_subnet\_id](#input\_vpn\_association\_subnet\_id) | ID of the subnet to associate with the VPN endpoint. | `string` | `""` | no |
| <a name="input_vpn_target_networks"></a> [vpn\_target\_networks](#input\_vpn\_target\_networks) | List of CIDR blocks to authorize for all groups and, when association is enabled, to route through the associated subnet. | `list(string)` | `[]` | no |

---

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpn_id"></a> [vpn\_id](#output\_vpn\_id) | The ID of the Client VPN endpoint, or an empty string when the endpoint is not created. |
| <a name="output_vpn_arn"></a> [vpn\_arn](#output\_vpn\_arn) | The ARN of the Client VPN endpoint, or an empty string when the endpoint is not created. |
| <a name="output_vpn_dns_name"></a> [vpn\_dns\_name](#output\_vpn\_dns\_name) | The DNS name to be used by clients when establishing the VPN session. |
| <a name="output_vpn_client_cidr"></a> [vpn\_client\_cidr](#output\_vpn\_client\_cidr) | The client CIDR block from which client IP addresses are assigned. |
| <a name="output_vpn_association_id"></a> [vpn\_association\_id](#output\_vpn\_association\_id) | The ID of the network association, or an empty string when association is disabled. |
| <a name="output_vpn_auth_rule_ids"></a> [vpn\_auth\_rule\_ids](#output\_vpn\_auth\_rule\_ids) | List of IDs of the created authorization rules. |
| <a name="output_vpn_route_ids"></a> [vpn\_route\_ids](#output\_vpn\_route\_ids) | List of IDs of the created VPN routes. |

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
