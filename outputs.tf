output "id" {
  description = "The ID of the security group"
  value       = ucloud_security_group.this.id
}

output "name" {
  description = "The name of the security group"
  value       = ucloud_security_group.this.name
}
