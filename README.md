# AWS Tabular Storage Profile Terraform module

Terraform module creates S3 Bucket, S3 Bucket configuration, and IAM Role resources on AWS and Storage Profile resource 
on Tabular.

## Usage

```
provider aws {
    region = var.region
}

provider tabular {
    organization_id = var.organization_id
}

module "tabular_bucket" {
  source = "../../"

  bucket_name        = "bucket-name"
  external_id        = var.organization_id
}

resource "tabular_s3_storage_profile" "example" {
  region         = var.region
  s3_bucket_name = module.tabular_bucket.s3_bucket_name
  role_arn       = module.tabular_bucket.iam_role_arn
}

resource "tabular_warehouse" "example" {
  name            = "tabular-warehouse-name"
  storage_profile = tabular_s3_storage_profile.example.id
}
```