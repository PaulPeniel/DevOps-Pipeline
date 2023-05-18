variable "vpc_cidr" {
  description = "cidr block for vpc"
  type        = string
}

variable "enable_dns_support" {
  type = bool
}

variable "enable_dns_hostnames" {
  type = bool
}

variable "Environment" {
  description = "where this infra is running"
  type        = string
}

variable "project_name" {
  type = string
}

variable "tags" {
  default = {
    Owner = "Paul Peniel"
  }
}

variable "public_cidr" {
  description = "public cidrs ips"
  type        = list(string)
}

variable "ports" {
  description = "Ingress traffic"
  type        = list(string)
}

variable "ami" {
  description = "OS type"
  type        = string
}
variable "instance_type" {
  description = "size of OS"
  type        = string
}

variable "key_name" {
  description = "keypair"
  type        = string
}

variable "azs" {
  description = "data center"
  type        = list(string)
}