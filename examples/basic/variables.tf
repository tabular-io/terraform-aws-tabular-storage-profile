variable "bucket_name" {
  type        = string
  description = "Name of the bucket to use for warehouse storage"
}

variable "organization_id" {
  type        = string
  description = "Tabular Organization ID"
}

variable "tabular_account_id" {
  type        = string
  description = "Tabular AWS Account"
  default     = "237881912361"
}

variable "tabular_region" {
  type        = string
  description = "Tabular Warehouse Location"
  default     = "us-east-1"
}

variable "force_destroy_s3_bucket" {
  type        = bool
  description = "All objects in bucket will be deleted"
  default     = false
}