variable "name" {
  type = string
}

variable "alert_email" {
  type = string
}

variable "db_identifier" {
  type = string
}

variable "enable_app" {
  type    = bool
  default = false
}

variable "alb_arn_suffix" {
  type    = string
  default = ""
}

variable "tg_arn_suffix" {
  type    = string
  default = ""
}

variable "asg_name" {
  type    = string
  default = ""
}