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
    '^SID-002-',
    'Ireland EU: user_id starts with SID-002'
);

SELECT matches(
    (SELECT user_id FROM ireland_dev_saayam_rdbms.users
     WHERE is_eu = TRUE LIMIT 1),
    '^SID-002-\d{3}-\d{3}-\d{3}-\d{3}$',
    'Ireland EU: user_id matches full SID-002-XXX-XXX-XXX-XXX format'
);

SELECT ok(
    LENGTH((SELECT user_id FROM ireland_dev_saayam_rdbms.users
            WHERE is_eu = TRUE LIMIT 1)) <= 25,
    'Ireland EU: user_id length within VARCHAR(25)'
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
    '^SID-001-',
    'Ireland Virginia DR: user_id starts with SID-001'
);

SELECT matches(
    (SELECT user_id FROM ireland_dev_saayam_rdbms.users
     WHERE is_eu = FALSE LIMIT 1),
    '^SID-001-\d{3}-\d{3}-\d{3}-\d{3}$',
    'Ireland Virginia DR: user_id matches full SID-001-XXX-XXX-XXX-XXX format'
);

SELECT ok(
    LENGTH((SELECT user_id FROM ireland_dev_saayam_rdbms.users
            WHERE is_eu = FALSE LIMIT 1)) <= 25,
    'Ireland Virginia DR: user_id length within VARCHAR(25)'
);

SELECT is(
    (SELECT COUNT(DISTINCT user_id)
     FROM ireland_dev_saayam_rdbms.users),
    2::BIGINT,
    'Ireland: EU and DR inserts produce unique user_ids'
);

SELECT isnt(
    (SELECT LEFT(user_id, 7) FROM ireland_dev_saayam_rdbms.users
     WHERE is_eu = TRUE LIMIT 1),
    (SELECT LEFT(user_id, 7) FROM ireland_dev_saayam_rdbms.users
     WHERE is_eu = FALSE LIMIT 1),
    'Ireland: EU and Virginia DR user_ids have different prefixes'
);

SELECT * FROM finish();
ROLLBACK;