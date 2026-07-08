BEGIN;

SELECT plan(6);

INSERT INTO virginia_dev_saayam_rdbms.users (is_eu) VALUES (FALSE);

SELECT isnt(
    (SELECT user_id FROM virginia_dev_saayam_rdbms.users LIMIT 1),
    NULL,
    'Virginia: user_id is not null'
);

SELECT matches(
    (SELECT user_id FROM virginia_dev_saayam_rdbms.users LIMIT 1),
    '^SID-00-',
    'Virginia: user_id starts with SID-00'
);

SELECT matches(
    (SELECT user_id FROM virginia_dev_saayam_rdbms.users LIMIT 1),
    '^SID-00-\d{3}-\d{3}-\d{3}-\d{3}-\d{3}$',
    'Virginia: user_id matches full SID-00-XXX-XXX-XXX-XXX-XXX format'
);

SELECT ok(
    LENGTH((SELECT user_id FROM virginia_dev_saayam_rdbms.users LIMIT 1)) <= 255,
    'Virginia: user_id length within VARCHAR(255)'
);

INSERT INTO virginia_dev_saayam_rdbms.users (is_eu) VALUES (FALSE);

SELECT is(
    (SELECT COUNT(DISTINCT user_id) FROM virginia_dev_saayam_rdbms.users),
    2::BIGINT,
    'Virginia: two inserts produce unique user_ids'
);

SELECT matches(
    (SELECT user_id FROM virginia_dev_saayam_rdbms.users LIMIT 1),
    '^SID-00-000-',
    'Virginia: first segment is 000'
);

SELECT * FROM finish();
ROLLBACK;