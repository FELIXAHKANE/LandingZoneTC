variable "project-name" {
  type        = string
  default     = "LandingZone"
  description = "The name of the Project"
}

variable "project-id" {
  type        = string
  default     = "1173087"
  description = "The ID of the Project"
}

#variable "my-secret-id" {
#  type        = string
#  default     = ""
#  description = "API keys Secret ID"
#}

#variable "my-secret-key" {
#  type        = string
#  default     = """
#  description = "APi keys Secret key"
#}

variable "vpc_cidr" {
  type        = string
  default     = "10.10.0.0/16"
  description = "VPC's CIDR range"
}

variable "vpc_name" {
  type        = string
  default     = "vpc1"
  description = "VPC's name"
}

variable "multicast" {
  type        = string
  default     = "false"
  description = "The value for the multicast enablement"
}

variable "region" {
  type        = string
  default     = "eu-frankfurt"
  description = "The name of the region"
}

variable "AZ-1" {
  type        = string
  default     = "1"
  description = "The value for the first availability zone"
}

variable "AZ-2" {
  type        = string
  default     = "2"
  description = "The value for the first availability zone"
}

variable "natgw01-bandwidth" {
  type        = string
  default     = "20"
  description = "The value for the nat gateway bandwidth"
}

variable "natgw01-max-concurrent" {
  type        = string
  default     = "1000000"
  description = "The value for the nat gateway max concurrent sessions"
}

variable "natgw02-bandwidth" {
  type        = string
  default     = "20"
  description = "The value for the nat gateway bandwidth"
}

variable "natgw02-max-concurrent" {
  type        = string
  default     = "1000000"
  description = "The value for the nat gateway max concurrent sessions"
}

variable "rt-public-entry01-destination" {
  default     = "0.0.0.0/0"
}

variable "rt-public-entry01-next_hop_type" {
  default     = "NAT"
}

variable "rt-public-entry01-description" {
  default     = "default route to NAT gateway"
}

variable "rt-public-entry02-destination" {
  default     = "0.0.0.0/0"
}

variable "rt-public-entry02-next_hop_type" {
  default     = "NAT"
}

variable "rt-public-entry02-description" {
  default     = "default route to NAT gateway"
}
