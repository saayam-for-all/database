--drop table if exists virginia_dev_saayam_rdbms.req_add_info
CREATE TABLE req_add_info (
    id               SERIAL         PRIMARY KEY,       
    req_id           VARCHAR(255)   NOT NULL,
    field_id         VARCHAR(70)    NOT NULL,
    item_id          VARCHAR(100)   NULL,               -- FK to list_item_metadata (list-type fields)
    field_value VARCHAR(255)   NULL,               -- for string/int/float type fields

    UNIQUE (req_id, field_id, item_id),                 -- prevents duplicate answers

    FOREIGN KEY (req_id)   REFERENCES request(req_id),
    FOREIGN KEY (field_id) REFERENCES req_add_info_metadata(field_id),
    FOREIGN KEY (item_id)  REFERENCES list_item_metadata(item_id)  
);


1 /REQ-1 /1.3.1.A /1.3.1.A.1 /NULL
1 /REQ-1 /1.3.1.B /1.3.1.B.1 /NULL
1 /REQ-1 /1.3.1.B /1.3.1.B.2 /NULL
1 /REQ-1 /1.3.1.A / NULL/English
