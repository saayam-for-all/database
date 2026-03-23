--Converting the datatype of language_1, language_2, and language_3 from character varying to BIGINT.
ALTER TABLE users
ALTER COLUMN language_1 TYPE BIGINT USING language_1::BIGINT,
ALTER COLUMN language_2 TYPE BIGINT USING language_2::BIGINT,
ALTER COLUMN language_3 TYPE BIGINT USING language_3::BIGINT;

--Connecting the language 1, language 2, and language 3 attributes from the users table to the language_id attribute in the supporting languages table.
ALTER TABLE users
ADD CONSTRAINT fk_users_language_1
FOREIGN KEY (language_1)
REFERENCES supporting_languages(language_id),
ADD CONSTRAINT fk_users_language_2
FOREIGN KEY (language_2)
REFERENCES supporting_languages(language_id),
ADD CONSTRAINT fk_users_language_3
FOREIGN KEY (language_3)
REFERENCES supporting_languages(language_id);

--Changing the column name in the supporting_language table.
ALTER TABLE supporting_languages
RENAME COLUMN iso_639_1_code TO iso_code;