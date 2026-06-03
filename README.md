# terraform-ucloud-security-group

Terraform module to create a **Security Group** with multiple rules on [UCloud](https://www.ucloud.cn).

## Features

- Creates one security group with any number of rules in a single module call
- `cidr_block` accepts multiple CIDRs per rule — one inline rule block created per CIDR
- Per-rule: `policy` (accept/drop), `priority` (high/medium/low), `protocol`, `port_range`
- Input validation: name length, policy/priority/protocol enum values
- Outputs: security group ID and name

## Usage

### Basic — web server

```hcl
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
```

### Multiple CIDRs per rule

```hcl
module "sg_app" {
  source = "github.com/0xphuong/terraform-ucloud-security-group?ref=v1.0.0"

  name = "app"

  rules = {
    # Two CIDRs → two rule blocks created automatically
    allow-ssh = {
      port_range = "22"
      protocol   = "tcp"
      cidr_block = ["10.0.1.0/24", "192.168.1.0/24"]
      policy     = "accept"
      priority   = "high"
    }
    deny-all = {
      port_range = "1-65535"
      protocol   = "tcp"
      cidr_block = ["0.0.0.0/0"]
      policy     = "drop"
      priority   = "low"
    }
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3.0 |
| ucloud | >= 1.39.5 |

## Providers

| Name | Version |
|------|---------|
| ucloud | >= 1.39.5 |

## Resources

| Name | Type |
|------|------|
| ucloud_security_group.this | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | Security group name (1–63 characters) | `string` | — | **yes** |
| rules | Map of security group rules | `map(object)` | `{}` | no |
| tag | Tag for the security group | `string` | `"Default"` | no |
| remark | Remarks for the security group | `string` | `null` | no |

### `rules` map value

| Field | Type | Default | Required | Description |
|-------|------|---------|----------|-------------|
| `cidr_block` | `list(string)` | — | **yes** | One or more source CIDRs. One rule block created per CIDR. |
| `port_range` | `string` | `null` | no | Port or range (e.g. `"80"`, `"8080-8090"`) |
| `protocol` | `string` | `null` | no | `tcp` \| `udp` \| `icmp` \| `gre` |
| `policy` | `string` | `"accept"` | no | `accept` \| `drop` |
| `priority` | `string` | `"medium"` | no | `high` \| `medium` \| `low` |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the security group |
| name | The name of the security group |
<!-- END_TF_DOCS -->

## Examples

- [Basic](./examples/basic) — web server with HTTP/HTTPS/SSH rules
- [Complete](./examples/complete) — app and database tiers with multi-CIDR rules

## Changelog

See [CHANGELOG.md](./CHANGELOG.md).

## License

[MIT](./LICENSE)
