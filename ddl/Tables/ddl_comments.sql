-- Table: comments
CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.comments (
    comment_id SERIAL PRIMARY KEY,
    request_id VARCHAR(255) NOT NULL,
    user_id VARCHAR(255) NOT NULL,
    comment_desc TEXT NOT NULL,
    comment_date TIMESTAMP NOT NULL,
    FOREIGN KEY (request_id) REFERENCES virginia_dev_saayam_rdbms.requests (request_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (user_id) REFERENCES virginia_dev_saayam_rdbms.users (user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Indexes
CREATE INDEX IF NOT EXISTS fk_comments_request_id_idx ON virginia_dev_saayam_rdbms.comments (request_id);
CREATE INDEX IF NOT EXISTS fk_comments_user_id_idx ON virginia_dev_saayam_rdbms.comments (user_id);
