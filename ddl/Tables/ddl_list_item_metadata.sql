--drop table if exists virginia_dev_saayam_rdbms.list_item_metadata

CREATE TABLE virginia_dev_saayam_rdbms.list_item_metadata (
    item_id VARCHAR(100) PRIMARY KEY,
    field_id VARCHAR(70),
    item_value VARCHAR(100),
    item_type VARCHAR(20),  --examples: 'string', 'int', 'range', 'currency'
    FOREIGN KEY (field_id) REFERENCES virginia_dev_saayam_rdbms.req_add_info_metadata(field_id)
);

/* insertion is done by list_item_metadata.csv file 
1.1.A.1     1.1.A       VEG             string
1.1.A.2     1.1.A       NON-VEG         string
1.1.A.3     1.1.A       VEGAN           string
*/

