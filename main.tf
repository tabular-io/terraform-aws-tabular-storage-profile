data "aws_caller_identity" "default" {}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      identifiers = [var.tabular_account_id]
      type        = "AWS"
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]

    condition {
      test     = "ArnLike"
      values   = ["arn:aws:iam::${var.tabular_account_id}:role/TabularSignerServiceRole*"]
      variable = "aws:PrincipalArn"
    }

    condition {
      test     = "StringEquals"
      values   = [var.external_id]
      variable = "sts:ExternalId"
    }
  }
}

resource "aws_iam_role" "default" {
  name                 = "TabularRole_${var.bucket_name}"
  assume_role_policy   = data.aws_iam_policy_document.assume_role.json
  max_session_duration = 3600
}

data "aws_iam_policy_document" "tabular" {
  statement {
    effect  = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:GetBucketNotification",
      "s3:PutBucketNotification",
      "s3:GetObject",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:DeleteObject",
      "s3:AbortMultipartUpload",
    ]
    resources = [
      "arn:aws:s3:::${var.bucket_name}",
      "arn:aws:s3:::${var.bucket_name}/*"
    ]
  }

  statement {
    effect  = "Allow"
    actions = [
      "glue:GetDatabase",
      "glue:GetDatabases",
      "glue:CreateDatabase",
      "glue:UpdateDatabase",
      "glue:DeleteDatabase",
      "glue:GetTable",
      "glue:GetTables",
      "glue:SearchTables",
      "glue:SchemaEdit",
      "glue:DeleteTable",
      "glue:UpdateTable"
    ]
    #tfsec:ignore:aws-iam-no-policy-wildcards
    resources = ["*"]
  }
}

resource "aws_iam_policy" "default" {
  name   = "Tabular${title(var.bucket_name)}"
  policy = data.aws_iam_policy_document.tabular.json
}

resource "aws_iam_role_policy_attachment" "default" {
  policy_arn = aws_iam_policy.default.arn
  role       = aws_iam_role.default.name
}

resource "aws_s3_bucket" "default" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_versioning" "default" {
  bucket = aws_s3_bucket.default.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_inventory" "default" {
  name                     = "${var.bucket_name}_inventory"
  bucket                   = aws_s3_bucket.default.id
  included_object_versions = "All"
  enabled                  = true

  destination {
    bucket {
      bucket_arn = aws_s3_bucket.default.arn
      format     = "Parquet"
      prefix     = "inventory"
    }
  }

  optional_fields = [
    "Size",
    "LastModifiedDate",
    "StorageClass",
    "ETag",
    "IsMultipartUploaded",
    "ReplicationStatus",
    "EncryptionStatus",
    "ObjectLockRetainUntilDate",
    "ObjectLockMode",
    "ObjectLockLegalHoldStatus",
    "IntelligentTieringAccessTier",
    "BucketKeyStatus"
  ]

  schedule {
    frequency = "Daily"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "default" {
  bucket = aws_s3_bucket.default.id

  rule {
    id     = "AbortIncompleteMultipartUpload"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = var.delete_recovery_days
    }

    noncurrent_version_expiration {
      noncurrent_days = var.delete_recovery_days
    }

    expiration {
      expired_object_delete_marker = true
    }
  }
}

resource "aws_s3_bucket_logging" "default" {
  bucket        = aws_s3_bucket.default.id
  target_bucket = aws_s3_bucket.default.id
  target_prefix = "access_logs/"
}

data "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["logging.s3.amazonaws.com"]
      type        = "Service"
    }
    actions = [
      "s3:PutObject"
    ]
    resources = ["${aws_s3_bucket.default.arn}/*"]
  }

  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
    actions = [
      "s3:PutObject"
    ]
    resources = ["${aws_s3_bucket.default.arn}/*"]

    condition {
      test     = "ArnLike"
      values   = [aws_s3_bucket.default.arn]
      variable = "aws:SourceArn"
    }
  }
}

resource "aws_s3_bucket_policy" "default" {
  bucket = aws_s3_bucket.default.id
  policy = data.aws_iam_policy_document.s3_bucket_policy.json
}

# S3 Buckets only support a single notification configuration. Declaring multiple aws_s3_bucket_notification resources
# to the same S3 Bucket will cause a perpetual difference in configuration. See the example
# "Trigger multiple Lambda functions" for an option.
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification
resource "aws_s3_bucket_notification" "default" {
  bucket = aws_s3_bucket.default.id

  queue {
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = "tabular/staged/"
    filter_suffix = "checksum"
    queue_arn     = "arn:aws:sqs:${var.tabular_region}:${var.tabular_account_id}:tabular-loader-s3-notifications-queue"
  }

  queue {
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = "access-logs/"
    filter_suffix = "checksum"
    queue_arn     = "arn:aws:sqs:${var.tabular_region}:${var.tabular_account_id}:warehouses-s3-access-logs"
  }

  topic {
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = "inventory/"
    filter_suffix = "checksum"
    topic_arn     = "arn:aws:sns:${var.tabular_region}:${var.tabular_account_id}:warehouses-s3-inventory-list-events"
  }
}