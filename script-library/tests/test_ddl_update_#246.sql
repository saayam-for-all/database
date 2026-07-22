BEGIN;

SELECT plan(30);

-- =============================================
-- 0. action
-- =============================================
SELECT has_column(
    'virginia_dev_saayam_rdbms', 'action', 'created_at',
    'action: created_at column exists'
);

SELECT has_column(
    'virginia_dev_saayam_rdbms', 'action', 'last_updated_at',
    'action: last_updated_at column exists'
);

SELECT hasnt_column(
    'virginia_dev_saayam_rdbms', 'action', 'created_date',
    'action: created_date column removed'
);

SELECT hasnt_column(
    'virginia_dev_saayam_rdbms', 'action', 'last_update_date',
    'action: last_update_date column removed'
);

SELECT trigger_is(
    'virginia_dev_saayam_rdbms', 'action', 'trg_action_updated_at',
    'virginia_dev_saayam_rdbms', 'set_updated_at',
    'action: trg_action_updated_at trigger exists'
);

-- =============================================
-- 1. country
-- =============================================
SELECT has_column(
    'virginia_dev_saayam_rdbms', 'country', 'last_updated_at',
    'country: last_updated_at column exists'
);

SELECT hasnt_column(
    'virginia_dev_saayam_rdbms', 'country', 'last_update_date',
    'country: last_update_date column removed'
);

SELECT trigger_is(
    'virginia_dev_saayam_rdbms', 'country', 'trg_country_updated_at',
    'virginia_dev_saayam_rdbms', 'set_updated_at',
    'country: trg_country_updated_at trigger exists'
);

-- =============================================
-- 2. identity_type
-- =============================================
SELECT has_column(
    'virginia_dev_saayam_rdbms', 'identity_type', 'identity_type_desc',
    'identity_type: identity_type_desc column exists'
);

SELECT hasnt_column(
    'virginia_dev_saayam_rdbms', 'identity_type', 'identity_type_dsc',
    'identity_type: identity_type_dsc column removed'
);

SELECT has_column(
    'virginia_dev_saayam_rdbms', 'identity_type', 'last_updated_at',
    'identity_type: last_updated_at column exists'
);

-- =============================================
-- 3. supporting_languages
-- =============================================
SELECT has_column(
    'virginia_dev_saayam_rdbms', 'supporting_languages', 'iso_code',
    'supporting_languages: iso_code column exists'
);

SELECT hasnt_column(
    'virginia_dev_saayam_rdbms', 'supporting_languages', 'iso_639_1_code',
    'supporting_languages: iso_639_1_code column removed'
);

SELECT trigger_is(
    'virginia_dev_saayam_rdbms', 'supporting_languages', 'trg_supporting_lang_updated_at',
    'virginia_dev_saayam_rdbms', 'set_updated_at',
    'supporting_languages: trigger uses schema qualified function'
);

-- =============================================
-- 4. city
-- =============================================
SELECT has_column(
    'virginia_dev_saayam_rdbms', 'city', 'last_updated_at',
    'city: last_updated_at column exists'
);

SELECT col_type_is(
    'virginia_dev_saayam_rdbms', 'city', 'state_id', 'character varying(50)',
    'city: state_id is VARCHAR(50)'
);

-- =============================================
-- 5. users
-- =============================================
SELECT has_column(
    'virginia_dev_saayam_rdbms', 'users', 'last_updated_at',
    'users: last_updated_at column exists'
);

SELECT hasnt_column(
    'virginia_dev_saayam_rdbms', 'users', 'last_update_date',
    'users: last_update_date column removed'
);

SELECT has_column(
    'virginia_dev_saayam_rdbms', 'users', 'promotion_wizard_last_updated_at',
    'users: promotion_wizard_last_updated_at column exists'
);

SELECT hasnt_column(
    'virginia_dev_saayam_rdbms', 'users', 'promotion_wizard_last_update_date',
    'users: promotion_wizard_last_update_date column removed'
);

SELECT hasnt_column(
    'virginia_dev_saayam_rdbms', 'users', 'user_category_id',
    'users: user_category_id column removed'
);

SELECT col_type_is(
    'virginia_dev_saayam_rdbms', 'users', 'language_1', 'bigint',
    'users: language_1 is BIGINT'
);

SELECT col_type_is(
    'virginia_dev_saayam_rdbms', 'users', 'language_2', 'bigint',
    'users: language_2 is BIGINT'
);

SELECT col_type_is(
    'virginia_dev_saayam_rdbms', 'users', 'language_3', 'bigint',
    'users: language_3 is BIGINT'
);

SELECT has_column(
    'virginia_dev_saayam_rdbms', 'users', 'external_auth_provider',
    'users: external_auth_provider column exists'
);

SELECT has_column(
    'virginia_dev_saayam_rdbms', 'users', 'dob',
    'users: dob column exists'
);

SELECT has_column(
    'virginia_dev_saayam_rdbms', 'users', 'is_eu',
    'users: is_eu column exists'
);

SELECT trigger_is(
    'virginia_dev_saayam_rdbms', 'users', 'trg_users_updated_at',
    'virginia_dev_saayam_rdbms', 'set_updated_at',
    'users: trg_users_updated_at trigger exists'
);

SELECT trigger_is(
    'virginia_dev_saayam_rdbms', 'users', 'trg_users_promo_wizard_updated_at',
    'virginia_dev_saayam_rdbms', 'set_promo_wizard_updated_at',
    'users: trg_users_promo_wizard_updated_at trigger exists'
);

SELECT col_default_is(
    'virginia_dev_saayam_rdbms', 'users', 'is_eu', 'false',
    'users: is_eu defaults to false'
);

SELECT * FROM finish();
ROLLBACK;