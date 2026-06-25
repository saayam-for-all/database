BEGIN;

SELECT plan(8);

INSERT INTO virginia_dev_saayam_rdbms.users (is_eu) VALUES (FALSE);
INSERT INTO virginia_dev_saayam_rdbms.users (is_eu) VALUES (TRUE);

SELECT isnt(
    (SELECT user_id FROM virginia_dev_saayam_rdbms.users
     WHERE is_eu = FALSE LIMIT 1),
    NULL,
    'Virginia non-EU: user_id is not null'
);

SELECT matches(
    (SELECT user_id FROM virginia_dev_saayam_rdbms.users
     WHERE is_eu = FALSE LIMIT 1),
    '^SID-001-',
    'Virginia non-EU: user_id starts with SID-001'
);

SELECT matches(
    (SELECT user_id FROM virginia_dev_saayam_rdbms.users
     WHERE is_eu = FALSE LIMIT 1),
    '^SID-001-\d{3}-\d{3}-\d{3}-\d{3}$',
    'Virginia non-EU: user_id matches full SID-001-XXX-XXX-XXX-XXX format'
);

SELECT ok(
    LENGTH((SELECT user_id FROM virginia_dev_saayam_rdbms.users
            WHERE is_eu = FALSE LIMIT 1)) <= 25,
    'Virginia non-EU: user_id length within VARCHAR(25)'
);

SELECT isnt(
    (SELECT user_id FROM virginia_dev_saayam_rdbms.users
     WHERE is_eu = TRUE LIMIT 1),
    NULL,
    'Virginia EU DR: user_id is not null'
);

SELECT matches(
    (SELECT user_id FROM virginia_dev_saayam_rdbms.users
     WHERE is_eu = TRUE LIMIT 1),
    '^SID-002-',
    'Virginia EU DR: user_id starts with SID-002'
);

SELECT matches(
    (SELECT user_id FROM virginia_dev_saayam_rdbms.users
     WHERE is_eu = TRUE LIMIT 1),
    '^SID-002-\d{3}-\d{3}-\d{3}-\d{3}$',
    'Virginia EU DR: user_id matches full SID-002-XXX-XXX-XXX-XXX format'
);

INSERT INTO virginia_dev_saayam_rdbms.users (is_eu) VALUES (FALSE);

SELECT is(
    (SELECT COUNT(DISTINCT user_id)
     FROM virginia_dev_saayam_rdbms.users
     WHERE is_eu = FALSE),
    2::BIGINT,
    'Virginia: two non-EU inserts produce unique user_ids'
);

SELECT * FROM finish();
ROLLBACK;