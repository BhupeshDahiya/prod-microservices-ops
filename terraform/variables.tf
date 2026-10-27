variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "env_name" {
  type    = string
  default = "dev"
}

variable "tags" {
  description = "Global tags to apply to all resources"
  type        = map(string)
  default = {
    Terraform = "true"
  }
}

variable "environment_name" {
  description = "Env for the current resource"
  type        = string
  default     = "dev"
}

# vpc vars

variable "cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_newbits" {
  type    = number
  default = 8
}

# eks vars

variable "cluster_name" {
  type    = string
  default = "main_cluster"
}

variable "cluster_version" {
  type    = string
  default = "1.37"
}

variable "principal_arn" {
  description = "arn of the iam role which we are giving eks access to"
  type        = string
  default     = "arn:aws:iam::350235531576:user/vpro-gitops"
}

variable "node_group_name" {
  type    = string
  default = "main_cluster_node_group"
}

variable "capacity_type" {
  type    = string
  default = "ON_DEMAND"
}

variable "ami_type" {
  type    = string
  default = "ami-064e0fb2e5d705dc8"
}

variable "instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "disk_size" {
  type    = number
  default = 20
}