locals {
  # Expand each rule into one entry per CIDR x protocol pair. UCloud has no
  # "all protocols" value, so a rule covering tcp and udp genuinely needs two
  # rule blocks — listing the protocols here beats repeating the whole entry.
  #
  # Inline rule blocks don't support for_each, so this flattens into a list fed
  # to a dynamic block. A rule with no protocol stays a single entry per CIDR,
  # which is how the provider expresses "any protocol" for that CIDR.
  expanded_rules = flatten([
    for rule_name, rule in var.rules : [
      for cidr in rule.cidr_block : [
        for protocol in(rule.protocol != null ? rule.protocol : [null]) : {
          cidr_block = cidr
          port_range = rule.port_range
          protocol   = protocol
          policy     = rule.policy
          priority   = rule.priority
        }
      ]
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
