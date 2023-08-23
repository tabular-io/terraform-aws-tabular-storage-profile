output "s3_bucket_name" {
  value = aws_s3_bucket.default.id
}

output "iam_role_arn" {
  value = aws_iam_role.default.arn
}