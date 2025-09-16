==========================================================================
# Main Terraform Script to create the RDS instance based on passed values#
==========================================================================

terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"    # Official AWS provider from HashiCorp
      version = "~> 5.0"           
    }
  }
  required_version = ">= 1.0"      
}

# =============================================================================
# AWS PROVIDER CONFIGURATION
# =============================================================================
provider "aws" {
  region = var.aws_region          # region we specify in variables
}


# =============================================================================
# RDS POSTGRESQL DATABASE INSTANCE
# =============================================================================

resource "aws_db_instance" "postgres_db" {
  
  # -------------------------------------------------------------------------
  # BASIC DATABASE CONFIGURATION
  # -------------------------------------------------------------------------
  identifier     = "${var.environment}-postgres-db"  
  engine         = "postgres"                         
  instance_class = var.db_instance_class             

  # -------------------------------------------------------------------------
  # STORAGE CONFIGURATION 
  # -------------------------------------------------------------------------
  allocated_storage = var.allocated_storage          
  storage_type      = "gp2"                         # General Purpose SSD (cheapest option)
  storage_encrypted = true                          # Encrypt data at rest (FREE security feature)

  # -------------------------------------------------------------------------
  # DATABASE ACCESS CREDENTIALS
  # -------------------------------------------------------------------------
  db_name  = var.database_name                      # Name of the database inside PostgreSQL
  username = var.db_username                        # Admin username for database
  
  password = var.db_password

  # -------------------------------------------------------------------------
  # NETWORK SECURITY CONFIGURATION
  # -------------------------------------------------------------------------
  vpc_security_group_ids = [var.vpc_security_group_id]  
  publicly_accessible    = false                        # NO public internet access
  

  # -------------------------------------------------------------------------
  # BACKUP CONFIGURATION 
  # -------------------------------------------------------------------------
  backup_retention_period = var.backup_retention_period  # How many days to keep backups

  # -------------------------------------------------------------------------
  # CLEANUP CONFIGURATION
  # -------------------------------------------------------------------------
  skip_final_snapshot = var.skip_final_snapshot      # When deleting DB:
  # true = Delete immediately 
  # false = Take final backup before deleting (costs extra)

  # -------------------------------------------------------------------------
  # OPTIONAL: RESOURCE TAGS FOR ORGANIZATION
  # -------------------------------------------------------------------------
  # These are just labels - they don't cost anything but help organize resources
  tags = {
    Name        = "${var.environment}-postgres-db"   
    Environment = var.environment                     
  }
}

