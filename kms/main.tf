resource "aws_kms_key" "rds-key" {
  description = "key to encrypt rds password"
  deletion_window_in_days = 7
}

resource "aws_kms_alias" "rds-kms-alias" {
  target_key_id = aws_kms_key.rds-key.id
  name = "alias/rds-kms-key"
}


data "aws_kms_ciphertext" "rds-password" {
  key_id = aws_kms_key.rds-key.key_id

  plaintext = <<EOF
{
  "rds_password": ${var.rds_password}
}
EOF
}
