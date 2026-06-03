module "sg_web" {
  source = "github.com/0xphuong/terraform-ucloud-security-group?ref=v1.0.0"

  name = "web"
  tag  = "production"

  rules = {
    allow-http = {
      port_range = "80"
      protocol   = "tcp"
      cidr_block = ["0.0.0.0/0"]
      policy     = "accept"
    }
    allow-https = {
      port_range = "443"
      protocol   = "tcp"
      cidr_block = ["0.0.0.0/0"]
      policy     = "accept"
    }
    allow-ssh = {
      port_range = "22"
      protocol   = "tcp"
      cidr_block = ["203.0.113.10/32"]
      policy     = "accept"
      priority   = "high"
    }
  }
}

output "sg_id"   { value = module.sg_web.id }
output "sg_name" { value = module.sg_web.name }
