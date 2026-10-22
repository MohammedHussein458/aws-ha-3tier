# ---------- باسورد عشوائي ----------
resource "random_password" "db" {
  length  = 20
  special = false # عشان RDS بيرفض بعض الرموز
}

# ---------- Subnet Group: بيقول لـ RDS يتحط في أنهي Subnets ----------
resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-db-subnets"
  subnet_ids = var.db_subnet_ids

  tags = { Name = "${var.name}-db-subnets" }
}

# ---------- قاعدة البيانات ----------
resource "aws_db_instance" "this" {
  identifier = "${var.name}-db"

  engine         = "mysql"
  instance_class = var.instance_class

  allocated_storage = 20
  storage_type      = "gp2"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  password = random_password.db.result

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.db_sg_id]
  publicly_accessible    = false
  multi_az               = var.multi_az

  backup_retention_period = var.backup_retention_days

  # إعدادات بيئة dev (في prod بنعكسهم)
  skip_final_snapshot = true
  deletion_protection = false
  apply_immediately   = true

  tags = { Name = "${var.name}-db" }
}

# ---------- الأسرار في SSM Parameter Store ----------
resource "aws_ssm_parameter" "password" {
  name  = "/${var.name}/db/password"
  type  = "SecureString"
  value = random_password.db.result
}

resource "aws_ssm_parameter" "username" {
  name  = "/${var.name}/db/username"
  type  = "String"
  value = var.db_username
}

resource "aws_ssm_parameter" "host" {
  name  = "/${var.name}/db/host"
  type  = "String"
  value = aws_db_instance.this.address
}

resource "aws_ssm_parameter" "dbname" {
  name  = "/${var.name}/db/name"
  type  = "String"
  value = var.db_name
}