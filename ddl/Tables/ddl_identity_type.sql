-- Table: identity_type
CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.identity_type (
    identity_type_id SERIAL PRIMARY KEY,
    identity_value VARCHAR(255) NOT NULL,
    identity_type_dsc VARCHAR(255),
    last_updated_date TIMESTAMP,
    UNIQUE (identity_type_id)
);