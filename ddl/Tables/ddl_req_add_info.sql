--drop table if exists virginia_dev_saayam_rdbms.req_add_info

create table if not exists virginia_dev_saayam_rdbms.req_add_info(
    request_id VARCHAR(255),                             -- FK to Request(request_id)
    cat_id VARCHAR(50),                       -- FK to Help_Category(category_id)
    field_name_key VARCHAR(100),
    field_value TEXT,
    PRIMARY KEY (request_id, field_name_key),
    FOREIGN KEY (request_id) REFERENCES virginia_dev_saayam_rdbms.request(request_id),
    FOREIGN KEY (cat_id) REFERENCES virginia_dev_saayam_rdbms.help_category(cat_id)
);

/* insertion is done by req_add_info.csv file */