variable "bucket_name" {
  description = "Name used for S3 Bucket resource."
  type        = string
}

variable "name" {
  description = "Name used for resources."
  type        = string
}

variable "retention" {
  description = "Retention in days for log files in S3 Bucket and CloudWatch Logs group."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags used for all created resources."
  type        = map(string)
  default     = {}
}

variable "prevent_s3_destruction" {
  default     = true
  description = "Prevent the destruction of the S3 Bucket"
  type        = bool
}
