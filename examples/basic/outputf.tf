output "s3_bucket_name" {
  value = module.tabular_bucket.s3_bucket_name
}

output "iam_role_arn" {
  value = module.tabular_bucket.iam_role_arn
}