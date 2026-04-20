# pgvector Integration Guide

## Seamlessly Adding Semantic Search to Existing FTS

---

## ✅ YES - All Three Extensions Work Together Perfectly

You can combine:

1. **Native FTS** - Keyword search
2. **pg_trgm** - Fuzzy/typo tolerance
3. **pgvector** - Semantic/AI search

They're **completely independent** and can be used together or separately.

---

## 🔧 How They Work Together

### **1. Setup (One-Time)**

```sql
-- Enable all three extensions
CREATE EXTENSION IF NOT EXISTS pg_trgm;    -- Fuzzy matching
CREATE EXTENSION IF NOT EXISTS vector;     -- Semantic search

-- Native FTS is built into PostgreSQL, no extension needed
```

### **2. Add Columns to Your Tables**

```sql
-- Example: request table
ALTER TABLE request
  -- FTS column (already added in Phase 1)
  ADD COLUMN IF NOT EXISTS search_vector tsvector
    GENERATED ALWAYS AS (
      to_tsvector('english',
        coalesce(req_subj, '') || ' ' ||
        coalesce(req_desc, '')
      )
    ) STORED,

  -- Semantic search column (new)
  ADD COLUMN IF NOT EXISTS search_embedding vector(1536);  -- OpenAI ada-002 size

-- pg_trgm doesn't need special columns, works on existing text columns
```

### **3. Create Indexes**

```sql
-- FTS index (already created)
CREATE INDEX IF NOT EXISTS idx_request_fts
  ON request USING GIN(search_vector);

-- Trigram indexes (already created)
CREATE INDEX IF NOT EXISTS idx_request_subj_trgm
  ON request USING GIN(req_subj gin_trgm_ops);

-- Vector index (new)
CREATE INDEX IF NOT EXISTS idx_request_embedding
  ON request USING ivfflat(search_embedding vector_cosine_ops)
  WITH (lists = 100);  -- Adjust based on data size
```

---

## 🎯 Search Strategies: Use All Three

### **Strategy 1: Keyword Search (FTS)**

Best for: Exact terms, specific phrases

```sql
-- Find requests with "emergency" and "medical"
SELECT req_id, req_subj, req_desc,
       ts_rank(search_vector, query) as relevance
FROM request,
     to_tsquery('english', 'emergency & medical') query
WHERE search_vector @@ query
ORDER BY relevance DESC
LIMIT 20;
```

**Use when:**

- User searches specific keywords
- Need fast performance (<10ms)
- Searching 1M+ records

---

### **Strategy 2: Fuzzy Search (pg_trgm)**

Best for: Typos, partial matches, autocomplete

```sql
-- Find similar subjects (typo-tolerant)
-- "emergancy" finds "emergency"
SELECT req_id, req_subj,
       similarity(req_subj, 'emergancy') as fuzzy_score
FROM request
WHERE req_subj % 'emergancy'  -- % operator = similar to
ORDER BY fuzzy_score DESC
LIMIT 20;

-- Autocomplete
SELECT DISTINCT req_subj
FROM request
WHERE req_subj ILIKE 'emer%'
ORDER BY similarity(req_subj, 'emergency') DESC
LIMIT 10;
```

**Use when:**

- Autocomplete/typeahead
- User likely made typo
- Searching names, titles

---

### **Strategy 3: Semantic Search (pgvector)**

Best for: Conceptual similarity, multi-language, synonyms

```sql
-- Find semantically similar requests
-- "heart attack" finds "cardiac arrest", "chest pain", etc.
SELECT req_id, req_subj, req_desc,
       1 - (search_embedding <=> $1::vector) as semantic_score
FROM request
WHERE search_embedding IS NOT NULL
ORDER BY search_embedding <=> $1::vector  -- $1 = query embedding
LIMIT 20;
```

**Use when:**

- Need "smart" understanding
- Cross-language search
- Finding duplicates
- Matching by concept, not exact words

---

### **Strategy 4: Hybrid Search (ALL THREE COMBINED)**

Best for: Best overall results

```sql
-- Combine all three scores
WITH scores AS (
  SELECT
    req_id,
    req_subj,
    req_desc,

    -- Keyword score (0-1 normalized)
    COALESCE(
      ts_rank(search_vector, to_tsquery('english', 'emergency & medical')) /
      (SELECT MAX(ts_rank(search_vector, to_tsquery('english', 'emergency & medical'))) FROM request WHERE search_vector @@ to_tsquery('english', 'emergency & medical')),
      0
    ) as keyword_score,

    -- Fuzzy score (0-1)
    COALESCE(similarity(req_subj, 'emergency medical'), 0) as fuzzy_score,

    -- Semantic score (0-1)
    COALESCE(1 - (search_embedding <=> $1::vector), 0) as semantic_score

  FROM request
  WHERE
    search_vector @@ to_tsquery('english', 'emergency & medical')
    OR req_subj % 'emergency medical'
    OR (search_embedding IS NOT NULL AND search_embedding <=> $1::vector < 0.5)
)
SELECT
  req_id,
  req_subj,
  req_desc,
  -- Weighted combined score
  (keyword_score * 0.5 + fuzzy_score * 0.2 + semantic_score * 0.3) as final_score
FROM scores
ORDER BY final_score DESC
LIMIT 20;
```

**Weighting suggestions:**

- **Keyword-heavy:** 60% keyword, 20% fuzzy, 20% semantic
- **Balanced:** 40% keyword, 20% fuzzy, 40% semantic
- **Semantic-heavy:** 20% keyword, 10% fuzzy, 70% semantic

---

## 📊 When to Use Each

| Search Type        | Use FTS | Use pg_trgm | Use pgvector | Example Query                        |
| ------------------ | ------- | ----------- | ------------ | ------------------------------------ |
| **Exact keywords** | ✅      | ❌          | ❌           | "emergency medical help"             |
| **Typos**          | ❌      | ✅          | ⚠️           | "emergancy help" → "emergency help"  |
| **Autocomplete**   | ❌      | ✅          | ❌           | "emer..." → "emergency"              |
| **Partial match**  | ❌      | ✅          | ❌           | "hann" → "johannesburg"              |
| **Synonyms**       | ❌      | ❌          | ✅           | "doctor" → "physician"               |
| **Cross-language** | ⚠️      | ❌          | ✅           | Search "help" → find "मदद" (Hindi)   |
| **Conceptual**     | ❌      | ❌          | ✅           | "lonely" → "depression", "isolation" |
| **Phrase search**  | ✅      | ❌          | ❌           | "need urgent help"                   |
| **Multi-field**    | ✅      | ⚠️          | ✅           | Search across title + description    |

---

## 💰 Cost of Adding pgvector

### **Embedding Generation**

**Option 1: OpenAI API**

- Model: text-embedding-ada-002
- Cost: $0.0001 per 1K tokens (~750 words)
- Quality: Excellent
- Languages: 100+

**Example cost calculation:**

```
1,000 requests × 100 words each = 133,333 tokens
Cost = $0.0001 × 133.333 = $0.013 (one-time)

Daily updates: 100 requests/day × 100 words = 4,000 tokens/day
Cost = $0.0001 × 4 = $0.0004/day = $0.12/month
```

**Option 2: Self-hosted (sentence-transformers)**

- Model: all-MiniLM-L6-v2 or multilingual-e5
- Cost: EC2 instance ($50-100/month) OR Lambda ($5-10/month)
- Quality: Good
- Languages: 50+

**Recommended:** Start with OpenAI (~$5-20/month), migrate to self-hosted if costs grow

---

## 🚀 Implementation Timeline

### **Phase 1: FTS + pg_trgm (Already doing this)**

- Week 1-2: Core search
- Cost: $0
- Covers: 90% of needs

### **Phase 2: Add pgvector (Later, when needed)**

- Week 3: Enable extension
- Week 4: Generate embeddings for existing data
- Week 5: Update API to use hybrid search
- Cost: $5-50/month
- Covers: 99% of needs

### **Phase 3: External search (Much later, if needed)**

- Timeline: 2-4 years
- Cost: $200-500/month
- Covers: Advanced features

---

## 🔧 Hybrid Search Function (Complete Example)

```sql
-- Create a stored function for hybrid search
CREATE OR REPLACE FUNCTION search_requests_hybrid(
  query_text TEXT,
  query_embedding vector(1536) DEFAULT NULL,
  limit_results INT DEFAULT 20,
  keyword_weight FLOAT DEFAULT 0.5,
  fuzzy_weight FLOAT DEFAULT 0.2,
  semantic_weight FLOAT DEFAULT 0.3
)
RETURNS TABLE (
  req_id VARCHAR,
  req_subj VARCHAR,
  req_desc VARCHAR,
  keyword_score FLOAT,
  fuzzy_score FLOAT,
  semantic_score FLOAT,
  final_score FLOAT
) AS $$
BEGIN
  RETURN QUERY
  WITH scores AS (
    SELECT
      r.req_id,
      r.req_subj,
      r.req_desc,

      -- Normalize keyword score
      CASE
        WHEN r.search_vector @@ to_tsquery('english', query_text)
        THEN ts_rank(r.search_vector, to_tsquery('english', query_text))
        ELSE 0
      END as kw_score,

      -- Fuzzy similarity
      similarity(r.req_subj || ' ' || r.req_desc, query_text) as fz_score,

      -- Semantic similarity (if embedding provided)
      CASE
        WHEN query_embedding IS NOT NULL AND r.search_embedding IS NOT NULL
        THEN 1 - (r.search_embedding <=> query_embedding)
        ELSE 0
      END as sem_score

    FROM request r
    WHERE
      r.search_vector @@ to_tsquery('english', query_text)
      OR (r.req_subj || ' ' || r.req_desc) % query_text
      OR (query_embedding IS NOT NULL
          AND r.search_embedding IS NOT NULL
          AND r.search_embedding <=> query_embedding < 0.7)
  )
  SELECT
    s.req_id,
    s.req_subj,
    s.req_desc,
    s.kw_score as keyword_score,
    s.fz_score as fuzzy_score,
    s.sem_score as semantic_score,
    (s.kw_score * keyword_weight +
     s.fz_score * fuzzy_weight +
     s.sem_score * semantic_weight) as final_score
  FROM scores s
  ORDER BY final_score DESC
  LIMIT limit_results;
END;
$$ LANGUAGE plpgsql;

-- Usage examples:

-- 1. Keyword + Fuzzy only (no embeddings)
SELECT * FROM search_requests_hybrid('emergency medical help');

-- 2. Full hybrid search (with embeddings)
SELECT * FROM search_requests_hybrid(
  'heart attack',
  '[0.123, -0.456, ...]'::vector(1536),  -- Query embedding from OpenAI
  20,
  0.4,  -- 40% keyword weight
  0.2,  -- 20% fuzzy weight
  0.4   -- 40% semantic weight
);

-- 3. Heavily semantic
SELECT * FROM search_requests_hybrid(
  'feeling alone',
  get_embedding('feeling alone'),
  10,
  0.1,  -- 10% keyword
  0.1,  -- 10% fuzzy
  0.8   -- 80% semantic (finds "depression", "isolation", etc.)
);
```

---

## ✅ Summary

### **All Three Extensions Are Compatible**

- ✅ No conflicts
- ✅ Can use together or separately
- ✅ Each has different strengths
- ✅ Combine for best results

### **Recommended Approach**

1. **Start:** FTS + pg_trgm (Phases 1-5)
2. **Add later:** pgvector when you need semantic search (Phase 6)
3. **Combine:** Use hybrid search for best overall results

### **Cost**

- FTS + pg_trgm: $0/month
- - pgvector: $5-50/month
- Total: Still far cheaper than external search services ($200-500/month)

### **Performance**

- FTS: <10ms for millions of records
- pg_trgm: <50ms for fuzzy searches
- pgvector: <100ms for semantic searches
- All three combined: <150ms

### **When to Add pgvector**

- ✅ Need cross-language search
- ✅ Want synonym matching
- ✅ Finding duplicate requests
- ✅ Smart volunteer matching
- ✅ After Phases 1-5 are complete

**Don't add until you need it** - FTS + pg_trgm covers 90-95% of use cases.
