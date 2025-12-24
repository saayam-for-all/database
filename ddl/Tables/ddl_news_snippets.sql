CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.news_snippets (
-- Unique ID for each news entry
news_id SERIAL PRIMARY KEY,
    
-- The title or short headline of the news snippet
headline VARCHAR(255) NOT NULL,

-- The detailed text explaining the activity (a couple of sentences)
snippet_text TEXT NOT NULL,

-- The secure S3 path to the image file (URL or Key)
image_path TEXT,

-- JSON to store one or more LinkedIn URLs for mentioned people
-- E.g., [{"name": "PersonA", "url": "..."}]
profile_links JSONB DEFAULT '[]'::jsonb,

-- The date the event occurred, used for chronological ordering 
event_date DATE NOT NULL,
    
-- When the record was created in the DB
created_at TIMESTAMP DEFAULT NOW(),

last_updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TRIGGER trg_news_snippets_updated_at
BEFORE UPDATE ON virginia_dev_saayam_rdbms.news_snippets
FOR EACH ROW
EXECUTE FUNCTION virginia_dev_saayam_rdbms.set_updated_at();
