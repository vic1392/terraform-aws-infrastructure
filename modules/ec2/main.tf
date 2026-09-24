resource "aws_instance" "this" {
  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id = var.subnet_id

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = var.instance_name
  }
}

resource "aws_iam_role" "ec2_role" {
  name = "${var.instance_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "ec2.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "s3_access" {
  name = "${var.instance_name}-s3-access"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Action = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
      ]

      Resource = [
        var.s3_bucket_arn,
        "${var.s3_bucket_arn}/*"
      ]
    }]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.instance_name}-profile"
  role = aws_iam_role.ec2_role.name
}
