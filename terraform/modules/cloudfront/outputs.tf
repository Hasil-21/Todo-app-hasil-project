output "bucket_name" {
  value = aws_s3_bucket.site.bucket
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.site.id
}

output "cloudfront_domain_name" {
  description = "Use this URL to access the app (no custom domain)"
  value       = aws_cloudfront_distribution.site.domain_name
}
