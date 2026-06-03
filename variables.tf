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
  description = "Map of security group rules. Key is a logical name. cidr_block accepts multiple CIDRs — one rule block is created per CIDR."
  type = map(object({
    cidr_block = list(string)
    port_range = optional(string)
    protocol   = optional(string)
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
  validation {
    condition = alltrue([
      for k, v in var.rules :
      v.protocol == null ? true : contains(["tcp", "udp", "icmp", "gre"], v.protocol)
    ])
    error_message = "protocol must be one of: tcp, udp, icmp, gre."
  }
  validation {
    condition = alltrue([
      for k, v in var.rules :
      v.port_range == null ? true : can(regex("^\\d+(-\\d+)?$", v.port_range))
    ])
    error_message = "port_range must be a single port (e.g. '80') or a range (e.g. '8080-8090')."
  }
}
