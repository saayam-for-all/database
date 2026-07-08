BEGIN;

SELECT plan(10);

INSERT INTO ireland_dev_saayam_rdbms.users (is_eu) VALUES (TRUE);
INSERT INTO ireland_dev_saayam_rdbms.users (is_eu) VALUES (FALSE);

SELECT isnt(
    (SELECT user_id FROM ireland_dev_saayam_rdbms.users
     WHERE is_eu = TRUE LIMIT 1),
    NULL,
    'Ireland EU: user_id is not null'
);

SELECT matches(
    (SELECT user_id FROM ireland_dev_saayam_rdbms.users
     WHERE is_eu = TRUE LIMIT 1),
    '^SID-EU-',
    'Ireland EU: user_id starts with SID-EU'
);

SELECT matches(
    (SELECT user_id FROM ireland_dev_saayam_rdbms.users
     WHERE is_eu = TRUE LIMIT 1),
    '^SID-EU-\d{3}-\d{3}-\d{3}-\d{3}-\d{3}$',
    'Ireland EU: user_id matches full SID-EU-XXX-XXX-XXX-XXX-XXX format'
);

SELECT ok(
    LENGTH((SELECT user_id FROM ireland_dev_saayam_rdbms.users
            WHERE is_eu = TRUE LIMIT 1)) <= 255,
    'Ireland EU: user_id length within VARCHAR(255)'
);

SELECT matches(
    (SELECT user_id FROM ireland_dev_saayam_rdbms.users
     WHERE is_eu = TRUE LIMIT 1),
    '^SID-EU-000-',
    'Ireland EU: first segment is 000'
);

SELECT isnt(
    (SELECT user_id FROM ireland_dev_saayam_rdbms.users
     WHERE is_eu = FALSE LIMIT 1),
    NULL,
    'Ireland Virginia DR: user_id is not null'
);

SELECT matches(
    (SELECT user_id FROM ireland_dev_saayam_rdbms.users
     WHERE is_eu = FALSE LIMIT 1),
    '^SID-00-',
    'Ireland Virginia DR: user_id starts with SID-00'
);

SELECT matches(
    (SELECT user_id FROM ireland_dev_saayam_rdbms.users
     WHERE is_eu = FALSE LIMIT 1),
    '^SID-00-\d{3}-\d{3}-\d{3}-\d{3}-\d{3}$',
    'Ireland Virginia DR: user_id matches full SID-00-XXX-XXX-XXX-XXX-XXX format'
);

SELECT matches(
    (SELECT user_id FROM ireland_dev_saayam_rdbms.users
     WHERE is_eu = FALSE LIMIT 1),
    '^SID-00-000-020-',
    'Ireland Virginia DR: first segment is 020'
);

SELECT isnt(
    (SELECT LEFT(user_id, 6) FROM ireland_dev_saayam_rdbms.users
     WHERE is_eu = TRUE LIMIT 1),
    (SELECT LEFT(user_id, 6) FROM ireland_dev_saayam_rdbms.users
     WHERE is_eu = FALSE LIMIT 1),
    'Ireland: EU and Virginia DR user_ids have different prefixes'
);

SELECT * FROM finish();
ROLLBACK;