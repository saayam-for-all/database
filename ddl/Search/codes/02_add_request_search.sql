-- Request search.
-- Prerequisite: run 01_enable_fuzzy_search.sql.
-- Set search_path to the target schema before running.

-- Request-local full-text vector.
ALTER TABLE request
ADD COLUMN IF NOT EXISTS search_vector tsvector
GENERATED ALWAYS AS (
    setweight(to_tsvector('english', coalesce(req_subj, '')), 'A') ||
    setweight(to_tsvector('english', coalesce(req_desc, '')), 'B') ||
    setweight(to_tsvector('english', coalesce(req_loc, '')), 'C')
) STORED;

-- Request indexes.
CREATE INDEX IF NOT EXISTS idx_request_search_vector
ON request USING GIN (search_vector);

CREATE INDEX IF NOT EXISTS idx_request_subj_trgm
ON request USING GIN (req_subj gin_trgm_ops);

CREATE INDEX IF NOT EXISTS idx_request_desc_trgm
ON request USING GIN (req_desc gin_trgm_ops);

CREATE INDEX IF NOT EXISTS idx_request_loc_trgm
ON request USING GIN (req_loc gin_trgm_ops);

-- Category indexes used by request search.
CREATE INDEX IF NOT EXISTS idx_help_categories_name_fts
ON help_categories
USING GIN (to_tsvector('english', coalesce(cat_name, '')));

CREATE INDEX IF NOT EXISTS idx_help_categories_name_trgm
ON help_categories USING GIN (cat_name gin_trgm_ops);

-- Request search entry point.
CREATE OR REPLACE FUNCTION search_requests(
    query_text TEXT,
    limit_results INT DEFAULT 20,
    requester_user_id VARCHAR(255) DEFAULT NULL,
    requester_access_level SMALLINT DEFAULT NULL,
    allowed_request_owner_ids VARCHAR(255)[] DEFAULT NULL
)
RETURNS TABLE (
    req_id VARCHAR(255),
    req_cat_id VARCHAR(50),
    cat_name VARCHAR(100),
    req_subj VARCHAR(125),
    req_desc VARCHAR(255),
    req_loc VARCHAR(125),
    req_status_id INT,
    req_priority_id INT,
    submission_date TIMESTAMP,
    relevance_score REAL
)
LANGUAGE plpgsql
SET search_path FROM CURRENT
AS $$
BEGIN
    IF query_text IS NULL OR btrim(query_text) = '' THEN
        RETURN;
    END IF;

    RETURN QUERY
    WITH query_input AS (
        SELECT plainto_tsquery('english', query_text) AS ts_query
    ),
    ranked AS (
        SELECT
            r.req_id,
            r.req_cat_id,
            hc.cat_name,
            r.req_subj,
            r.req_desc,
            r.req_loc,
            r.req_status_id,
            r.req_priority_id,
            r.submission_date,
            ts_rank_cd(
                setweight(
                    to_tsvector('english', replace(coalesce(hc.cat_name, ''), '_', ' ')),
                    'A'
                ) ||
                setweight(to_tsvector('english', coalesce(r.req_subj, '')), 'A') ||
                setweight(to_tsvector('english', coalesce(r.req_desc, '')), 'B') ||
                setweight(to_tsvector('english', coalesce(r.req_loc, '')), 'C'),
                qi.ts_query
            ) AS fts_score,
            GREATEST(
                similarity(replace(coalesce(hc.cat_name, ''), '_', ' '), query_text),
                word_similarity(query_text, replace(coalesce(hc.cat_name, ''), '_', ' ')),
                similarity(coalesce(r.req_subj, ''), query_text),
                word_similarity(query_text, coalesce(r.req_subj, '')),
                similarity(coalesce(r.req_desc, ''), query_text),
                word_similarity(query_text, coalesce(r.req_desc, '')),
                similarity(coalesce(r.req_loc, ''), query_text)
            ) AS fuzzy_score
        FROM request r
        JOIN help_categories hc
          ON hc.cat_id = r.req_cat_id
        CROSS JOIN query_input qi
        WHERE
            (
                coalesce(requester_access_level, 0) >= 4
                OR (
                    requester_user_id IS NOT NULL
                    AND r.req_user_id = requester_user_id
                )
                OR (
                    allowed_request_owner_ids IS NOT NULL
                    AND r.req_user_id = ANY(allowed_request_owner_ids)
                )
            )
            AND
            (
            (
                setweight(
                    to_tsvector('english', replace(coalesce(hc.cat_name, ''), '_', ' ')),
                    'A'
                ) ||
                r.search_vector
            ) @@ qi.ts_query
            OR to_tsvector('english', replace(coalesce(hc.cat_name, ''), '_', ' ')) @@ qi.ts_query
            OR coalesce(r.req_subj, '') % query_text
            OR coalesce(r.req_desc, '') % query_text
            OR coalesce(r.req_loc, '') % query_text
            OR replace(coalesce(hc.cat_name, ''), '_', ' ') % query_text
            OR word_similarity(query_text, replace(coalesce(hc.cat_name, ''), '_', ' ')) >= 0.45
            OR word_similarity(query_text, coalesce(r.req_subj, '')) >= 0.45
            OR word_similarity(query_text, coalesce(r.req_desc, '')) >= 0.45
            )
    )
    SELECT
        ranked.req_id,
        ranked.req_cat_id,
        ranked.cat_name,
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
-- SELECT * FROM search_requests('emergency medical');
