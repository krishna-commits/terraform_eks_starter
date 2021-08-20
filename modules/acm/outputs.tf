output "certificate_arn" {
  description = "The ARN of the generated certificate"
  value       = aws_acm_certificate_validation.certificate.certificate_arn
}
