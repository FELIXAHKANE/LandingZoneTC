terraform {
  required_providers {
    tencentcloud = {
      source = "tencentcloudstack/tencentcloud"
    }
  }
}

# Configure the TencentCloud Provider
provider "tencentcloud" {
  #secret_id  = var.my-secret-id
  #secret_key = var.my-secret-key
  region     = var.region
}

# Get availability zones
data "tencentcloud_availability_zones_by_product" "all" {
  product = "cvm"
}

resource "tencentcloud_vpc" "LandingZoneVPC" {
  name                = var.vpc_name
  cidr_block          = var.vpc_cidr

  # Optional parameters
  # tags = {
  #   "name"          = "vpc-${var.project-name}-${var.region}-${var.environment}-01"
  #   "owner"         = var.tag-owner
  #   "purpose"       = var.tag-purpose
  #   "environment"   = var.environment
  #   "security_lvl"  = var.tag-security_lvl
  #   "cost_center"   = var.tag-cost_center
  # }
  # dns_servers       = ["119.29.29.29", "8.8.8.8"]
  is_multicast        = var.multicast
}

resource "tencentcloud_subnet" "PublicSubnet01" {
  name                = "subnet-${var.project-name}-public-01"
  availability_zone   = "${var.region}-${var.AZ-1}"
  vpc_id              = tencentcloud_vpc.LandingZoneVPC.id
  cidr_block          = cidrsubnet("${var.vpc_cidr}", 4, 0)  #10.10.0.0/20

  # Optional but highly recommended parameters
  route_table_id      = tencentcloud_route_table.rt-public01.id
  is_multicast        = var.multicast

  # Optional parameters
  #tags = {}
}

resource "tencentcloud_subnet" "PublicSubnet02" {
  name                = "subnet-${var.project-name}-public-02"
  availability_zone   = "${var.region}-${var.AZ-2}"
  vpc_id              = tencentcloud_vpc.LandingZoneVPC.id
  cidr_block          = cidrsubnet("${var.vpc_cidr}", 4, 1)  #10.10.16.0/20

  # Optional but highly recommended parameters
  route_table_id      = tencentcloud_route_table.rt-public02.id
  is_multicast        = var.multicast

  #Optional parameters
  #tags = {}
}

resource "tencentcloud_eip" "NATGW-EIP01" {

  name = "eip-${var.project-name}-01"
  internet_max_bandwidth_out = "50"
}

resource "tencentcloud_eip" "NATGW-EIP02" {

  name = "eip-${var.project-name}-02"
  internet_max_bandwidth_out = "50"
}

resource "tencentcloud_nat_gateway" "LZ-NATGW01" {
  name                = "natgw-public01"
  vpc_id              = tencentcloud_vpc.LandingZoneVPC.id
  bandwidth           = var.natgw01-bandwidth
  max_concurrent      = var.natgw01-max-concurrent
  assigned_eip_set    = ["${tencentcloud_eip.NATGW-EIP01.public_ip}"]
}

resource "tencentcloud_nat_gateway" "LZ-NATGW02" {
  name                = "natgw-public02"
  vpc_id              = tencentcloud_vpc.LandingZoneVPC.id
  bandwidth           = var.natgw02-bandwidth
  max_concurrent      = var.natgw02-max-concurrent
  assigned_eip_set    = ["${tencentcloud_eip.NATGW-EIP02.public_ip}"]
}

resource "tencentcloud_route_table" "rt-public01" {
  name                = "rt-${var.project-name}-public01"
  vpc_id              = tencentcloud_vpc.LandingZoneVPC.id

  #Optional parameters
  #tags = {}
}

resource "tencentcloud_route_table" "rt-public02" {
  name                = "rt-${var.project-name}-public02"
  vpc_id              = tencentcloud_vpc.LandingZoneVPC.id

  #Optional parameters
  #tags = {}
}

resource "tencentcloud_route_table_entry" "public01-default-route" {
  route_table_id         = tencentcloud_route_table.rt-public01.id
  destination_cidr_block = var.rt-public-entry01-destination
  next_type              = var.rt-public-entry01-next_hop_type
  next_hub               = tencentcloud_nat_gateway.LZ-NATGW01.id

  #Optional parameters
  description            = var.rt-public-entry01-description
}

resource "tencentcloud_route_table_entry" "public02-default-route" {
  route_table_id         = tencentcloud_route_table.rt-public02.id
  destination_cidr_block = var.rt-public-entry02-destination
  next_type              = var.rt-public-entry02-next_hop_type
  next_hub               = tencentcloud_nat_gateway.LZ-NATGW02.id

  #Optional parameters
  description            = var.rt-public-entry02-description
}

resource "tencentcloud_security_group" "sg-LandingZone-public01" {
  name              = "sg-${var.project-name}-public01"

  #Optional parameters
  #project_id  = var.project-id
  #description = "sg-${var.project-name}-publicCVMs-${var.tag-owner}-${var.tag-purpose}-${var.environment}-${var.tag-security_lvl}"
  #tags = {
  #  "owner"         = var.tag-owner
  #  "purpose"       = var.tag-purpose
  #  "environment"   = var.environment
  #  "security_lvl"  = var.tag-security_lvl
  #}
}

resource "tencentcloud_security_group" "sg-LandingZone-public02" {
  name              = "sg-${var.project-name}-public02"

  #Optional parameters
  #project_id  = var.project-id
  #description = "sg-${var.project-name}-publicCVMs-${var.tag-owner}-${var.tag-purpose}-${var.environment}-${var.tag-security_lvl}"
  #tags = {
  #  "owner"         = var.tag-owner
  #  "purpose"       = var.tag-purpose
  #  "environment"   = var.environment
  #  "security_lvl"  = var.tag-security_lvl
  #}
}

resource "tencentcloud_security_group_rule" "sg-LandingZone-public01-r1" {
  security_group_id = tencentcloud_security_group.sg-LandingZone-public01.id
  type              = "ingress"
  cidr_ip           = var.vpc_cidr
  ip_protocol       = "TCP"
  port_range        = "22"
  policy            = "ACCEPT"
  description       = "allow ssh"
}

resource "tencentcloud_security_group_rule" "sg-LandingZone-public01-r2" {
  security_group_id = tencentcloud_security_group.sg-LandingZone-public01.id
  type              = "ingress"
  cidr_ip           = var.vpc_cidr
  ip_protocol       = "TCP"
  port_range        = "3389"
  policy            = "ACCEPT"
  description       = "allow rdp"
}

resource "tencentcloud_security_group_rule" "sg-LandingZone-public01-r3" {
  security_group_id = tencentcloud_security_group.sg-LandingZone-public01.id
  type              = "ingress"
  cidr_ip           = var.vpc_cidr
  ip_protocol       = "ICMP"
  #port_range        = ""
  policy            = "ACCEPT"
  description       = "allow icmp"
}

resource "tencentcloud_security_group_rule" "sg-LandingZone-public01-r4" {
  security_group_id = tencentcloud_security_group.sg-LandingZone-public01.id
  type              = "ingress"
  cidr_ip           = var.vpc_cidr
  #ip_protocol       = "ALL"
  #port_range        = "ALL"
  policy            = "ACCEPT"
  description       = "allow all internal"
}

resource "tencentcloud_security_group_rule" "sg-LandingZone-public02-r1" {
  security_group_id = tencentcloud_security_group.sg-LandingZone-public02.id
  type              = "ingress"
  source_sgid       = tencentcloud_security_group.sg-LandingZone-public02.id
  ip_protocol       = "TCP"
  port_range        = "22"
  policy            = "ACCEPT"
  description       = "allow ssh"
}

resource "tencentcloud_security_group_rule" "sg-LandingZone-public02-r2" {
  security_group_id = tencentcloud_security_group.sg-LandingZone-public02.id
  type              = "ingress"
  source_sgid       = tencentcloud_security_group.sg-LandingZone-public02.id
  ip_protocol       = "TCP"
  port_range        = "3389"
  policy            = "ACCEPT"
  description       = "allow rdp"
}

resource "tencentcloud_security_group_rule" "sg-LandingZone-public02-r3" {
  security_group_id = tencentcloud_security_group.sg-LandingZone-public02.id
  type              = "ingress"
  cidr_ip           = var.vpc_cidr
  ip_protocol       = "ICMP"
  #port_range        = ""
  policy            = "ACCEPT"
  description       = "allow icmp"
}

resource "tencentcloud_security_group_rule" "sg-LandingZone-public02-r4" {
  security_group_id = tencentcloud_security_group.sg-LandingZone-public02.id
  type              = "ingress"
  cidr_ip           = var.vpc_cidr
  #ip_protocol       = "ALL"
  #port_range        = "ALL"
  policy            = "ACCEPT"
  description       = "allow all internal"
}
