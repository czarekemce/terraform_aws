locals {
  current_timestamp = timestamp()
  simple_timestamp = replace(local.current_timestamp, "/[-:TZ]/", "")
  combined_name = "new-test-bucket-${local.simple_timestamp}"
}

resource "aws_s3_bucket" "combined_name" {
  bucket = local.combined_name
  acl    = "private"
}

output "combined_name" {
  value = aws_s3_bucket.combined_name.bucket
}

resource "aws_iam_user" "new-test-terraform-user" {
  name = "new-test-terraform-user"
}

resource "aws_iam_role" "new-terraform-role" {
  name = "new-terraform-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "s3.amazonaws.com",
        },
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "new-terraform-role-attachment" {
  role       = aws_iam_role.new-terraform-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_s3_bucket_policy" "combined_name_policy" {
  bucket = aws_s3_bucket.combined_name.bucket

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.new-terraform-role.name}"
        },
        "Action": [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        "Resource": [
          "arn:aws:s3:::${aws_s3_bucket.combined_name.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.combined_name.bucket}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "new-test-terraform-user" {
  user       = aws_iam_user.new-test-terraform-user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

data "aws_caller_identity" "current" {}
