
output "bastion_security_group_id" {
  value       = join("", aws_security_group.default.*.id)
  description = "ID of bastion securtiy group"
}

output "bastion_host_role_arn" {
  value       = local.bastion_host_role_arn
  description = "ARN for bastion host"
}
