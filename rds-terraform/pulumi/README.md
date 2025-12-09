# RDS PostgreSQL Deployment - DEV Environment

Deploy AWS RDS PostgreSQL database for development using Pulumi.

## Quick Start

### 1. Install Requirements
```bash
pip install pulumi pulumi-aws
```
### 2. Edit Configuration

Open `Pulumi.dev.yaml` and replace:
- `` with your actual AWS Security Group ID

### 3. Deploy
```bash
# Preview what will be created
pulumi preview

# Create the database
pulumi up
```

## 4. Delete Everything
```bash
pulumi destroy
```
