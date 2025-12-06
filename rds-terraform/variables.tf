# =============================================================================
# TERRAFORM VARIABLES DEFINITION FILE
# =============================================================================
# This file defines all the parameters you can customize when deploying
# the database.

# =============================================================================
# REQUIRED VARIABLES
# =============================================================================

variable "aws_region" {
  description = "AWS region where the database will be created (e.g., eu-west-1 for Ireland)"
  type        = string
  # Example values:
  # - "eu-west-1"     = Ireland
  # - "eu-central-1"  = Frankfurt 
  # - "eu-west-2"     = London
  # - "us-east-1"     = N. Virginia
}

variable "environment" {
  description = "Environment name - used in naming and tagging resources"
  type        = string
  # Example values: "qa", "staging", "prod", "dev"
  
}

variable "db_instance_class" {
  description = "The size/type of the database server"
  type        = string
}

variable "vpc_security_group_id" {
  description = "ID of your existing VPC security group"
  type        = string
}

# =============================================================================
# OPTIONAL VARIABLES (Have defaults but can be customized)
# =============================================================================

variable "database_name" {
  description = "Name of the database that will be created inside PostgreSQL"
  type        = string
  default     = "saayam_db"
  
}

variable "db_username" {
  description = "Admin username for the database"
  type        = string
  default     = "saayam_admin"
}

variable "db_password" {
  description = "Password for the database admin user"
  type        = string
  default     = ""           
  sensitive   = true         # Terraform won't display this in logs
  
}

variable "allocated_storage" {
  description = "Initial database storage size in GB"
  type        = number
  default     = 20
  
}

variable "backup_retention_period" {
  description = "How many days to keep automatic database backups (0 = no backups)"
  type        = number
  default     = 0            # No backups by default ()
  
}

variable "skip_final_snapshot" {
  description = "Skip taking a final backup when deleting the database"
  type        = bool
  default     = true         # Skip by default (faster deletion, no extra cost)
  
}
