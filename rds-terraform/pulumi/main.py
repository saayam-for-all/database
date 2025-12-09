"""
Pulumi script to deploy RDS PostgreSQL instance
"""

import pulumi
import pulumi_aws as aws

# Read configuration values
config = pulumi.Config()
aws_region = config.require("aws_region")
environment = config.require("environment")
db_instance_class = config.require("db_instance_class")
vpc_security_group_id = config.require("vpc_security_group_id")

# Optional configs
database_name = config.get("database_name") 
db_username = config.get("db_username")
db_password = config.require("db_password")  # Must provide password for now

# Create RDS instance
rds_instance = aws.rds.Instance(
    "postgres-db",
    identifier=f"{environment}-postgres-db",
    engine="postgres",
    instance_class=db_instance_class,
    allocated_storage=20,
    storage_type="",
    storage_encrypted=True,
    db_name=database_name,
    username=db_username,
    password=db_password,
    vpc_security_group_ids=[vpc_security_group_id],
    publicly_accessible=False,
    skip_final_snapshot=True,
    backup_retention_period=0,
    tags={
        "Name": f"{environment}-postgres-db",
        "Environment": environment,
    }
)

# Export basic outputs
pulumi.export("db_endpoint", rds_instance.endpoint)
pulumi.export("db_name", rds_instance.db_name)