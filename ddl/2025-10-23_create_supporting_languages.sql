
CREATE TABLE IF NOT EXISTS public.supporting_languages (
    id                BIGSERIAL PRIMARY KEY,
    language_name     VARCHAR(64)  NOT NULL,
    iso_639_1         CHAR(2)      NOT NULL,                 -- e.g., en, zh, hi
    locale_code       VARCHAR(10)  NOT NULL,                 -- e.g., en_US, zh_CN
    writing_direction VARCHAR(3)   NOT NULL DEFAULT 'LTR',   -- 'LTR' or 'RTL'
    total_speakers_m  NUMERIC(10,1),                         -- millions (optional)
    is_active         BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at        TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at        TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_lang_unique UNIQUE (iso_639_1, locale_code),
    CONSTRAINT ck_direction CHECK (writing_direction IN ('LTR','RTL')),
    CONSTRAINT ck_iso6391 CHECK (iso_639_1 ~ '^[a-z]{2}$'),
    CONSTRAINT ck_locale CHECK (locale_code ~ '^[a-z]{2}_[A-Z]{2}$')
);

CREATE INDEX IF NOT EXISTS ix_supporting_languages_name
    ON public.supporting_languages (language_name);

-- Keep updated_at fresh
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_supporting_languages_updated_at ON public.supporting_languages;

CREATE TRIGGER trg_supporting_languages_updated_at
BEFORE UPDATE ON public.supporting_languages
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();
