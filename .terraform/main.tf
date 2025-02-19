# Terraform para provisionar a infraestrutura AWS

provider "aws" {
  region = "us-east-1"
}

# Criar o bucket S3 para o site
resource "aws_s3_bucket" "site" {
  bucket = "meu-site-estatico"
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

# Criar política de acesso público para o S3
resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.site.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::meu-site-estatico/*"
    }
  ]
}
POLICY
}

# Criar distribuição CloudFront
resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_s3_bucket.site.bucket_regional_domain_name
    origin_id   = "S3-meu-site"
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-meu-site"

    viewer_protocol_policy = "redirect-to-https"
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

# Criar pool de usuários no Cognito
resource "aws_cognito_user_pool" "users" {
  name = "meu-user-pool"
}

# Criar API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name        = "MeuAPI"
  description = "API para o site"
}

# Criar função Lambda para backend
resource "aws_lambda_function" "backend" {
  function_name = "backend-function"
  runtime       = "nodejs18.x"
  handler       = "index.handler"

  filename         = "lambda.zip"
  source_code_hash = filebase64sha256("lambda.zip")

  role = aws_iam_role.lambda_exec.arn
}

# Criar tabela no DynamoDB
resource "aws_dynamodb_table" "users" {
  name         = "Users"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "userId"

  attribute {
    name = "userId"
    type = "S"
  }
}
