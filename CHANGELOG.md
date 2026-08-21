# Changelog

All notable changes to this module will be documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.0.0] - 2026-08-20

### Changed
- **BREAKING:** `rules[*].protocol` is now `list(string)` instead of `string`. Every rule expands to one
  rule block per CIDR x protocol pair, matching how `cidr_block` already worked. Existing configurations
  must wrap the value: `protocol = "tcp"` becomes `protocol = ["tcp"]`.

  UCloud has no "all protocols" value — the provider rejects `all`, `any` and their case variants at plan
  time with `expected protocol to be one of [tcp udp gre icmp]` — so covering tcp and udp genuinely needs
  two rule blocks. Listing the protocols on one entry replaces repeating the whole entry per protocol.

### Added
- Validation that `port_range` is set when `protocol` includes `tcp` or `udp`. The provider enforces this
  itself, but only once the expanded rule reaches it, so its error names a generated rule rather than the
  entry that produced it. `icmp` and `gre` are accepted with or without a port range.
- Validation that `protocol`, when given, is not an empty list.


## [1.1.0] - 2026-04-29

### Added
- Validation: `port_range` must be a single port (`"80"`) or a range (`"8080-8090"`)
- Output: `remark` — the security group's remark field

## [1.0.0] - 2026-04-29

### Added
- Initial release
- `ucloud_security_group` resource with `dynamic "rules"` block
- `cidr_block` accepts `list(string)` — expands to one inline rule per CIDR
- Input validation: `policy` (accept/drop), `priority` (high/medium/low), `protocol` (tcp/udp/icmp/gre)
- Per-rule defaults: `policy = "accept"`, `priority = "medium"`
- Outputs: `id`, `name`
- Examples: `basic` (web server), `complete` (app + database tiers)
- GitHub Actions CI: fmt, validate
