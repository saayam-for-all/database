-- Table: user_signoff
CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.user_signoff (
	signoff_id SERIAL PRIMARY KEY,
    reason VARCHAR(250)
);