variable "name" {
  type = string
}

variable "cidr_block" {
  type = string
}

variable "enable_dns_hostnames" {
  type    = bool
  default = true
}

variable "enable_dns_support" {
  type    = bool
  default = true
}

variable "subnets" {
  type = map(object({
    cidr_block              = string
    availability_zone       = string
    route_tables            = optional(set(string), [])
    vpc_interface_endpoints = optional(set(string), [])
  }))
  default = {}
}

variable "route_tables" {
  type = map(object({
    global_type           = string
    vpc_gateway_endpoints = optional(set(string), [])
  }))
  default = {
    "igw" = {
      global_type = "igw"
    }
  }
}

variable "vpc_interface_endpoints" {
  type = map(object({
    security_groups     = optional(list(string))
    private_dns_enabled = optional(bool, true)
  }))
  default = {}
}

variable "vpc_gateway_endpoints" {
  type = map(object({
    route_tables = optional(set(string), [])
  }))
}

variable "security_groups" {
  type = map(object({
    type                       = string
    allow_global               = optional(bool, false)
    allow_local                = optional(bool, false)
    allow_self                 = optional(bool, false)
    allow_local_subnets        = optional(set(string), [])
    allow_cidr_blocks          = optional(list(string), [])
    allow_local_security_group = optional(string)
    port_range                 = optional(set(number), [])
    protocol                   = string
  }))
  default = {}
}
