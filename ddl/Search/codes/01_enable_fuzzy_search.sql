-- Phase 1 / Stage 1: Enable required extension for fuzzy search
-- Safe to run multiple times
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Optional verification query
-- SELECT extname FROM pg_extension WHERE extname = 'pg_trgm';
