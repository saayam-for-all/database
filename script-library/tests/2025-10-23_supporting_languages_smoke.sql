-- 1) Expect 12 active rows
SELECT CASE WHEN COUNT(*) = 12 THEN 'OK: 12 languages present'
            ELSE 'FAIL: expected 12, found ' || COUNT(*) END AS check_languages_count
FROM virginia_dev_saayam_rdbms.supporting_languages
WHERE is_active = TRUE;

-- 2) Uniqueness of iso_639_1 + locale_code
SELECT 'OK: uniqueness enforced' AS check_uniqueness
WHERE NOT EXISTS (
  SELECT 1 FROM (
    SELECT iso_639_1, locale_code, COUNT(*) c
    FROM virginia_dev_saayam_rdbms.supporting_languages
    GROUP BY 1,2
    HAVING COUNT(*) > 1
  ) d
);

-- 3) RTL rows should be 2 (Arabic, Urdu)
SELECT CASE WHEN COUNT(*) = 2 THEN 'OK: RTL count is 2'
            ELSE 'WARN: RTL count differs: ' || COUNT(*) END AS check_rtl_count
FROM virginia_dev_saayam_rdbms.supporting_languages
WHERE writing_direction = 'RTL';
