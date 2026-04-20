# Saayam Search Implementation Plan

## Overview

This document outlines our finalized two-phase approach to implementing comprehensive search capabilities for the Saayam platform using PostgreSQL native features.

---

## Table of Contents

- [Phase 1: Full-Text Search (FTS) + pg_trgm](#phase-1-full-text-search-fts--pg_trgm)
  - [What We're Implementing](#what-were-implementing)
  - [Why This Approach](#why-this-approach)
  - [Phase 1: Implementation Checklist](#phase-1-implementation-checklist)
    - [Stage 1: Setup & Foundation](#stage-1-setup--foundation)
    - [Stage 2: Request Search Implementation](#stage-2-request-search-implementation)
    - [Stage 3: User & Volunteer Search](#stage-3-user--volunteer-search)
    - [Stage 4: Categories & Advanced Features](#stage-4-categories--advanced-features)
    - [Stage 5: Testing & Optimization](#stage-5-testing--optimization)
  - [Phase 1: Expected Outcomes](#phase-1-expected-outcomes)
- [Phase 2: Semantic Search with pgvector](#phase-2-semantic-search-with-pgvector)
  - [What Is Semantic Search?](#what-is-semantic-search)
  - [Why Add pgvector?](#why-add-pgvector)
  - [How pgvector Works](#how-pgvector-works)
  - [Phase 2: Implementation Checklist](#phase-2-implementation-checklist)
    - [Stage 1: pgvector Setup](#stage-1-pgvector-setup)
    - [Stage 2: Hybrid Search Implementation](#stage-2-hybrid-search-implementation)
    - [Stage 3: Testing & Integration](#stage-3-testing--integration)
  - [Phase 2: Expected Outcomes](#phase-2-expected-outcomes)
- [Success Metrics & Monitoring](#success-metrics--monitoring)
- [Quick Start Guide](#quick-start-guide)
- [Resources & Documentation](#resources--documentation)
- [Implementation Summary](#implementation-summary)

---

## Phase 1: Full-Text Search (FTS) + pg_trgm

**Status:** Finalized for Implementation  
**Implementation:** 5 Stages  
**Cost:** $0 (uses existing RDS infrastructure)

### What We're Implementing

PostgreSQL native Full-Text Search combined with the pg_trgm extension to provide:

- **Keyword Search:** Find help requests, users, and volunteers by exact terms
- **Fuzzy Matching:** Handle typos and partial matches automatically
- **Ranked Results:** Return most relevant results first
- **Multi-language Support:** Search in English, Hindi, Spanish, and more
- **Autocomplete:** Provide typeahead suggestions as users type
- **Real-time Indexing:** Updates automatically with data changes

### Why This Approach

- **Zero Infrastructure Cost:** Runs inside existing RDS instance
- **No Data Sync Issues:** Search data is always consistent with database
- **ACID Compliance:** Maintains transactional integrity
- **Battle-Tested:** PostgreSQL FTS has 15+ years in production use
- **Scalable:** Handles 1M-10M records efficiently
- **Easy Maintenance:** One-time setup, auto-updating via triggers

---

## Phase 1: Implementation Checklist

### Stage 1: Setup & Foundation

**Objective:** Enable extensions and prepare infrastructure

- [ ] **Enable pg_trgm extension** on RDS PostgreSQL
  - Connect to QA database
  - Run: `CREATE EXTENSION IF NOT EXISTS pg_trgm;`
  - Verify installation
  - Test on QA environment
- [ ] **Backup production database** before changes
- [ ] **Document rollback procedure**
- [ ] **Create migration scripts directory** (`database/ddl/Search/`)

**Deliverables:**

- `01_enable_extensions.sql` - Extension setup script
- Rollback documentation
- QA environment tested and verified

---

### Stage 2: Request Search Implementation

**Objective:** Enable search on help requests (highest priority)

**Target Table:** `request`  
**Searchable Fields:** `req_subj`, `req_desc`, `req_loc`

**Tasks:**

- [ ] **Add search_vector column** to request table

  ```sql
  ALTER TABLE request ADD COLUMN search_vector tsvector
    GENERATED ALWAYS AS (
      to_tsvector('english',
        coalesce(req_subj, '') || ' ' ||
        coalesce(req_desc, '') || ' ' ||
        coalesce(req_loc, '')
      )
    ) STORED;
  ```

- [ ] **Create GIN indexes** for fast searching

  ```sql
  -- Full-text search index
  CREATE INDEX idx_request_search_vector
    ON request USING GIN(search_vector);

  -- Fuzzy/typo tolerance indexes
  CREATE INDEX idx_request_subj_trgm
    ON request USING GIN(req_subj gin_trgm_ops);

  CREATE INDEX idx_request_desc_trgm
    ON request USING GIN(req_desc gin_trgm_ops);
  ```

- [ ] **Create search function**

  ```sql
  CREATE FUNCTION search_requests(
    query_text TEXT,
    limit_results INT DEFAULT 20
  ) RETURNS TABLE (...) AS $$ ... $$;
  ```

- [ ] **Test queries**
  - Keyword search: "emergency medical help"
  - Fuzzy search: "emergancy" → finds "emergency"
  - Location search: "San Jose"
  - Phrase search: "urgent medical assistance"

**Deliverables:**

- `02_request_search.sql` - Complete implementation
- Search function for API integration
- Test query results documented

**PRD Alignment:**

- ✓ Users can search help requests by keywords
- ✓ Search handles typos automatically
- ✓ Results ranked by relevance
- ✓ Search performance <100ms

---

### Stage 3: User & Volunteer Search

**Objective:** Enable searching for users and volunteers

**Target Tables:** `users`, `volunteer_details`  
**Searchable Fields:**

- Users: `full_name`, `first_name`, `last_name`, `primary_email_address`
- Volunteers: `skills` (JSONB), location, availability

**Tasks:**

- [ ] **Add search columns to users table**

  ```sql
  ALTER TABLE users ADD COLUMN search_vector tsvector
    GENERATED ALWAYS AS (
      to_tsvector('english',
        coalesce(full_name, '') || ' ' ||
        coalesce(primary_email_address, '') || ' ' ||
        coalesce(city_name, '')
      )
    ) STORED;
  ```

- [ ] **Create indexes**

  ```sql
  CREATE INDEX idx_users_search_vector
    ON users USING GIN(search_vector);

  CREATE INDEX idx_users_name_trgm
    ON users USING GIN(full_name gin_trgm_ops);
  ```

- [ ] **Handle JSONB skill search** in volunteer_details

  ```sql
  CREATE INDEX idx_volunteer_skills_gin
    ON volunteer_details USING GIN(skills jsonb_path_ops);
  ```

- [ ] **Create volunteer search view**
  - Combine user info + volunteer details + skills
  - Include availability and location

- [ ] **Create search functions**
  - `search_users(query_text)` - Find users by name/email
  - `search_volunteers(query_text, skills)` - Find volunteers by skills

**Deliverables:**

- `03_user_volunteer_search.sql` - Implementation
- Volunteer matching function
- Admin search API queries

**PRD Alignment:**

- ✓ Admin can search users by name/email
- ✓ System can match volunteers by skills
- ✓ Search handles name variations (Jon → John)
- ✓ Volunteer discovery by location and skills

---

### Stage 4: Categories & Advanced Features

**Objective:** Complete search implementation with categories and enhancements

**Target Tables:** `help_categories`, `organizations`

**Tasks:**

- [ ] **Add FTS to help_categories**

  ```sql
  ALTER TABLE help_categories ADD COLUMN search_vector tsvector
    GENERATED ALWAYS AS (
      to_tsvector('english',
        coalesce(cat_name, '') || ' ' ||
        coalesce(cat_desc, '')
      )
    ) STORED;
  ```

- [ ] **Implement category autocomplete**
  - Typeahead suggestions as users type
  - Use pg_trgm for partial matching

- [ ] **Add multi-language support**
  - Configure text search for Hindi, Spanish
  - Create language-specific dictionaries

  ```sql
  CREATE TEXT SEARCH CONFIGURATION hindi (COPY = simple);
  CREATE TEXT SEARCH CONFIGURATION spanish (COPY = spanish);
  ```

- [ ] **Implement search filters**
  - Date range (submission_date, serviced_date)
  - Location (city, state)
  - Status (req_status_id)
  - Priority (req_priority_id)
  - Category (req_cat_id)

- [ ] **Add search highlighting**
  - Show matched terms in results
  - Use `ts_headline` function

- [ ] **Create search analytics table**

  ```sql
  CREATE TABLE search_logs (
    log_id SERIAL PRIMARY KEY,
    query_text TEXT,
    user_id VARCHAR(255),
    results_count INT,
    execution_time_ms INT,
    searched_at TIMESTAMP DEFAULT NOW()
  );
  ```

**Deliverables:**

- `04_categories_advanced_search.sql` - Implementation
- Autocomplete API endpoint
- Multi-language search configuration
- Search analytics dashboard queries

**PRD Alignment:**

- ✓ Users can browse/search help categories
- ✓ Autocomplete suggests relevant categories
- ✓ Multi-language search support
- ✓ Search analytics for improving UX
- ✓ Filter results by multiple criteria

---

### Stage 5: Testing & Optimization

**Objective:** Ensure production readiness and optimal performance

**Tasks:**

- [ ] **Performance testing**
  - Test with 10K, 100K, 1M records
  - Measure query latency (target: <100ms p95)
  - Test concurrent searches (target: 100+ simultaneous)

- [ ] **Optimize indexes**
  - Analyze index usage: `pg_stat_user_indexes`
  - Remove unused indexes
  - Adjust GIN index parameters if needed

- [ ] **Add query result caching**
  - Cache frequent searches (Redis or pg_prewarm)
  - Set appropriate TTL (5-15 minutes)

- [ ] **Setup monitoring**
  - CloudWatch metrics for query performance
  - Alerts for slow queries (>500ms)
  - Track search usage patterns

- [ ] **Load testing**
  - Simulate 1000 concurrent searches
  - Test under peak load conditions
  - Verify no performance degradation

- [ ] **Documentation**
  - API documentation for search endpoints
  - Query examples and best practices
  - Troubleshooting guide

**Deliverables:**

- Performance benchmark report
- CloudWatch dashboard
- Load testing results
- Complete search API documentation

**PRD Alignment:**

- ✓ Search performs under load (<100ms)
- ✓ System monitoring in place
- ✓ Production-ready implementation
- ✓ Documentation for developers

---

## Phase 1: Expected Outcomes

### Performance Metrics

| Metric                | Target | How We Measure              |
| --------------------- | ------ | --------------------------- |
| Query Latency (p95)   | <100ms | CloudWatch metrics          |
| Index Update Time     | <10ms  | PostgreSQL logs             |
| Autocomplete Response | <50ms  | API monitoring              |
| Concurrent Users      | 100+   | Load testing                |
| Search Relevance      | >95%   | User feedback / A/B testing |

### PRD Requirements Met

**Search Functionality:**

- ✓ Full-text keyword search across requests
- ✓ Fuzzy matching for typos (1-2 character errors)
- ✓ Ranked results by relevance
- ✓ Multi-field search (title, description, location)
- ✓ Autocomplete/typeahead suggestions
- ✓ Filter by date, status, priority, category, location

**User Experience:**

- ✓ Fast response times (<100ms)
- ✓ Handles misspellings gracefully
- ✓ Shows relevant results first
- ✓ Multi-language support (English, Hindi, Spanish)

**Admin Features:**

- ✓ Search users by name/email
- ✓ Find volunteers by skills/location
- ✓ Search analytics dashboard
- ✓ Filter and export search results

**Technical Requirements:**

- ✓ Zero additional infrastructure cost
- ✓ ACID compliant (consistent results)
- ✓ Auto-updating indexes
- ✓ Scalable to 1M+ records

---

## Phase 2: Semantic Search with pgvector

**Status:** Future Enhancement (6-12 months)  
**Implementation:** 3 Stages  
**Cost:** $20-50/month (OpenAI embeddings)

### What Is Semantic Search?

Semantic search understands the **meaning** of queries, not just exact keywords:

- **Example 1:** Search "heart attack" → finds "cardiac arrest", "chest pain", "myocardial infarction"
- **Example 2:** Search "feeling alone" → finds "depression", "isolation", "loneliness"
- **Example 3:** Search "need doctor" → finds "medical help", "physician", "healthcare"

### Why Add pgvector?

**Advantages Over FTS + pg_trgm:**

1. **Conceptual Understanding**
   - FTS: Matches words literally
   - pgvector: Understands synonyms and related concepts

2. **Cross-Language Search**
   - Search in English → find Hindi/Spanish results
   - Unified search across languages

3. **Duplicate Detection**
   - Find similar requests automatically
   - Prevent duplicate help requests

4. **Smarter Volunteer Matching**
   - Match volunteers based on skill semantics
   - "Python developer" matches "software engineer", "programmer"

5. **Better User Experience**
   - Users don't need exact keywords
   - More forgiving search
   - Higher result relevance

### How pgvector Works

```
1. User searches: "need help with groceries"
   ↓
2. Convert query to embedding (vector): [0.23, -0.45, 0.67, ...]
   ↓
3. Find requests with similar embeddings (cosine similarity)
   ↓
4. Return: "food assistance", "meal delivery", "grocery shopping help"
```

**Embeddings** = Numeric representations of text meaning (1536 dimensions)

---

## Phase 2: Implementation Checklist

### Stage 1: pgvector Setup

**Objective:** Enable pgvector and generate embeddings

**Tasks:**

- [ ] **Enable pgvector extension**

  ```sql
  CREATE EXTENSION IF NOT EXISTS vector;
  ```

- [ ] **Add embedding columns**

  ```sql
  ALTER TABLE request
    ADD COLUMN search_embedding vector(1536);

  ALTER TABLE users
    ADD COLUMN profile_embedding vector(1536);

  ALTER TABLE volunteer_details
    ADD COLUMN skills_embedding vector(1536);
  ```

- [ ] **Create vector indexes**

  ```sql
  CREATE INDEX idx_request_embedding
    ON request USING ivfflat(search_embedding vector_cosine_ops)
    WITH (lists = 100);
  ```

- [ ] **Setup embedding generation**
  - Option A: OpenAI API integration
  - Option B: Self-hosted model (sentence-transformers)
  - Create Lambda/script for batch generation

- [ ] **Generate embeddings for existing data**
  - Batch process: 1000 records at a time
  - Estimate: ~10K requests × $0.0001 = $1 one-time

**Deliverables:**

- `05_pgvector_setup.sql` - Schema changes
- Embedding generation script
- Cost analysis and monitoring

---

### Stage 2: Hybrid Search Implementation

**Objective:** Combine FTS + pg_trgm + pgvector for best results

**Tasks:**

- [ ] **Create hybrid search function**

  ```sql
  CREATE FUNCTION search_requests_hybrid(
    query_text TEXT,
    query_embedding vector(1536),
    keyword_weight FLOAT DEFAULT 0.4,
    fuzzy_weight FLOAT DEFAULT 0.2,
    semantic_weight FLOAT DEFAULT 0.4
  ) RETURNS TABLE (...) AS $$
    -- Combine all three search methods
    -- Weight and rank results
  $$ LANGUAGE plpgsql;
  ```

- [ ] **Implement semantic duplicate detection**
  - Find similar requests automatically
  - Alert users about existing requests
  - Reduce duplicate help requests

- [ ] **Enhanced volunteer matching**
  - Match by skill embeddings
  - Consider semantic similarity
  - Rank volunteers by relevance

- [ ] **Cross-language search**
  - Generate embeddings in multiple languages
  - Unified search experience

**Deliverables:**

- `06_hybrid_search.sql` - Complete implementation
- Duplicate detection service
- Enhanced volunteer matching algorithm

---

### Stage 3: Testing & Integration

**Objective:** Validate semantic search quality and integrate with API

**Tasks:**

- [ ] **Quality testing**
  - Test semantic search accuracy
  - Compare with FTS-only results
  - A/B test with real users

- [ ] **Performance tuning**
  - Optimize vector index parameters
  - Test query latency (target: <150ms)
  - Cache embeddings for frequent queries

- [ ] **API integration**
  - Update search endpoints
  - Add hybrid search option
  - Backward compatible with Phase 1

- [ ] **Cost monitoring**
  - Track embedding API usage
  - Optimize batch generation
  - Set budget alerts

**Deliverables:**

- Quality comparison report
- Updated API documentation
- Cost monitoring dashboard

---

## Phase 2: Expected Outcomes

### Enhanced Capabilities

| Feature             | Phase 1 (FTS + pg_trgm) | Phase 2 (+ pgvector) | Improvement |
| ------------------- | ----------------------- | -------------------- | ----------- |
| Keyword match       | Excellent               | Excellent            | Same        |
| Typo tolerance      | Excellent               | Excellent            | Same        |
| Synonym matching    | None                    | Excellent            | ✓ New       |
| Conceptual search   | None                    | Excellent            | ✓ New       |
| Cross-language      | Limited                 | Excellent            | ✓ Major     |
| Duplicate detection | Manual                  | Automatic            | ✓ New       |
| Relevance score     | Good (85%)              | Excellent (95%+)     | ✓ +10%      |

### PRD Requirements Met (Additional)

**Enhanced Search:**

- ✓ Understands synonyms and related concepts
- ✓ Cross-language search capability
- ✓ Finds conceptually similar requests
- ✓ Automatic duplicate detection

**Smarter Matching:**

- ✓ Semantic volunteer-to-request matching
- ✓ Skill-based recommendations
- ✓ Context-aware search results

**User Experience:**

- ✓ More forgiving search (no exact keywords needed)
- ✓ Higher relevance scores
- ✓ Reduced duplicate requests

### Cost Analysis

**Monthly Operational Cost:**

| Component                           | Cost       | Notes                            |
| ----------------------------------- | ---------- | -------------------------------- |
| Infrastructure                      | $0         | Uses existing RDS                |
| Embedding generation (new requests) | $5-10      | ~50-100 requests/day             |
| Embedding generation (users)        | $1-2       | ~10-20 new users/day             |
| API calls (search)                  | $10-20     | Cached embeddings, minimal calls |
| **Total Monthly**                   | **$20-50** | Scales with usage                |

**One-time Setup Cost:**

- Existing data embeddings: ~$1-5 (10K-50K records)

---

## Success Metrics & Monitoring

### Phase 1 Metrics

```sql
-- Query performance
SELECT
  AVG(execution_time_ms) as avg_latency,
  PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY execution_time_ms) as p95_latency,
  COUNT(*) as total_searches
FROM search_logs
WHERE searched_at > NOW() - INTERVAL '24 hours';

-- Search volume
SELECT
  DATE(searched_at) as date,
  COUNT(*) as searches,
  COUNT(DISTINCT user_id) as unique_users
FROM search_logs
GROUP BY DATE(searched_at)
ORDER BY date DESC;

-- Popular queries
SELECT
  query_text,
  COUNT(*) as frequency,
  AVG(results_count) as avg_results
FROM search_logs
GROUP BY query_text
ORDER BY frequency DESC
LIMIT 20;
```

### Phase 2 Metrics

```sql
-- Semantic search quality
SELECT
  query_text,
  search_type, -- 'keyword' vs 'semantic'
  AVG(click_through_rate) as ctr,
  AVG(time_to_first_click) as engagement
FROM search_analytics
GROUP BY query_text, search_type;

-- Duplicate detection effectiveness
SELECT
  COUNT(*) as duplicates_prevented,
  SUM(estimated_time_saved_hours) as hours_saved
FROM duplicate_detections
WHERE detected_at > NOW() - INTERVAL '30 days';
```

---

## Quick Start Guide

### Running Phase 1 Implementation

```bash
# 1. Connect to your database
psql -h your-rds-endpoint.rds.amazonaws.com \
     -U postgres \
     -d virginia_dev_saayam_rdbms

# 2. Run migration scripts in order
\i database/ddl/Search/codes/01_enable_fuzzy_search.sql
\i database/ddl/Search/codes/02_add_request_search.sql
\i database/ddl/Search/codes/03_add_user_and_volunteer_search.sql
\i database/ddl/Search/codes/04_add_category_and_advanced_search.sql

# 3. Test search functionality
SELECT * FROM search_requests('emergency medical');
SELECT * FROM search_users('john');
SELECT * FROM search_volunteers('python programming');

# 4. Verify indexes
SELECT schemaname, tablename, indexname, idx_scan
FROM pg_stat_user_indexes
WHERE tablename IN ('request', 'users', 'volunteer_details');
```

### Running Phase 2 Implementation

```bash
# 1. Enable pgvector
\i database/ddl/Search/codes/05_enable_semantic_search_pgvector.sql

# 2. Generate embeddings (Python script)
python scripts/generate_embeddings.py --batch-size 1000

# 3. Implement hybrid search
\i database/ddl/Search/codes/06_add_hybrid_search.sql

# 4. Test semantic search
SELECT * FROM search_requests_hybrid(
  'need help with groceries',
  get_embedding('need help with groceries')
);
```

---

## Resources & Documentation

### PostgreSQL Documentation

- [Full-Text Search](https://www.postgresql.org/docs/current/textsearch.html)
- [pg_trgm Extension](https://www.postgresql.org/docs/current/pgtrgm.html)
- [pgvector Extension](https://github.com/pgvector/pgvector)

### Implementation Guides

- `database/ddl/Search/00_pgvector_integration_guide.md` - Detailed pgvector integration
- API documentation (to be created in Phase 1, Stage 5)

### Support

- PostgreSQL community forums
- pgvector GitHub issues
- OpenAI API documentation (for embeddings)

---

## Implementation Summary

**Phase 1 (FTS + pg_trgm):**

- Stage 1: Setup & Foundation
- Stage 2: Request Search
- Stage 3: User & Volunteer Search
- Stage 4: Categories & Advanced Features
- Stage 5: Testing & Optimization
- **Total: 5 Stages, Production-ready**

**Phase 2 (+ pgvector):**

- Stage 1: pgvector Setup
- Stage 2: Hybrid Search Implementation
- Stage 3: Testing & Integration
- **Total: 3 Stages, Enhanced capabilities**

**Recommended Start for Phase 2:** 6-12 months after Phase 1 deployment, based on user feedback and search analytics.
