DO $organization_types$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_type t
        JOIN pg_namespace n ON n.oid = t.typnamespace
        WHERE n.nspname = 'virginia_dev_saayam_rdbms'
          AND t.typname = 'org_type_enum'
    ) THEN
        CREATE TYPE virginia_dev_saayam_rdbms.org_type_enum
            AS ENUM ('non_profit', 'for_profit');
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_type t
        JOIN pg_namespace n ON n.oid = t.typnamespace
        WHERE n.nspname = 'virginia_dev_saayam_rdbms'
          AND t.typname = 'org_size_enum'
    ) THEN
        CREATE TYPE virginia_dev_saayam_rdbms.org_size_enum
            AS ENUM ('small', 'medium', 'large');
    END IF;
END
$organization_types$;

ALTER TABLE virginia_dev_saayam_rdbms.organizations
    ADD COLUMN IF NOT EXISTS is_contributor BOOLEAN;

ALTER TABLE virginia_dev_saayam_rdbms.organizations
    ALTER COLUMN org_type TYPE virginia_dev_saayam_rdbms.org_type_enum
        USING org_type::text::virginia_dev_saayam_rdbms.org_type_enum,
    ALTER COLUMN org_size TYPE virginia_dev_saayam_rdbms.org_size_enum
        USING org_size::text::virginia_dev_saayam_rdbms.org_size_enum,
    ALTER COLUMN created_at TYPE TIMESTAMP WITHOUT TIME ZONE
        USING created_at::TIMESTAMP WITHOUT TIME ZONE,
    ALTER COLUMN created_at SET DEFAULT (now() AT TIME ZONE 'UTC'),
    ALTER COLUMN last_updated_at TYPE TIMESTAMP WITHOUT TIME ZONE
        USING last_updated_at::TIMESTAMP WITHOUT TIME ZONE,
    ALTER COLUMN last_updated_at SET DEFAULT (now() AT TIME ZONE 'UTC');

DO $organizations_state_fk$
DECLARE
    v_constraint text;
BEGIN
    FOR v_constraint IN
        SELECT c.conname
        FROM pg_constraint c
        WHERE c.conrelid = 'virginia_dev_saayam_rdbms.organizations'::regclass
          AND c.contype = 'f'
          AND EXISTS (
              SELECT 1
              FROM unnest(c.conkey) AS key(attnum)
              JOIN pg_attribute a
                ON a.attrelid = c.conrelid
               AND a.attnum = key.attnum
              WHERE a.attname = 'state_id'
          )
    LOOP
        EXECUTE format(
            'ALTER TABLE virginia_dev_saayam_rdbms.organizations DROP CONSTRAINT %I',
            v_constraint
        );
    END LOOP;

    ALTER TABLE virginia_dev_saayam_rdbms.organizations
        ADD CONSTRAINT organizations_state_id_fkey
        FOREIGN KEY (state_id)
        REFERENCES virginia_dev_saayam_rdbms.state(state_id)
        ON DELETE SET NULL;
END
$organizations_state_fk$;

CREATE INDEX IF NOT EXISTS idx_org_name
    ON virginia_dev_saayam_rdbms.organizations(org_name);
CREATE INDEX IF NOT EXISTS idx_org_state_id
    ON virginia_dev_saayam_rdbms.organizations(state_id);
CREATE INDEX IF NOT EXISTS idx_org_city_state
    ON virginia_dev_saayam_rdbms.organizations(city_name, state_id);

DROP TRIGGER IF EXISTS trg_organizations_updated_at
    ON virginia_dev_saayam_rdbms.organizations;
CREATE TRIGGER trg_organizations_updated_at
BEFORE UPDATE ON virginia_dev_saayam_rdbms.organizations
FOR EACH ROW
EXECUTE FUNCTION virginia_dev_saayam_rdbms.set_updated_at();

CREATE SEQUENCE IF NOT EXISTS virginia_dev_saayam_rdbms.org_id_seq
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 999999999999
    NO CYCLE;

ALTER SEQUENCE virginia_dev_saayam_rdbms.org_id_seq
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 999999999999
    NO CYCLE;

DO $organization_sequence_sync$
DECLARE
    v_max_id bigint;
    v_last_value bigint;
BEGIN
    SELECT max(NULLIF(regexp_replace(org_id, '[^0-9]', '', 'g'), '')::bigint)
      INTO v_max_id
      FROM virginia_dev_saayam_rdbms.organizations;

    IF v_max_id IS NOT NULL THEN
        SELECT last_value
          INTO v_last_value
          FROM virginia_dev_saayam_rdbms.org_id_seq;

        PERFORM setval(
            'virginia_dev_saayam_rdbms.org_id_seq'::regclass,
            GREATEST(v_max_id, v_last_value),
            true
        );
    END IF;
END
$organization_sequence_sync$;

CREATE OR REPLACE FUNCTION virginia_dev_saayam_rdbms.generate_org_id()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $generate_org_id$
DECLARE
    seq_id BIGINT;
    padded TEXT;
BEGIN
    seq_id := nextval('virginia_dev_saayam_rdbms.org_id_seq'::regclass);
    padded := LPAD(seq_id::TEXT, 13, '0');

    NEW.org_id := 'ORG-' ||
        SUBSTRING(padded FROM 1 FOR 3) || '-' ||
        SUBSTRING(padded FROM 4 FOR 3) || '-' ||
        SUBSTRING(padded FROM 7 FOR 3) || '-' ||
        SUBSTRING(padded FROM 10 FOR 4);

    RETURN NEW;
END
$generate_org_id$;

DROP TRIGGER IF EXISTS before_insert_organizations
    ON virginia_dev_saayam_rdbms.organizations;
CREATE TRIGGER before_insert_organizations
BEFORE INSERT ON virginia_dev_saayam_rdbms.organizations
FOR EACH ROW
EXECUTE FUNCTION virginia_dev_saayam_rdbms.generate_org_id();
