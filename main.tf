locals {
  # Expand each rule into one entry per CIDR.
  # Inline rule blocks don't support for_each, so we flatten into a list.
  expanded_rules = flatten([
    for rule_name, rule in var.rules : [
      for cidr in rule.cidr_block : {
        cidr_block = cidr
        port_range = rule.port_range
        protocol   = rule.protocol
        policy     = rule.policy
        priority   = rule.priority
      }
    ]
  ])
}

resource "ucloud_security_group" "this" {
  name   = var.name
  tag    = var.tag
  remark = var.remark != null ? var.remark : null

  dynamic "rules" {
    for_each = local.expanded_rules
    content {
      cidr_block = rules.value.cidr_block

      # Optional
      port_range = rules.value.port_range != null ? rules.value.port_range : null
      protocol   = rules.value.protocol != null ? rules.value.protocol : null
      policy     = rules.value.policy != null ? rules.value.policy : null
      priority   = rules.value.priority != null ? rules.value.priority : null
    }
  }
}
