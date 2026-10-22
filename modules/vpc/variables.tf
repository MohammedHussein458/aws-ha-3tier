variable "name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "azs" {
  type = list(string)
}

variable "public_subnets" {
  type = list(string)
}

variable "app_subnets" {
  type = list(string)
}

variable "db_subnets" {
  type = list(string)
}

variable "enable_nat" {
  type    = bool
  default = false
}