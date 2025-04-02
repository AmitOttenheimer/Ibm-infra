variable "trusted_profile_template_name" {
  description = "trusted profile template name"
  type        = string
  default     = "Wiz Trusted Profile Template"
}

variable "trusted_profile_template_description" {
  description = "trusted profile template description"
  type        = string
  default     = "Wiz Trusted Profile Template"
}

variable "trusted_profile_name" {
  description = "trusted profile name"
  type        = string
  default     = "Wiz Trusted Profile"
}

variable "wiz_service_id_identifier" {
  description = "wiz IBM service id identifier"
  type        = string
}

variable "wiz_service_id_iam_id" {
  description = "wiz IBM service id iam id"
  type        = string
}

variable "accounts" {
  description = "A list of account ids"
  type        = list(string)
  default     = []
}

variable "target_groups" {
  description = "A list of target groups"
  type        = list(string)
  default     = []
}
