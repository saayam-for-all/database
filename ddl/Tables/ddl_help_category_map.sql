drop table if exists help_category_map

create table if not exists help_category_map (
    parent_id VARCHAR(50),
    child_id VARCHAR(50) PRIMARY KEY, --one parent multiple child
    FOREIGN KEY (parent_id) REFERENCES help_category(cat_id),
    FOREIGN KEY (child_id) REFERENCES help_category(cat_id)
);

/* insertion is done by help_category_map.csv file */
