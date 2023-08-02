module "tabular_bucket" {
  source = "../../"

  bucket_name         = var.bucket_name
  external_id         = var.external_id
  tabular_account_arn = var.tabular_account_arn
}