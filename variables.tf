variable "vpn_create" {
  description = "Whether to create the VPN Endpoint and associated resources."
  type        = bool
  default     = false
}

variable "vpn_name" {
  description = "Name for the VPN endpoint."
  type        = string
  default     = ""
}

variable "vpn_client_cidr" {
  description = "Network range for clients."
  type        = string
  default     = ""
}

variable "vpn_acm_arn" {
  description = "ARN of the ACM certificate."
  type        = string
  default     = ""
}

variable "vpn_saml_arn" {
  description = "ARN of the SAML provider."
  type        = string
  default     = ""
}

variable "vpn_vpc_id" {
  description = "VPC ID where the VPN will be created."
  type        = string
  default     = ""
}

variable "vpn_security_groups" {
  description = "List of SG IDs for the VPN."
  type        = list(string)
  default     = []
}

variable "vpn_split_tunnel" {
  type    = bool
  default = true
}

# --- Logging ---
variable "vpn_logging_enabled" {
  type    = bool
  default = true
}

variable "vpn_cw_group" {
  type    = string
  default = ""
}

variable "vpn_cw_stream" {
  type    = string
  default = ""
}

# --- Networking ---
variable "vpn_association_enabled" {
  description = "Whether to associate the VPN with a subnet."
  type        = bool
  default     = false
}

variable "vpn_association_subnet_id" {
  description = "The subnet to associate with the VPN."
  type        = string
  default     = ""
}

variable "vpn_target_networks" {
  description = "List of CIDR blocks to authorize and route."
  type        = list(string)
  default     = []
}