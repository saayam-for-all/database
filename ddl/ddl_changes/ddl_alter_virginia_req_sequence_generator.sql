-- Replace request ID generator (Virginia).
-- New format: REQ-XXX-XXX-XXX-XXXX (LPAD + SUBSTRING, 13 digits grouped 3-3-3-4)

DROP TRIGGER IF EXISTS before_insert_requests ON virginia_dev_saayam_rdbms.request;
DROP FUNCTION IF EXISTS virginia_dev_saayam_rdbms.generate_request_id();

CREATE OR REPLACE FUNCTION virginia_dev_saayam_rdbms.generate_req_id()
RETURNS TRIGGER AS $$
DECLARE
    seq_id BIGINT;
    padded TEXT;
BEGIN
    seq_id := nextval('virginia_dev_saayam_rdbms.request_id_seq');
    padded := LPAD(seq_id::TEXT, 13, '0');
    NEW.req_id := 'REQ-' ||
        SUBSTRING(padded FROM 1 FOR 3) || '-' ||
        SUBSTRING(padded FROM 4 FOR 3) || '-' ||
        SUBSTRING(padded FROM 7 FOR 3) || '-' ||
        SUBSTRING(padded FROM 10 FOR 4);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_insert_requests
BEFORE INSERT ON virginia_dev_saayam_rdbms.request
FOR EACH ROW
EXECUTE FUNCTION virginia_dev_saayam_rdbms.generate_req_id();
