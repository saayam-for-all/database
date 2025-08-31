--drop table if exists virginia_dev_saayam_rdbms.req_add_info_metadata

CREATE TABLE virginia_dev_saayam_rdbms.req_add_info_metadata (
    field_id VARCHAR(70) PRIMARY KEY,                         --  primary key
    field_name_key VARCHAR(100),
    field_type VARCHAR(20),                                   -- examples: 'string', 'int', 'float', 'list'
    status VARCHAR(10) DEFAULT 'active' CHECK (status IN ('active', 'inactive')),  -- Fixed syntax
    cat_id VARCHAR(50),                                       
    FOREIGN KEY (cat_id) REFERENCES virginia_dev_saayam_rdbms.help_categories(cat_id)
);

-- Suggested Change: Consider using ENUM for status to avoid invalid text values

/* insertion is done by req_add_info_metadata.csv file 
1.1.A	PREFERRED_MEAL_TYPE	            string	active	1.1
1.1.B	DIETARY_RESTRICTIONS	        string	active	1.1
1.1.C	HOUSEHOLD_SIZE	                int	    active	1.1
*/