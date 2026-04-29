# Pulumi AWS Test Plan

## Document purpose

This test plan verifies the Pulumi deployment of the Saayam PostgreSQL RDS instance in AWS. Unlike the local test plan, this plan creates real AWS infrastructure, validates it, and then destroys it unless the test environment is intentionally retained.

## Scope

This plan covers:

- Pulumi deployment to AWS
- AWS RDS instance creation
- security group attachment
- private accessibility behavior
- encryption-at-rest validation
- PostgreSQL connection validation from an approved network path
- output validation
- cleanup and destroy validation

This plan does **not** validate the full application database schema or application backend behavior.

## AWS resources under test

The Pulumi script is expected to create one AWS RDS PostgreSQL instance with these intended characteristics:

| Property | Expected value |
|---|---|
| Engine | PostgreSQL |
| Instance identifier | `<environment>-postgres-db` |
| Instance class | Config value, for example `db.t3.micro` |
| Storage | 20 GB |
| Storage encryption | Enabled |
| Public accessibility | Disabled |
| Security group | Existing security group from config |
| Backups | `0` days for dev/test unless changed |
| Final snapshot on destroy | Skipped for dev/test unless changed |

## Required approvals and safeguards

Before running this plan, confirm:

- The AWS account is approved for dev/test infrastructure.
- The selected region is approved, for example `eu-west-1`.
- The security group allows PostgreSQL access only from approved sources.
- The database username and password are test-only credentials.
- The RDS cost is approved.
- A cleanup owner is assigned.

## Prerequisites

Local tools:

```bash
python --version
pulumi version
aws --version
psql --version
```

AWS prerequisites:

- AWS credentials configured locally or in CI.
- IAM permissions to create, read, tag, and delete RDS instances.
- IAM permissions to read VPC and security group data.
- An existing VPC security group for the database.
- A network path for testing PostgreSQL access, such as a bastion host, VPN, ECS task, EC2 instance, or CloudShell/VPC-connected runner.

## Recommended test stack

Use a short-lived stack name such as:

```bash
pulumi stack init aws-dev-test
pulumi stack select aws-dev-test
```

Use an environment value that makes the resource clearly temporary:

```bash
pulumi config set environment dev-test
```

This should produce an RDS identifier similar to:

```text
dev-test-postgres-db
```

## Configuration steps

From the Pulumi directory:

```bash
cd rds-terraform/pulumi
python -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install pulumi pulumi-aws
```

Set AWS and database config:

```bash
pulumi config set aws_region eu-west-1
pulumi config set aws:region eu-west-1
pulumi config set environment dev-test
pulumi config set db_instance_class db.t3.micro
pulumi config set vpc_security_group_id <approved-security-group-id>
pulumi config set database_name saayam_dev_test_db
pulumi config set db_username dev_test_admin
pulumi config set --secret db_password '<strong-test-password>'
```

Confirm config:

```bash
pulumi config
```

Expected result:

- Region is set.
- Security group ID is populated.
- Database name is populated.
- Username is populated.
- Password is marked secret.

## Test cases

### TC-A1: Verify AWS identity and region

**Objective:** Confirm deployment will run in the intended AWS account and region.

**Steps:**

```bash
aws sts get-caller-identity
aws configure get region
pulumi config get aws_region
pulumi config get aws:region
```

**Expected result:**

The AWS account and region match the approved test environment.

---

### TC-A2: Validate security group exists

**Objective:** Confirm the configured security group exists before deployment.

**Steps:**

```bash
SG_ID=$(pulumi config get vpc_security_group_id)
aws ec2 describe-security-groups --group-ids "$SG_ID"
```

**Expected result:**

AWS returns the configured security group.

---

### TC-A3: Preview AWS changes

**Objective:** Review planned infrastructure before creation.

**Steps:**

```bash
pulumi preview
```

**Expected result:**

Pulumi plans to create one RDS instance. No unexpected resources should appear.

Fail the test if:

- The region is wrong.
- The identifier points to prod or a shared environment accidentally.
- The plan includes unexpected resources.
- The storage type or resource arguments are invalid.

---

### TC-A4: Deploy RDS instance

**Objective:** Create the test RDS instance.

**Steps:**

```bash
pulumi up
```

Approve the deployment only after checking the preview.

**Expected result:**

Pulumi completes successfully and exports at least:

```text
db_endpoint
db_name
```

---

### TC-A5: Validate Pulumi outputs

**Objective:** Confirm deployment outputs are available and usable.

**Steps:**

```bash
pulumi stack output db_endpoint
pulumi stack output db_name
```

**Expected result:**

- `db_endpoint` is populated.
- `db_name` matches the configured database name.

---

### TC-A6: Validate RDS instance in AWS

**Objective:** Confirm the RDS instance exists with expected properties.

**Steps:**

```bash
DB_ID="$(pulumi config get environment)-postgres-db"
aws rds describe-db-instances --db-instance-identifier "$DB_ID"
```

Check these fields:

```text
Engine
DBInstanceClass
AllocatedStorage
StorageEncrypted
PubliclyAccessible
VpcSecurityGroups
DBInstanceStatus
```

**Expected result:**

- Engine is PostgreSQL.
- Instance class matches Pulumi config.
- Storage is 20 GB.
- Storage encryption is enabled.
- Public accessibility is false.
- Security group matches the configured security group.
- Instance status eventually becomes `available`.

---

### TC-A7: Validate database is not public

**Objective:** Confirm the database is not exposed directly to the internet.

**Steps:**

```bash
DB_ID="$(pulumi config get environment)-postgres-db"
aws rds describe-db-instances \
  --db-instance-identifier "$DB_ID" \
  --query 'DBInstances[0].PubliclyAccessible'
```

**Expected result:**

```text
false
```

---

### TC-A8: Validate PostgreSQL connectivity from approved network path

**Objective:** Confirm the database can be reached only from the intended network path.

Run this from an approved source such as a bastion, EC2 instance, VPN-connected workstation, or other VPC-connected environment.

**Steps:**

```bash
ENDPOINT=$(pulumi stack output db_endpoint | cut -d: -f1)
DB_NAME=$(pulumi stack output db_name)
DB_USER=$(pulumi config get db_username)

psql "host=$ENDPOINT port=5432 dbname=$DB_NAME user=$DB_USER sslmode=require"
```

When prompted, enter the test database password.

Then run:

```sql
SELECT version();
SELECT current_database();
SELECT current_user;
```

**Expected result:**

- Connection succeeds from the approved network path.
- PostgreSQL returns version information.
- Current database matches `saayam_dev_test_db` or the configured database name.
- Current user matches the configured database username.

---

### TC-A9: Validate blocked access from unapproved network path

**Objective:** Confirm the database cannot be accessed from an unauthorized location.

**Steps:**

From a machine not allowed by the security group, attempt:

```bash
ENDPOINT=<rds-endpoint-without-port>
psql "host=$ENDPOINT port=5432 dbname=saayam_dev_test_db user=dev_test_admin sslmode=require"
```

**Expected result:**

Connection fails or times out. This is expected because `publicly_accessible` is false and the security group should restrict inbound access.

---

### TC-A10: Validate tags

**Objective:** Confirm AWS tags were applied.

**Steps:**

```bash
DB_ARN=$(aws rds describe-db-instances \
  --db-instance-identifier "$(pulumi config get environment)-postgres-db" \
  --query 'DBInstances[0].DBInstanceArn' \
  --output text)

aws rds list-tags-for-resource --resource-name "$DB_ARN"
```

**Expected result:**

Tags include:

```text
Name = <environment>-postgres-db
Environment = <environment>
```

---

### TC-A11: Validate Pulumi refresh

**Objective:** Confirm Pulumi state matches AWS.

**Steps:**

```bash
pulumi refresh
```

**Expected result:**

Pulumi detects no unexpected drift, or any drift is documented and explained.

---

### TC-A12: Destroy test infrastructure

**Objective:** Remove AWS resources created for the test.

**Steps:**

```bash
pulumi destroy
```

Then verify deletion:

```bash
aws rds describe-db-instances --db-instance-identifier "$(pulumi config get environment)-postgres-db"
```

**Expected result:**

Pulumi destroy completes successfully. The AWS CLI describe command eventually returns not found.

---

### TC-A13: Remove test stack if no longer needed

**Objective:** Clean up Pulumi stack state after successful destroy.

**Steps:**

```bash
pulumi stack rm aws-dev-test
```

**Expected result:**

The temporary stack is removed.

## AWS test exit criteria

AWS testing is complete when:

- Preview shows only expected resources.
- RDS instance deploys successfully.
- RDS instance becomes available.
- RDS is encrypted at rest.
- RDS is not publicly accessible.
- Configured security group is attached.
- PostgreSQL connection succeeds from an approved network path.
- PostgreSQL connection fails from an unapproved network path.
- Pulumi outputs are correct.
- Tags are correct.
- `pulumi refresh` shows no unexplained drift.
- Test infrastructure is destroyed unless there is an approved reason to keep it.

## Rollback plan

If deployment fails:

1. Capture the Pulumi error output.
2. Run:

   ```bash
   pulumi stack
   pulumi refresh
   ```

3. Check whether a partial RDS instance was created:

   ```bash
   aws rds describe-db-instances
   ```

4. If a partial resource exists and is safe to remove, run:

   ```bash
   pulumi destroy
   ```

5. If Pulumi state and AWS are out of sync, document the resource ID before manually deleting anything.

## Risks and mitigations

| Risk | Mitigation |
|---|---|
| Accidental production deployment | Use a dedicated stack and temporary environment name such as `dev-test` |
| Unexpected AWS cost | Destroy the stack immediately after validation |
| Public database exposure | Validate `PubliclyAccessible=false` and review security group rules |
| Secret leakage | Use Pulumi secrets for `db_password`; do not commit real credentials |
| Wrong region | Validate both AWS CLI region and Pulumi region before preview/apply |
| Orphaned RDS instance | Verify destroy with AWS CLI after `pulumi destroy` |

## Recommended production-readiness checks after this test

Before adapting this Pulumi code for production, consider adding:

- subnet group configuration
- explicit VPC and subnet selection
- deletion protection for production
- backup retention greater than zero
- final snapshot enabled for production
- parameter group and engine version pinning
- CloudWatch logs exports
- monitoring and alarms
- secret retrieval from AWS Secrets Manager or another secure store
- environment-specific stacks for dev, QA, staging, and prod
