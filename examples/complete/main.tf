# App tier
module "sg_app" {
  source = "github.com/0xphuong/terraform-ucloud-security-group?ref=v2.0.0"

  name = "app"
  tag  = "production"

  rules = {
    allow-app-port = {
      port_range = "8080"
      protocol   = ["tcp"]
      cidr_block = ["10.0.0.0/16"]
      policy     = "accept"
    }
    # Multiple CIDRs — one rule block created per CIDR
    allow-ssh = {
      port_range = "22"
      protocol   = ["tcp"]
      cidr_block = ["10.0.1.0/24", "192.168.1.0/24"]
      policy     = "accept"
      priority   = "high"
    }
    allow-icmp = {
      protocol   = ["icmp"]
      cidr_block = ["0.0.0.0/0"]
      policy     = "accept"
      priority   = "low"
    }
  }
}

# Database tier
module "sg_db" {
  source = "github.com/0xphuong/terraform-ucloud-security-group?ref=v2.0.0"

  name   = "database"
  tag    = "production"
  remark = "Database tier security group"

  rules = {
    allow-mysql = {
      port_range = "3306"
      protocol   = ["tcp"]
      cidr_block = ["10.0.2.0/24"]
      policy     = "accept"
      priority   = "high"
    }
    allow-mongodb = {
      port_range = "27017"
      protocol   = ["tcp"]
      cidr_block = ["10.0.2.0/24"]
      policy     = "accept"
      priority   = "high"
    }
    deny-all = {
      port_range = "1-65535"
      protocol   = ["tcp"]
      cidr_block = ["0.0.0.0/0"]
      policy     = "drop"
      priority   = "low"
    }
  }
}

output "sg_app_id" { value = module.sg_app.id }
output "sg_db_id" { value = module.sg_db.id }

# One entry, several protocols: expands to a rule block per CIDR x protocol.
module "sg_intra_vpc" {
  source = "github.com/0xphuong/terraform-ucloud-security-group?ref=v2.0.0"

  name   = "intra-vpc"
  remark = "All intra-VPC traffic"
  rules = {
    vpc = {
      cidr_block = ["10.0.0.0/16", "10.1.0.0/16"]
      protocol   = ["tcp", "udp", "icmp"]
      port_range = "1-65535"
    }
  }
}

output "intra_vpc_id" {
  value = module.sg_intra_vpc.id
}
