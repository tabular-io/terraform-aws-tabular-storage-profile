variable "bucket_name" {
  type        = string
  description = "Name of the bucket to use for warehouse storage"
}

variable "external_id" {
  type        = string
  description = "Generated ID for trust policy"
}

variable "delete_recovery_days" {
  type        = number
  description = "The number of days after which deletes cannot be recovered"
  default     = 7
}

variable "tabular_account_id" {
  type        = string
  description = "Tabular Account Id"
  default     = "237881912361"
}

variable "tabular_region" {
  type        = string
  description = "Tabular Warehouse location"
  default     = "us-east-1"
}
