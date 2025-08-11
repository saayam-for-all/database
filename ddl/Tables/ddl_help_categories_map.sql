--drop table if exists virginia_dev_saayam_rdbms.help_category_map

create table if not exists virginia_dev_saayam_rdbms.help_category_map (
    parent_id VARCHAR(50),
    child_id VARCHAR(50) PRIMARY KEY, --one parent multiple child
    FOREIGN KEY (parent_id) REFERENCES virginia_dev_saayam_rdbms.help_categories(cat_id),
    FOREIGN KEY (child_id) REFERENCES virginia_dev_saayam_rdbms.help_categories(cat_id)
);

/* insertion is done by help_categories_map.csv file */
