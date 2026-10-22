## Vars for VPC
data "aws_availability_zones" "available" {
  state = "available"
}

# AZ's and CIDR's for subnets
locals {
  azs = slice(data.aws_availability_zones.available.names,0,3)
  public_subnets = [for n,az in local.azs : cidrsubnet(var.cidr_block, var.subnet_newbits, n)]
  private_subnets = [for n,az in local.azs : cidrsubnet(var.cidr_block, var.subnet_newbits, n+10)]
}