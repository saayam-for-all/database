drop table if exists req_add_info

create table if not exists req_add_info(
    request_id BIGINT,                             -- FK to Request(request_id)
    category_id VARCHAR(50),                       -- FK to Help_Category(category_id)
    field_name_key VARCHAR(100),
    field_value TEXT,
    PRIMARY KEY (request_id, field_name_key),
    FOREIGN KEY (request_id) REFERENCES request(request_id),
    FOREIGN KEY (category_id) REFERENCES help_category(category_id)
);
