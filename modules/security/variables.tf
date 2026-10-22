variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "app_port" {
  type    = number
  default = 80
}

variable "db_port" {
  type    = number
  default = 3306
}