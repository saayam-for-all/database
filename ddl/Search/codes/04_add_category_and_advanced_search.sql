-- Organization search.
-- Prerequisite: run 01_enable_fuzzy_search.sql.
-- Set search_path to the target schema before running.

-- Organization indexes.
CREATE INDEX IF NOT EXISTS idx_organizations_name_trgm
ON organizations USING GIN (org_name gin_trgm_ops);

CREATE INDEX IF NOT EXISTS idx_organizations_city_trgm
ON organizations USING GIN (city_name gin_trgm_ops);

-- Organization search entry point.
CREATE OR REPLACE FUNCTION search_organizations(
    query_text TEXT,
    limit_results INT DEFAULT 20,
    requester_access_level SMALLINT DEFAULT NULL,
    allowed_org_ids VARCHAR(255)[] DEFAULT NULL
)
RETURNS TABLE (
    org_id VARCHAR(255),
    org_name VARCHAR(125),
    city_name VARCHAR(100),
    state_code VARCHAR(6),
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
        SELECT btrim(query_text) AS raw_query
    ),
    ranked AS (
        SELECT
            o.org_id,
            o.org_name,
            o.city_name,
            o.state_code,
            GREATEST(
                similarity(coalesce(o.org_name, ''), qi.raw_query),
                word_similarity(qi.raw_query, coalesce(o.org_name, ''))
            ) AS org_score,
            GREATEST(
                similarity(coalesce(o.city_name, ''), qi.raw_query),
                word_similarity(qi.raw_query, coalesce(o.city_name, ''))
            ) AS city_score
        FROM organizations o
        CROSS JOIN query_input qi
        WHERE
            (
                coalesce(requester_access_level, 0) >= 4
                OR (
                    allowed_org_ids IS NOT NULL
                    AND o.org_id = ANY(allowed_org_ids)
                )
            )
            AND
            (
                coalesce(o.org_name, '') % qi.raw_query
                OR coalesce(o.city_name, '') % qi.raw_query
                OR word_similarity(qi.raw_query, coalesce(o.org_name, '')) >= 0.45
                OR word_similarity(qi.raw_query, coalesce(o.city_name, '')) >= 0.45
            )
    )
    SELECT
        ranked.org_id,
        ranked.org_name,
        ranked.city_name,
        ranked.state_code,
        (
            ranked.org_score * 0.70 +
            ranked.city_score * 0.30
        )::REAL AS relevance_score
    FROM ranked
    ORDER BY relevance_score DESC, org_name ASC, org_id ASC
    LIMIT GREATEST(limit_results, 1);
END;
$$;

-- Example usage:
-- SELECT * FROM search_organizations('Saayam Foundation');
