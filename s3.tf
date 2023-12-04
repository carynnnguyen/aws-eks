resource "aws_s3_bucket" "aws_s3_bucket" {
  bucket = var.s3_bucket_name
  acl    = "private"

  versioning {
    enabled = false
  }

  tags = {
    Name = "${var.cluster_name}-eks-s3"
  }

  lifecycle_rule {
    id      = "one_zone_ia_rule"
    enabled = true

    transition {
      days          = 10
      storage_class = "ONEZONE_IA"
    }
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [lifecycle_rule, versioning]
  }
}

resource "aws_s3_bucket_policy" "aws_s3_bucket" {
  bucket = aws_s3_bucket.aws_s3_bucket.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::123456789012:role/EKSPodRole"
        },
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ],
        Resource = [
          "${aws_s3_bucket.aws_s3_bucket.arn}/*",
          aws_s3_bucket.aws_s3_bucket.arn
        ]
      }
    ]
  })
}

resource "aws_s3_bucket" "aws_s3_bucket_folder" {
  bucket = "cce-state"
  acl    = "private"

  versioning {
    enabled = false
  }

  tags = {
    Name = "${var.cluster_name}-eks-s3-folder"
  }

  lifecycle_rule {
    id      = "one_zone_ia_rule"
    enabled = true

    transition {
      days          = 30
      storage_class = "ONEZONE_IA"
    }
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [lifecycle_rule, versioning]
  }
}

# Checking if buckets already exist
data "aws_s3_bucket" "aws_s3_bucket_data" {
  count  = terraform.workspace == "default" ? 0 : 1
  bucket = "aws-s3-bucket"
}

data "aws_s3_bucket" "aws_s3_bucket_folder_data" {
  count  = terraform.workspace == "default" ? 0 : 1
  bucket = "aws-s3-bucket-folder"
}

resource "null_resource" "bucket_already_exists" {
  count = length(data.aws_s3_bucket.aws_s3_bucket_data.*.id) > 0 ? 1 : 0

  provisioner "local-exec" {
    command = "echo Bucket aws-s3-bucket already exists and will not be created by Terraform."
  }
}

resource "null_resource" "bucket_folder_already_exists" {
  count = length(data.aws_s3_bucket.aws_s3_bucket_folder_data.*.id) > 0 ? 1 : 0

  provisioner "local-exec" {
    command = "echo Bucket aws-s3-bucket-folder already exists and will not be created by Terraform."
  }
}
