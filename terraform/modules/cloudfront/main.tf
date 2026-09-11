locals {
	env_region_map = {
		"dev" = "ap-south-1"
		"prod" = "us-east-1"
	}
	
	region = lookup(local.env_region_map,var.environment,"unknown") 
	name = "${var.name_prefix}-${var.environment}-${local.region}"
}

resource "aws_s3_bucket" "site"{
	bucket = "${local.name}-bucket"
}

resource "aws_s3_bucket_public_access_block" "site"{
	bucket = aws_s3_bucket.site.id
		
	block_public_policy = true
	block_public_acls = true
	ignore_public_acls = true
	restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "site"{
	bucket = aws_s3_bucket.site.id
	
	versioning_configuration {
		status = "Enabled"
	}
}


resource "aws_cloudfront_origin_access_control" "site" {
	name = "${local.name}-bucket-oac"
        description = "OAC for ${local.name}-bucket"
        origin_access_control_origin_type = "s3"
        signing_behavior = "always"
        signing_protocol = "sigv4"
}


resource "aws_cloudfront_distribution" "site"{
	enabled = true
	default_root_object = "index.hmtl"
	price_class = "PriceClass_100"

	origin {
		domain_name = aws_s3_bucket.site.bucket_regional_domain_name
		origin_id = "s3-${local.name}-bucket"
		origin_access_control_id = aws_cloudfront_origin_access_control.site.id
	}

	default_cache_behavior {
		allowed_methods = ["GET","HEAD"]
                cached_methods = ["GET", "HEAD"]
                target_origin_id = "s3-${local.name}-bucket"
                viewer_protocol_policy = "redirect-to-https"
                compress = true
	
		forwarded_values {
			query_string = false
			cookies {
				forward = "none"
			}
		}

		min_ttl = 0
		default_ttl = 3600
		max_ttl = 86400
	}
  
  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

data "aws_iam_policy_document" "site" {
  statement {
    sid     = "AllowCloudFrontServicePrincipalReadOnly"
    effect  = "Allow"
    actions = ["s3:GetObject"]

    resources = ["${aws_s3_bucket.site.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.site.arn]
    }
  }
}


resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.site.id
  policy = data.aws_iam_policy_document.site.json
}
