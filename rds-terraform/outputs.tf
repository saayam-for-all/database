

# =============================================================================
# DATABASE CONNECTION INFORMATION
# =============================================================================

output "db_endpoint" {
  description = "Database server address/hostname for connections"
  value       = aws_db_instance.postgres_db.endpoint
  
}

output "db_port" {
  description = "Database port number"
  value       = aws_db_instance.postgres_db.port
  
}

output "db_name" {
  description = "Database name to connect to"
  value       = aws_db_instance.postgres_db.db_name
}

output "db_username" {
  description = "Database admin username"
  value       = aws_db_instance.postgres_db.username
  sensitive   = true 
}


# =============================================================================
# AWS RESOURCE INFORMATION
# =============================================================================

output "db_instance_id" {
  description = "AWS RDS instance identifier"
  value       = aws_db_instance.postgres_db.id
 
}

output "db_security_group_id" {
  description = "Security group ID attached to the database"
  value       = var.vpc_security_group_id
  
}

