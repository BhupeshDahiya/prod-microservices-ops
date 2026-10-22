variable "aws_region" {
    type = string
    default = "us-east-1"
}

variable "env_name" {
  type = string
  default = "dev"
}

variable "tags" {
  description = "Global tags to apply to all resources"
  type        = map(string)
  default     = {
    Terraform = "true"
  }
}

# vpc vars

variable "cidr_block" {
    type = string
    default = "10.0.0.0/16"
}

variable "subnet_newbits" {
    type = number
    default = 8
}

