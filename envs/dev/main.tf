variable "region" {
  default = "eu-central-1"
}

variable "enable_nat" {
  default = false
}

variable "multi_az" {
  default = false
}

variable "alert_email" {
  type = string
}

variable "enable_compute" {
  default = false
}

variable "enable_edge" {
  default = false
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project   = "ha-3tier"
      Env       = "dev"
      ManagedBy = "terraform"
    }
  }
}

module "vpc" {
  source = "../../modules/vpc"

  name           = "ha3tier-dev"
  vpc_cidr       = "10.0.0.0/16"
  azs            = ["${var.region}a", "${var.region}b"]
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  app_subnets    = ["10.0.11.0/24", "10.0.12.0/24"]
  db_subnets     = ["10.0.21.0/24", "10.0.22.0/24"]
  enable_nat     = var.enable_nat
}

module "security" {
  source = "../../modules/security"

  name   = "ha3tier-dev"
  vpc_id = module.vpc.vpc_id
}

module "database" {
  source = "../../modules/database"

  name          = "ha3tier-dev"
  db_subnet_ids = module.vpc.db_subnet_ids
  db_sg_id      = module.security.db_sg_id
  multi_az      = var.multi_az
}

module "compute" {
  count  = var.enable_compute ? 1 : 0
  source = "../../modules/compute"

  name                  = "ha3tier-dev"
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  app_subnet_ids        = module.vpc.app_subnet_ids
  alb_sg_id             = module.security.alb_sg_id
  app_sg_id             = module.security.app_sg_id
  instance_profile_name = module.security.instance_profile_name
}

module "edge" {
  count  = var.enable_edge && var.enable_compute ? 1 : 0
  source = "../../modules/edge"

  name         = "ha3tier-dev"
  alb_dns_name = module.compute[0].alb_dns_name
}

module "monitoring" {
  source = "../../modules/monitoring"

  name          = "ha3tier-dev"
  alert_email   = var.alert_email
  db_identifier = module.database.db_identifier

  enable_app     = var.enable_compute
  alb_arn_suffix = try(module.compute[0].alb_arn_suffix, "")
  tg_arn_suffix  = try(module.compute[0].tg_arn_suffix, "")
  asg_name       = try(module.compute[0].asg_name, "")
}

output "alb_url" {
  value = try("http://${module.compute[0].alb_dns_name}", "compute disabled")
}

output "cloudfront_url" {
  value = try("https://${module.edge[0].cloudfront_domain}", "edge disabled")
}