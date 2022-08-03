output "key_alias_arn" {
  description = "The arn of the key alias"
  value       = aws_kms_alias.rds-kms-alias.arn
}

output "key_alias_name" {
  description = "The name of the key alias"
  value       = aws_kms_alias.rds-kms-alias.name
}

output "key_arn" {
  description = "The arn of the key"
  value       = aws_kms_key.rds-key.arn
}

output "key_id" {
  description = "The globally unique identifier for the key"
  value       = aws_kms_key.rds-key.id
}