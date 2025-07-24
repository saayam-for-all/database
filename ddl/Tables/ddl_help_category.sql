drop table if exists help_category

create table if not exists TABLE help_category (
    category_id VARCHAR(50) PRIMARY KEY,           -- e.g., '1', '1.1', '1.1.1'
    cat_name VARCHAR(100) NOT NULL,                    -- string_key, e.g., 'DONATE_CLOTHES'
    cat_description TEXT NOT NULL,                     -- purpose or goal of the category
    path TEXT NOT NULL                             -- materialized path, e.g., '1/1.1/1.1.1'
);


-- Suggested Change: Add index on "path" for faster LIKE/prefix hierarchy queries

