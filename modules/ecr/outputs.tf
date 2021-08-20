output "repository_name" {
  description = "Name of the Elastic Container Repository"
  value       = aws_ecr_repository.default.name
}

output "repository_url" {
  description = "URL of the Generated Elastic Container Repository"
  value       = aws_ecr_repository.default.repository_url
}
