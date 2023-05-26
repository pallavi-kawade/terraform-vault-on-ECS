# SSL Certificate
resource "aws_acm_certificate" "ssl_certificate" {
  provider                  = aws.acm_provider
  domain_name               = "vault.${var.www_domain_name}"
  subject_alternative_names = ["*.${var.www_domain_name}"]
  validation_method         = var.validation_method
 tags = {
    Environment = "dev"
  }

  lifecycle {
    create_before_destroy = true
  }
}