provider aws {
  region = var.tabular_region
}

provider "tabular" {
  organization_id = var.organization_id
}