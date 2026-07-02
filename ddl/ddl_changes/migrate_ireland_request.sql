-- Migrate request ID generator (Ireland) — function only.
-- Old format: REQ-00-XXX-XXX-XXX (3 segments)
-- request_id_seq unchanged (no RESTART; current counter preserved).

CREATE OR REPLACE FUNCTION ireland_dev_saayam_rdbms.generate_request_id()
RETURNS TRIGGER AS $$
DECLARE
    seq_id BIGINT;
    new_id TEXT;
BEGIN
    seq_id := nextval('ireland_dev_saayam_rdbms.request_id_seq');
    new_id := 'REQ-' || LPAD(FLOOR(seq_id / 1000000000000)::TEXT, 2, '0') || '-'
        || LPAD(FLOOR((seq_id % 1000000000000) / 1000000000)::TEXT, 3, '0') || '-'
        || LPAD(FLOOR((seq_id % 1000000000) / 1000000)::TEXT, 3, '0') || '-'
        || LPAD(FLOOR((seq_id % 1000000) / 1000)::TEXT, 3, '0') || '-'
        || LPAD((seq_id % 1000)::TEXT, 3, '0');
    NEW.req_id := new_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
