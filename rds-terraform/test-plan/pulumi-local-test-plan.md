# Pulumi Local Test Plan

## Document purpose

This test plan verifies the Pulumi implementation in `rds-terraform/pulumi/` without creating real AWS resources. The goal is to catch local setup issues, syntax errors, configuration problems, and resource-definition mistakes before running against AWS.

## Scope

This plan covers:

- Pulumi project structure validation
- Python dependency setup
- Static code checks
- Pulumi config validation
- Pulumi preview behavior with mocked or non-deploying workflows
- Unit-style validation of the RDS resource definition

This plan does **not** create, update, or delete real AWS infrastructure.

## Directory under test

```text
rds-terraform/pulumi/
├── Pulumi.yaml
├── Pulumi.dev.yaml
├── README.md
└── main.py
```

## Known issues to check before testing

These issues should be fixed or explicitly tracked before local testing is considered complete:

| Area | Current issue | Expected fix |
|---|---|---|
| Config namespace | `Pulumi.yaml` uses project name `rds-qa-infra`, but `Pulumi.dev.yaml` uses keys under `rds-deployment:*` | Use one consistent namespace, usually `rds-qa-infra:*` |
| Storage type | `main.py` sets `storage_type=""` | Set to `gp2`, `gp3`, or omit the field |
| AWS region | `aws_region` is read but not applied to a Pulumi AWS provider | Configure `aws:region` or create an explicit AWS provider using that region |
| Required values | security group ID, database name, username, and password are empty in `Pulumi.dev.yaml` | Use safe dummy/local values for local validation, and real secure values only for AWS testing |
| Secrets | `db_password` should be stored as a Pulumi secret | Use `pulumi config set --secret db_password <value>` |

## Test environment

Recommended local versions:

```bash
python --version
pulumi version
pip --version
```

Minimum expectations:

- Python 3.10+
- Pulumi CLI installed
- `pulumi_aws` Python package installed
- Local shell access to the repository

## Setup steps

From the Pulumi directory:

```bash
cd rds-terraform/pulumi
python -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install pulumi pulumi-aws pytest ruff
```

Optional: create a `requirements.txt` so local and CI installs are repeatable.

```bash
cat > requirements.txt <<'REQ'
pulumi
pulumi-aws
pytest
ruff
REQ
```

## Test cases

### TC-L1: Verify Pulumi project files exist

**Objective:** Confirm the Pulumi project has the required files.

**Steps:**

```bash
test -f Pulumi.yaml
test -f Pulumi.dev.yaml
test -f main.py
```

**Expected result:**

All commands exit successfully.

---

### TC-L2: Validate Python syntax

**Objective:** Confirm `main.py` is valid Python.

**Steps:**

```bash
python -m py_compile main.py
```

**Expected result:**

The command exits successfully with no syntax errors.

---

### TC-L3: Run basic linting

**Objective:** Catch obvious code-quality and import issues.

**Steps:**

```bash
ruff check main.py
```

**Expected result:**

No lint errors, or only approved warnings documented in the test notes.

---

### TC-L4: Validate Pulumi project metadata

**Objective:** Confirm the project name is what the config expects.

**Steps:**

```bash
cat Pulumi.yaml
cat Pulumi.dev.yaml
```

**Expected result:**

The project name in `Pulumi.yaml` should match the namespace used in `Pulumi.dev.yaml`.

Example expected alignment:

```yaml
# Pulumi.yaml
name: rds-qa-infra
```

```yaml
# Pulumi.dev.yaml
config:
  rds-qa-infra:aws_region: "eu-west-1"
  rds-qa-infra:environment: "dev"
```

---

### TC-L5: Initialize or select the local Pulumi stack

**Objective:** Confirm Pulumi can read the project locally.

**Steps:**

```bash
pulumi stack select dev || pulumi stack init dev
```

**Expected result:**

The `dev` stack is selected or created successfully.

---

### TC-L6: Validate required config keys exist

**Objective:** Confirm all required config values are present.

**Steps:**

```bash
pulumi config
```

Check for:

```text
aws_region
environment
db_instance_class
vpc_security_group_id
database_name
db_username
db_password
```

**Expected result:**

All required keys are present. `db_password` is marked as secret.

---

### TC-L7: Set safe local test config

**Objective:** Use non-production placeholder values for local validation.

**Steps:**

```bash
pulumi config set aws_region eu-west-1
pulumi config set environment dev
pulumi config set db_instance_class db.t3.micro
pulumi config set vpc_security_group_id sg-00000000000000000
pulumi config set database_name saayam_dev_db
pulumi config set db_username dev_admin
pulumi config set --secret db_password 'replace-with-local-test-secret'
```

If using Pulumi's AWS provider region directly, also run:

```bash
pulumi config set aws:region eu-west-1
```

**Expected result:**

Config is saved locally. The password appears as a secret.

---

### TC-L8: Preview without approving changes

**Objective:** Confirm Pulumi can build the resource graph.

**Steps:**

```bash
pulumi preview
```

**Expected result:**

Pulumi shows one planned RDS instance named similar to:

```text
postgres-db
```

The preview should not fail due to missing config, invalid Python, or invalid Pulumi resource arguments.

**Important:** A preview may still contact AWS for provider checks. This test should not be treated as a deployment.

---

### TC-L9: Unit-style resource validation with Pulumi mocks

**Objective:** Validate the resource definition without AWS credentials.

**Suggested file:** `test_main.py`

```python
import pulumi
from pulumi.runtime import mocks


class PulumiMocks(mocks.Mocks):
    def new_resource(self, args: mocks.MockResourceArgs):
        outputs = dict(args.inputs)
        outputs["id"] = f"{args.name}_id"
        outputs["endpoint"] = "mock-endpoint.rds.amazonaws.com"
        return [f"{args.name}_id", outputs]

    def call(self, args: mocks.MockCallArgs):
        return {}


pulumi.runtime.set_mocks(PulumiMocks())


def test_rds_instance_definition():
    # Import after mocks are set.
    import main  # noqa: F401

    # A stronger version of this test can expose the rds_instance object
    # from main.py and assert its expected output properties.
```

**Steps:**

```bash
pytest -q
```

**Expected result:**

Tests pass without real AWS credentials.

---

### TC-L10: Verify no production secrets are committed

**Objective:** Make sure sensitive values are not stored in plain text.

**Steps:**

```bash
grep -R "db_password" -n .
grep -R "password" -n .
```

**Expected result:**

No real password appears in committed files. Any password in `Pulumi.*.yaml` is stored under `secure:`.

## Local test exit criteria

Local testing is complete when:

- `main.py` compiles successfully
- linting passes or known warnings are documented
- Pulumi stack config is complete
- config namespace matches the project name
- `storage_type` is valid or removed
- password is configured as a secret
- `pulumi preview` succeeds without creating resources
- mock-based tests pass, if implemented

## Recommended local fixes before AWS testing

Update `main.py` so the AWS region is actually used and storage type is valid. Example pattern:

```python
provider = aws.Provider("aws-provider", region=aws_region)

rds_instance = aws.rds.Instance(
    "postgres-db",
    identifier=f"{environment}-postgres-db",
    engine="postgres",
    instance_class=db_instance_class,
    allocated_storage=20,
    storage_type="gp2",
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
    },
    opts=pulumi.ResourceOptions(provider=provider),
)
```
