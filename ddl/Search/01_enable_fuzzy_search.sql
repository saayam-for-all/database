-- Enable trigram support for fuzzy search.
-- Idempotent: Can run multiple times
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Verify extension install.
-- SELECT extname FROM pg_extension WHERE extname = 'pg_trgm';
