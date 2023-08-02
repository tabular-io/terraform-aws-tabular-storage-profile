variable "bucket_name" {
  type        = string
  description = "Name of the bucket to use for warehouse storage"
}

variable "external_id" {
  type        = string
  description = "Generated ID for trust policy"
}

variable "tabular_account_arn" {
  type        = string
  description = "Tabular AWS Account"
}