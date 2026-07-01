-- User search.
-- Prerequisite: run 01_enable_fuzzy_search.sql.
-- Set search_path to the target schema before running.

-- User-local full-text vector.
ALTER TABLE users
ADD COLUMN IF NOT EXISTS search_vector tsvector
GENERATED ALWAYS AS (
    setweight(
        to_tsvector(
            'english',
            coalesce(full_name, '') || ' ' ||
            coalesce(first_name, '') || ' ' ||
            coalesce(last_name, '')
        ),
        'A'
    ) ||
    setweight(to_tsvector('simple', coalesce(primary_email_address, '')), 'B')
) STORED;

-- User indexes.
CREATE INDEX IF NOT EXISTS idx_users_search_vector
ON users USING GIN (search_vector);

CREATE INDEX IF NOT EXISTS idx_users_full_name_trgm
ON users USING GIN (full_name gin_trgm_ops);

CREATE INDEX IF NOT EXISTS idx_users_email_trgm
ON users USING GIN (primary_email_address gin_trgm_ops);

CREATE INDEX IF NOT EXISTS idx_users_email_exact
ON users (primary_email_address);

-- User search entry point.
CREATE OR REPLACE FUNCTION search_users(
    query_text TEXT,
    limit_results INT DEFAULT 20,
    requester_user_id VARCHAR(255) DEFAULT NULL,
    requester_access_level SMALLINT DEFAULT NULL,
    allowed_user_ids VARCHAR(255)[] DEFAULT NULL
)
RETURNS TABLE (
    user_id VARCHAR(255),
    full_name VARCHAR(255),
    primary_email_address VARCHAR(255),
    user_category_id INT,
    user_status_id INT,
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
        SELECT
            btrim(query_text) AS raw_query,
            plainto_tsquery('english', query_text) AS name_ts_query,
            plainto_tsquery('simple', query_text) AS email_ts_query
    ),
    ranked AS (
        SELECT
            u.user_id,
            u.full_name,
            u.primary_email_address,
            u.user_category_id,
            u.user_status_id,
            GREATEST(
                ts_rank_cd(u.search_vector, qi.name_ts_query),
                ts_rank_cd(u.search_vector, qi.email_ts_query)
            ) AS fts_score,
            GREATEST(
                similarity(coalesce(u.full_name, ''), qi.raw_query),
                word_similarity(qi.raw_query, coalesce(u.full_name, '')),
                similarity(coalesce(u.primary_email_address, ''), qi.raw_query)
            ) AS fuzzy_score,
            CASE
                WHEN lower(coalesce(u.primary_email_address, '')) = lower(qi.raw_query) THEN 1.0
                ELSE 0.0
            END AS exact_email_score
        FROM users u
        CROSS JOIN query_input qi
        WHERE
            (
                coalesce(requester_access_level, 0) >= 4
                OR (
                    requester_user_id IS NOT NULL
                    AND u.user_id = requester_user_id
                )
                OR (
                    allowed_user_ids IS NOT NULL
                    AND u.user_id = ANY(allowed_user_ids)
                )
            )
            AND
            (
                u.search_vector @@ qi.name_ts_query
                OR u.search_vector @@ qi.email_ts_query
                OR coalesce(u.full_name, '') % qi.raw_query
                OR word_similarity(qi.raw_query, coalesce(u.full_name, '')) >= 0.45
                OR similarity(coalesce(u.primary_email_address, ''), qi.raw_query) >= 0.60
                OR lower(coalesce(u.primary_email_address, '')) = lower(qi.raw_query)
            )
    )
    SELECT
        ranked.user_id,
        ranked.full_name,
        ranked.primary_email_address,
        ranked.user_category_id,
        ranked.user_status_id,
        (
            ranked.exact_email_score * 1.00 +
            ranked.fts_score * 0.60 +
            ranked.fuzzy_score * 0.40
        )::REAL AS relevance_score
    FROM ranked
    ORDER BY relevance_score DESC, full_name ASC NULLS LAST, user_id ASC
    LIMIT GREATEST(limit_results, 1);
END;
$$;

-- Example usage:
-- SELECT * FROM search_users('arup');
