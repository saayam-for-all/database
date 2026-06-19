CREATE TABLE virginia_dev_saayam_rdbms.meeting_participants(
    meeting_id VARCHAR(255) NOT NULL,
    participant_id VARCHAR(255) NOT NULL, 

    --Unique identifer for table 
    CONSTRAINT meeting_participant_pk 
    PRIMARY KEY (meeting_id, participant_id),

    -- Foreign key constraint for meeting_id
    CONSTRAINT meeting_participant_meetingid_fk
    FOREIGN KEY (meeting_id) 
    REFERENCES meetings(meeting_id),

    -- Foreign key constraint for participant_id
    CONSTRAINT meeting_participant_participant_fk
    FOREIGN KEY (participant_id)
    REFERENCES users(user_id)

);

-- INDEXING 

-- Index to pull participants for a particular meeting
CREATE INDEX IF NOT EXISTS mp_meeting_id_idx
ON meeting_participants(meeting_id); 

