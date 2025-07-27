drop table if exists req_add_info_metadata

create table if not exists req_add_info_metadata (
    cat_id VARCHAR(50),                       
    field_name_key VARCHAR(100),
    field_type VARCHAR(20),                        -- 'string', 'int', 'float'
    status VARCHAR(10) DEFAULT 'active' CHECK (status IN ('active', 'inactive')),           -- 'active' or 'inactive'
    PRIMARY KEY (cat_id, field_name_key),
    FOREIGN KEY (cat_id) REFERENCES help_category(cat_id)
);

-- Suggested Change: Consider using ENUM for status to avoid invalid text values

/* insertion is done by req_add_info_metadata.csv file */