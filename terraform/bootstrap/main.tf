resource "aws_s3_bucket" "terraform_state" {
  bucket = "my-little-sample-terraform-state" # name of the bucket globally unique

  # Prevents accidental deletion of this S3 bucket.
  # So, any attempt to "terraform destroy" this bucket will be blocked.
  # This is useful safety for production environments.
  # If you want to delete the bucket and its contents, you need to 
  # comment out this block and add a new argument below this 
  # `force_destroy = true` to allow deletion.
  lifecycle {
    prevent_destroy = true
  }

}

# Enable versioning for the S3 bucket to keep track of changes to Terraform state files.
# Versioning is important for state files to allow rollback in case of issues.
resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption with AWS KMS for the S3 bucket to protect sensitive data.
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true # Block public ACLs, ACLs are Access Control Lists.
  block_public_policy     = true # Block public bucket policies, bucket policies are used to manage access to the bucket.
  ignore_public_acls      = true # Ignore public ACLs, this is used to ignore any public ACLs that are set on the bucket.
  restrict_public_buckets = true # Restrict public buckets, this is used to restrict access to the bucket.
}
