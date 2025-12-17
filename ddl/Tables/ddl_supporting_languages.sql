
CREATE TABLE IF NOT EXISTS virginia_dev_saayam_rdbms.supporting_languages (
    language_id       BIGSERIAL PRIMARY KEY,
    language_name     VARCHAR(64)  NOT NULL,
    iso_639_1_code CHAR(2) NOT NULL,                 -- e.g., en, zh, hi
    locale_code       VARCHAR(10)  NOT NULL,                 -- e.g., en_US, zh_CN
    writing_direction VARCHAR(3)   NOT NULL DEFAULT 'LTR',   -- 'LTR' or 'RTL'
    total_speakers_m  NUMERIC(10,1),                         -- millions (optional)
    is_active         BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    last_updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_lang_unique UNIQUE (iso_639_1_code, locale_code),
    CONSTRAINT ck_direction CHECK (writing_direction IN ('LTR','RTL')),
    CONSTRAINT ck_iso6391 CHECK (iso_639_1_code ~ '^[A-Za-z]{2}$'),
    CONSTRAINT ck_locale CHECK (locale_code ~ '^[a-z]{2}_[A-Z]{2}$')
);

CREATE INDEX IF NOT EXISTS ix_supporting_languages_name
    ON virginia_dev_saayam_rdbms.supporting_languages (language_name);

-- Keep updated_at fresh
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.last_updated_at := NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_supporting_languages_updated_at ON virginia_dev_saayam_rdbms.supporting_languages;

CREATE TRIGGER trg_supporting_lang_updated_at
BEFORE UPDATE ON virginia_dev_saayam_rdbms.supporting_languages
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();
