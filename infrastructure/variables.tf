variable "gcp_project" {
  type        = string
  description = "GCP project name"
  default     = "maincra-test"
}

variable "user" {
  type        = string
  description = "unix user"
  default     = "maincra"
}

variable "use_backup" {
  type        = string
  description = "Specifies if a backup will be used, use yes if you have a zip named backup"
  default     = "no"
}