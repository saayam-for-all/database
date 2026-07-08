BEGIN;

SELECT plan(10);

INSERT INTO stockholm_dev_saayam_rdbms.users (is_eu) VALUES (TRUE);
INSERT INTO stockholm_dev_saayam_rdbms.users (is_eu) VALUES (FALSE);

SELECT isnt(
    (SELECT user_id FROM stockholm_dev_saayam_rdbms.users
     WHERE is_eu = TRUE LIMIT 1),
    NULL,
    'Stockholm EU DR: user_id is not null'
);

SELECT matches(
    (SELECT user_id FROM stockholm_dev_saayam_rdbms.users
     WHERE is_eu = TRUE LIMIT 1),
    '^SID-EU-',
    'Stockholm EU DR: user_id starts with SID-EU'
);

SELECT matches(
    (SELECT user_id FROM stockholm_dev_saayam_rdbms.users
     WHERE is_eu = TRUE LIMIT 1),
    '^SID-EU-\d{3}-\d{3}-\d{3}-\d{3}-\d{3}$',
    'Stockholm EU DR: user_id matches full SID-EU-XXX-XXX-XXX-XXX-XXX format'
);

SELECT ok(
    LENGTH((SELECT user_id FROM stockholm_dev_saayam_rdbms.users
            WHERE is_eu = TRUE LIMIT 1)) <= 255,
    'Stockholm EU DR: user_id length within VARCHAR(255)'
);

SELECT matches(
    (SELECT user_id FROM stockholm_dev_saayam_rdbms.users
     WHERE is_eu = TRUE LIMIT 1),
    '^SID-EU-000-020-',
    'Stockholm EU DR: first segment is 020'
);

SELECT isnt(
    (SELECT user_id FROM stockholm_dev_saayam_rdbms.users
     WHERE is_eu = FALSE LIMIT 1),
    NULL,
    'Stockholm Virginia DR: user_id is not null'
);

SELECT matches(
    (SELECT user_id FROM stockholm_dev_saayam_rdbms.users
     WHERE is_eu = FALSE LIMIT 1),
    '^SID-00-',
    'Stockholm Virginia DR: user_id starts with SID-00'
);

SELECT matches(
    (SELECT user_id FROM stockholm_dev_saayam_rdbms.users
     WHERE is_eu = FALSE LIMIT 1),
    '^SID-00-\d{3}-\d{3}-\d{3}-\d{3}-\d{3}$',
    'Stockholm Virginia DR: user_id matches full SID-00-XXX-XXX-XXX-XXX-XXX format'
);

SELECT matches(
    (SELECT user_id FROM stockholm_dev_saayam_rdbms.users
     WHERE is_eu = FALSE LIMIT 1),
    '^SID-00-000-040-',
    'Stockholm Virginia DR: first segment is 040'
);

SELECT isnt(
    (SELECT LEFT(user_id, 6) FROM stockholm_dev_saayam_rdbms.users
     WHERE is_eu = TRUE LIMIT 1),
    (SELECT LEFT(user_id, 6) FROM stockholm_dev_saayam_rdbms.users
     WHERE is_eu = FALSE LIMIT 1),
    'Stockholm: EU DR and Virginia DR user_ids have different prefixes'
);

SELECT * FROM finish();
ROLLBACK;