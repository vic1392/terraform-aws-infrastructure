output "db_instance_id" {
  description = "RDS instance identifier"
  value       = aws_db_instance.this.id
}

output "db_instance_arn" {
  description = "RDS instance ARN"
  value       = aws_db_instance.this.arn
}

output "db_endpoint" {
  description = "Connection endpoint (host:port)"
  value       = aws_db_instance.this.endpoint
}

output "db_address" {
  description = "Hostname (without port)"
  value       = aws_db_instance.this.address
}

output "db_port" {
  description = "Database port"
  value       = aws_db_instance.this.port
}

output "db_name" {
  description = "Initial database name"
  value       = aws_db_instance.this.db_name
}

output "db_username" {
  description = "Master username"
  value       = aws_db_instance.this.username
  sensitive   = true
}

output "db_password" {
  description = "Master password"
  value       = local.master_password
  sensitive   = true
}

output "secret_arn" {
  description = "ARN of the Secrets Manager secret with credentials"
  value       = aws_secretsmanager_secret.this.arn
}

output "read_replica_endpoint" {
  description = "Read replica endpoint (null if not created)"
  value       = var.create_read_replica ? aws_db_instance.replica[0].endpoint : null
}
