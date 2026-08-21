variable "name" {
  description = "Name of the security group (1–63 characters)"
  type        = string

  validation {
    condition     = length(var.name) >= 1 && length(var.name) <= 63
    error_message = "Security group name must be between 1 and 63 characters."
  }
}

variable "tag" {
  description = "Tag assigned to the security group"
  type        = string
  default     = "Default"
}

variable "remark" {
  description = "Remarks for the security group"
  type        = string
  default     = null
}

variable "rules" {
  description = "Map of security group rules. Key is a logical name. Both cidr_block and protocol take lists, and one rule block is created for every CIDR x protocol pair — UCloud has no 'all protocols' value, so tcp+udp has to be spelled out as two rules and this does that expansion."
  type = map(object({
    cidr_block = list(string)
    protocol   = optional(list(string))
    port_range = optional(string)
    policy     = optional(string, "accept")
    priority   = optional(string, "medium")
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.rules : length(v.cidr_block) > 0
    ])
    error_message = "Each rule must have at least one cidr_block."
  }
  validation {
    condition = alltrue([
      for k, v in var.rules : v.protocol == null ? true : length(v.protocol) > 0
    ])
    error_message = "protocol, when given, must list at least one protocol."
  }
  validation {
    condition = alltrue([
      for k, v in var.rules :
      v.policy == null ? true : contains(["accept", "drop"], v.policy)
    ])
    error_message = "policy must be 'accept' or 'drop'."
  }
  validation {
    condition = alltrue([
      for k, v in var.rules :
      v.priority == null ? true : contains(["high", "medium", "low"], v.priority)
    ])
    error_message = "priority must be 'high', 'medium', or 'low'."
  }
  # UCloud accepts no "all"/"any" here: the provider rejects anything outside
  # this set at plan time with "expected protocol to be one of [tcp udp gre
  # icmp]".
  validation {
    condition = alltrue(flatten([
      for k, v in var.rules :
      v.protocol == null ? [true] : [
        for p in v.protocol : contains(["tcp", "udp", "icmp", "gre"], p)
      ]
    ]))
    error_message = "Each protocol must be one of: tcp, udp, icmp, gre. UCloud has no 'all' value — list the protocols instead."
  }
  validation {
    condition = alltrue([
      for k, v in var.rules :
      v.port_range == null ? true : can(regex("^\\d+(-\\d+)?$", v.port_range))
    ])
    error_message = "port_range must be a single port (e.g. '80') or a range (e.g. '8080-8090')."
  }
  # The provider enforces this itself — '"port_range" must be set when
  # "protocol" is "tcp" or "udp"' — but only once the expanded rule reaches it,
  # which names a generated rule rather than the entry that produced it. icmp
  # and gre are accepted with or without a port range.
  validation {
    condition = alltrue([
      for k, v in var.rules :
      v.protocol == null ? true : (
        length(setintersection(toset(v.protocol), toset(["tcp", "udp"]))) > 0 ? v.port_range != null : true
      )
    ])
    error_message = "port_range is required when protocol includes 'tcp' or 'udp'."
  }
}
