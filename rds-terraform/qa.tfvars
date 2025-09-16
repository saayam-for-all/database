# =============================================================================
# tfvars to pass parameterized inputs tot he terraform script
# =============================================================================
# 1. We can create similar tfvars for different instances, this way the main terraform deployment script stays untouched and we can deploy the instance across different regions with custom parameters
===============================================================================

aws_region              = "eu-west-1"           # Placeholder for EU region, will update accordingly
environment             = "qa"                  #  environment
db_instance_class       = "db.t3.micro"         
vpc_security_group_id   = "" # saayam vpc group id

# Optional customizations 
database_name           = "saayam_qa_db"        # Placeholder Database name will update accordingly
db_username             = "qa_admin"             # Username
db_password             = "" # need to discuss on appropriate password passing approach
allocated_storage       = 20                    
backup_retention_period = 0                    
skip_final_snapshot     = true                  

