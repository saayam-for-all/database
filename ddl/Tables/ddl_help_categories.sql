--drop table if exists virginia_dev_saayam_rdbms.help_category

create table if not exists virginia_dev_saayam_rdbms.help_categories (
    cat_id VARCHAR(50) PRIMARY KEY,           -- e.g., '1', '1.1', '1.1.1'
    cat_name VARCHAR(100) NOT NULL,                    -- string_key, e.g., 'DONATE_CLOTHES'
    cat_desc VARCHAR(150) NOT NULL                     -- purpose or goal of the category
);

/* insertion is done by help_categories.csv file 
0.0.0.0.0	GENERAL_CATEGORY	              GENERAL_CATEGORY_DESC
1	        FOOD_AND_ESSENTIALS_SUPPORT	      FOOD_AND_ESSENTIALS_SUPPORT_DESC
1.1	        FOOD_ASSISTANCE	                  FOOD_ASSISTANCE_DESC
*/
