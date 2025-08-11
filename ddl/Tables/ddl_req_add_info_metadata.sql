--drop table if exists virginia_dev_saayam_rdbms.req_add_info_metadata

-- Create the updated table
CREATE TABLE virginia_dev_saayam_rdbms.req_add_info_metadata (
    field_id VARCHAR(70) PRIMARY KEY,                         -- New primary key
    field_name_key VARCHAR(100),
    field_type VARCHAR(20),                                   -- 'string', 'int', 'float'
    status VARCHAR(10) DEFAULT 'active' CHECK (status IN ('active', 'inactive')),  -- Fixed syntax
    cat_id VARCHAR(50),                                       -- Moved to last column
    FOREIGN KEY (cat_id) REFERENCES virginia_dev_saayam_rdbms.help_category(cat_id)
);

-- Suggested Change: Consider using ENUM for status to avoid invalid text values

/* insertion is done by req_add_info_metadata.csv file */