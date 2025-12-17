-- Issue #91: Seed 12 supported languages/locales

INSERT INTO virginia_dev_saayam_rdbms.supporting_languages
(language_name, iso_639_1, locale_code, writing_direction, total_speakers_m)
VALUES
('English',           'en', 'en_US', 'LTR', 1515.0),
('Mandarin Chinese',  'zh', 'zh_CN', 'LTR', 1140.0),
('Hindi',             'hi', 'hi_IN', 'LTR',  609.0),
('Spanish',           'es', 'es_ES', 'LTR',  560.0),
('French',            'fr', 'fr_FR', 'LTR',  312.0),
('Arabic',            'ar', 'ar_SA', 'RTL',  280.0),
('Bengali',           'bn', 'bn_BD', 'LTR',  278.0),
('Portuguese',        'pt', 'pt_PT', 'LTR',  264.0),
('Russian',           'ru', 'ru_RU', 'LTR',  255.0),
('Urdu',              'ur', 'ur_PK', 'RTL',  230.0),
('German',            'de', 'de_DE', 'LTR',  134.0),
('Telugu',            'te', 'te_IN', 'LTR',   96.0)
ON CONFLICT (iso_639_1, locale_code) DO NOTHING;
