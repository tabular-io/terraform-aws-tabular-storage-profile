module "tabular_bucket" {
  source = "../../"

  bucket_name        = var.bucket_name
  external_id        = var.organization_id
  tabular_account_id = var.tabular_account_id
  tabular_region     = var.tabular_region
}

resource "tabular_s3_storage_profile" "example" {
  region         = var.tabular_region
  s3_bucket_name = module.tabular_bucket.s3_bucket_name
  role_arn       = module.tabular_bucket.iam_role_arn
}

resource "tabular_warehouse" "example" {
  name            = "tabular-warehouse-name"
  storage_profile = tabular_s3_storage_profile.example.id
}