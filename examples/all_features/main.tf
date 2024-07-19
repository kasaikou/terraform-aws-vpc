module "vpc" {
  source     = "../.."
  name       = "kasaikou-test"
  cidr_block = "10.0.0.0/16"
  subnets = {
    "alb-primary" = {
      cidr_block        = "10.0.0.0/20"
      availability_zone = "ap-northeast-1a"
      route_tables      = ["igw"]
      vpc_endpoints     = [""]
    }
    "alb-secondary" = {
      cidr_block        = "10.0.16.0/20"
      availability_zone = "ap-northeast-1c"
      route_tables      = ["igw"]
    }
    "public-primary" = {
      cidr_block        = "10.0.32.0/20"
      availability_zone = "ap-northeast-1a"
      route_tables      = ["igw"]
      vpc_interface_endpoints = [
        "com.amazonaws.ap-northeast-1.ecr.dkr",
        "com.amazonaws.ap-northeast-1.ecr.api",
      ]
    }
    "public-secondary" = {
      cidr_block        = "10.0.48.0/20"
      availability_zone = "ap-northeast-1c"
      route_tables      = ["igw"]
      vpc_interface_endpoints = [
        "com.amazonaws.ap-northeast-1.ecr.dkr",
        "com.amazonaws.ap-northeast-1.ecr.api",
      ]
    }
    "private-primary" = {
      cidr_block        = "10.0.64.0/20"
      availability_zone = "ap-northeast-1a"
    }
    "private-secondary" = {
      cidr_block        = "10.0.80.0/20"
      availability_zone = "ap-northeast-1c"
    }
  }
  security_groups = {
    "allow-global-http-ingress" = {
      type         = "ingress"
      allow_global = true
      port_range   = [80]
      protocol     = "tcp"
    }
    "allow-global-https-ingress" = {
      type         = "ingress"
      allow_global = true
      port_range   = [443]
      protocol     = "tcp"
    }
    "allow-any-egress" = {
      type         = "egress"
      allow_global = true
      protocol     = "-1"
    }
  }
  route_tables = {
    "igw" = {
      global_type = "igw"
      vpc_gateway_endpoints = [
        "com.amazonaws.ap-northeast-1.s3"
      ]
    }
  }
  vpc_gateway_endpoints = {
    "com.amazonaws.ap-northeast-1.s3" : {}
  }
  vpc_interface_endpoints = {
    "com.amazonaws.ap-northeast-1.ecr.dkr" : {}
    "com.amazonaws.ap-northeast-1.ecr.api" : {}
  }
}
