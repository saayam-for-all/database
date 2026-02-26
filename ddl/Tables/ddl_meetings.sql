-- Meetings table 
-- Timezone is WITHOUT TIMEZONE (UTC default)

SET TIME ZONE 'UTC';

CREATE TABLE meetings (
meeting_id VARCHAR(255) NOT NULL,
meeting_date DATE NOT NULL, 
start_time TIME WITHOUT TIME ZONE NOT NULL,
end_time TIME WITHOUT TIME ZONE NOT NULL,
cohost_id VARCHAR(255) NOT NULL,

-- Primary key constraint 
CONSTRAINT meetings_pk 
PRIMARY KEY(meeting_id, cohost_id),

--Unique idenitifer for table 
CONSTRAINT meetings_meeting_id_unique
UNIQUE(meeting_id), 

-- Foreign key constraint
CONSTRAINT meetings_fk
FOREIGN KEY (cohost_id)
REFERENCES users(user_id),

-- Time check constraint
CONSTRAINT meetings_time_chk 
CHECK (end_time>start_time)
 );