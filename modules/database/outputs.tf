output "db_endpoint" {
  value = aws_db_instance.this.address
}

output "db_name" {
  value = var.db_name
}


output "db_identifier" {
  value = aws_db_instance.this.identifier
}