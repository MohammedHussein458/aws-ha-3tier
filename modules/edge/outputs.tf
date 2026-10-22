output "cloudfront_domain" {
  value = aws_cloudfront_distribution.this.domain_name
}

output "static_bucket" {
  value = aws_s3_bucket.static.id
}