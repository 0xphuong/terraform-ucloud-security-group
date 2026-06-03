# Changelog

All notable changes to this module will be documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
