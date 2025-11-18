--drop table if exists virginia_dev_saayam_rdbms.req_add_info

create table if not exists virginia_dev_saayam_rdbms.req_add_info(
    req_id VARCHAR(255) NOT NULL,                        -- FK to Request
    field_id VARCHAR(70) NOT NULL,                       -- FK to req_add_info_metadata called questions
    item_ids TEXT,                                       -- stores the chosen answers
    PRIMARY KEY (req_id, field_id),
    FOREIGN KEY (req_id) REFERENCES virginia_dev_saayam_rdbms.request(req_id),
    FOREIGN KEY (field_id) REFERENCES virginia_dev_saayam_rdbms.req_add_info_metadata(field_id)
);

/* insertion is done by req_add_info.csv file */
