BEGIN;

SELECT plan(5);

INSERT INTO stockholm_dev_saayam_rdbms.users (is_eu) VALUES (TRUE);

SELECT isnt(
    (SELECT user_id FROM stockholm_dev_saayam_rdbms.users LIMIT 1),
    NULL,
    'Stockholm EU DR: user_id is not null'
);

SELECT matches(
    (SELECT user_id FROM stockholm_dev_saayam_rdbms.users LIMIT 1),
    '^SID-002-',
    'Stockholm EU DR: user_id starts with SID-002'
);

SELECT matches(
    (SELECT user_id FROM stockholm_dev_saayam_rdbms.users LIMIT 1),
    '^SID-002-\d{3}-\d{3}-\d{3}-\d{3}$',
    'Stockholm EU DR: user_id matches full SID-002-XXX-XXX-XXX-XXX format'
);

SELECT ok(
    LENGTH((SELECT user_id FROM stockholm_dev_saayam_rdbms.users LIMIT 1)) <= 25,
    'Stockholm EU DR: user_id length within VARCHAR(25)'
);

INSERT INTO stockholm_dev_saayam_rdbms.users (is_eu) VALUES (TRUE);

SELECT is(
    (SELECT COUNT(DISTINCT user_id)
     FROM stockholm_dev_saayam_rdbms.users),
    2::BIGINT,
    'Stockholm EU DR: two inserts produce unique user_ids'
);

SELECT * FROM finish();
ROLLBACK;