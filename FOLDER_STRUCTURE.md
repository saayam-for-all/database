# Database Repository Folder Structure - All Regions

## Proposed Structure
database/
├── schema/ # Core database schemas
│ ├── tables/
│ │ ├── users.sql
│ │ ├── requests.sql
│ │ ├── organizations.sql
│ │ ├── fraud_requests.sql
│ │ ├── countries.sql
│ │ └── ... (all tables)
│ ├── functions/
│ ├── sequences/
│ └── triggers/
│
├── regions/ # Region-specific setup
│ ├── virginia/
│ │ ├── init/
│ │ ├── migrations/
│ │ └── config.yml
│ ├── ireland/
│ │ ├── init/
│ │ ├── migrations/
│ │ └── config.yml
│ └── stockholm/
│ ├── init/
│ ├── migrations/
│ └── config.yml
│
├── dml/ # Data files
│ ├── seed-data/
│ ├── virginia/
│ ├── ireland/
│ └── stockholm/
│
├── scripts/
│ ├── deploy.sh
│ ├── validate.sh
│ └── script-library/
│
└── docs/
├── SCHEMA.md
├── REGIONS.md
└── DEPLOYMENT.md


## Rationale
- All table definitions in one place (schema/tables/)
- Each region has its own config file for region-specific settings
- No duplicate schema files
- Easy to add new regions
- Clear separation between schemas and region setup
