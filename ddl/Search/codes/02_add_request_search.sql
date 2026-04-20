-- Phase 1 / Stage 2: Request search
-- Prerequisite: run 01_enable_fuzzy_search.sql (pg_trgm extension)

-- 1) Add full-text generated column
ALTER TABLE virginia_dev_saayam_rdbms.request
ADD COLUMN IF NOT EXISTS search_vector tsvector
GENERATED ALWAYS AS (
    to_tsvector(
        'english',
        coalesce(req_subj, '') || ' ' ||
        coalesce(req_desc, '') || ' ' ||
        coalesce(req_loc, '')
    )
) STORED;

-- 2) Create indexes for fast full-text and fuzzy matching
CREATE INDEX IF NOT EXISTS idx_request_search_vector
ON virginia_dev_saayam_rdbms.request USING GIN (search_vector);

CREATE INDEX IF NOT EXISTS idx_request_subj_trgm
ON virginia_dev_saayam_rdbms.request USING GIN (req_subj gin_trgm_ops);

CREATE INDEX IF NOT EXISTS idx_request_desc_trgm
ON virginia_dev_saayam_rdbms.request USING GIN (req_desc gin_trgm_ops);

CREATE INDEX IF NOT EXISTS idx_request_loc_trgm
ON virginia_dev_saayam_rdbms.request USING GIN (req_loc gin_trgm_ops);

-- 3) Unified request search function (keyword + typo tolerance)
CREATE OR REPLACE FUNCTION virginia_dev_saayam_rdbms.search_requests(
    query_text TEXT,
    limit_results INT DEFAULT 20
)
RETURNS TABLE (
    req_id VARCHAR(255),
    req_subj VARCHAR(125),
    req_desc VARCHAR(255),
    req_loc VARCHAR(125),
    req_status_id INT,
    req_priority_id INT,
    submission_date TIMESTAMP,
    relevance_score REAL
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF query_text IS NULL OR btrim(query_text) = '' THEN
        RETURN;
    END IF;

    RETURN QUERY
    WITH ranked AS (
        SELECT
            r.req_id,
            r.req_subj,
            r.req_desc,
            r.req_loc,
            r.req_status_id,
            r.req_priority_id,
            r.submission_date,
            ts_rank_cd(
                r.search_vector,
                plainto_tsquery('english', query_text)
            ) AS fts_score,
            GREATEST(
                similarity(coalesce(r.req_subj, ''), query_text),
                similarity(coalesce(r.req_desc, ''), query_text),
                similarity(coalesce(r.req_loc, ''), query_text)
            ) AS fuzzy_score
        FROM virginia_dev_saayam_rdbms.request r
        WHERE
            r.search_vector @@ plainto_tsquery('english', query_text)
            OR coalesce(r.req_subj, '') % query_text
            OR coalesce(r.req_desc, '') % query_text
            OR coalesce(r.req_loc, '') % query_text
    )
    SELECT
        ranked.req_id,
        ranked.req_subj,
        ranked.req_desc,
        ranked.req_loc,
        ranked.req_status_id,
        ranked.req_priority_id,
        ranked.submission_date,
        (ranked.fts_score * 0.70 + ranked.fuzzy_score * 0.30)::REAL AS relevance_score
    FROM ranked
    ORDER BY relevance_score DESC, submission_date DESC NULLS LAST
    LIMIT GREATEST(limit_results, 1);
END;
$$;

-- Example usage:
-- SELECT * FROM virginia_dev_saayam_rdbms.search_requests('emergency medical');
