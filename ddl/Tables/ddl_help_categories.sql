--drop table if exists virginia_dev_saayam_rdbms.help_category

create table if not exists virginia_dev_saayam_rdbms.help_categories (
    cat_id VARCHAR(50) PRIMARY KEY,           -- e.g., '1', '1.1', '1.1.1'
    cat_name VARCHAR(100) NOT NULL,                    -- string_key, e.g., 'DONATE_CLOTHES'
    cat_desc TEXT NOT NULL                     -- purpose or goal of the category
);

/* insertion is done by help_categories.csv file */
