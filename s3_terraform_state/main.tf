provider "aws" {
  region = var.aws_region
}

resource "aws_kms_key" "terraform_state_key" {
  description             = "This key is used to encrypt terraform state bucket"
  deletion_window_in_days = 7
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-simplephone"
}

resource "aws_s3_bucket_acl" "terraform_state_acl" {
  bucket = aws_s3_bucket.terraform_state.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.terraform_state.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.terraform_state_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}
