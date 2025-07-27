drop table if exists help_category

create table if not exists help_category (
    cat_id VARCHAR(50) PRIMARY KEY,           -- e.g., '1', '1.1', '1.1.1'
    cat_name VARCHAR(100) NOT NULL,                    -- string_key, e.g., 'DONATE_CLOTHES'
    cat_desc TEXT NOT NULL                     -- purpose or goal of the category
);

/* insertion is done by help_category.csv file */
