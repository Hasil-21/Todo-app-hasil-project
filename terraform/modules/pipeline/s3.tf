resource "aws_s3_bucket" "artifacts"{
	bucket_prefix = "${var.name_prefix}-pipeline-artifacts-"
	force_destroy = true
}


resource "aws_s3_bucket_public_access_block" "artifacts" {
	bucket = aws_s3_bucket.artifacts.id

	block_public_policy = true
	block_public_acls = true
	ignore_public_acls = true
	restrict_public_buckets = true
}
