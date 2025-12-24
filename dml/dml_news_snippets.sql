-- The first insert command
INSERT INTO virginia_dev_saayam_rdbms.news_snippets (headline,snippet_text,image_path,profile_links,event_date
) VALUES (
'Volunteer Drive Success',
'Our latest volunteer drive was a huge success! Over 50 new volunteers joined us to support our mission. Special thanks to CHP for leading the effort',
's3:---01.jpg',
'[{"name": "PersonA", "url": "https://linkedin.com/in/PersonA"}, {"name": "PersonB", "url": "https://linkedin.com/in/PersonB"}]'::jsonb, --checks if the given is valid jsob, else the transaction will fail
'2025-12-15' -- The date the event actually happened
);

-- later, if you want to add to the same list without removing the existing ones, then use the UPDATE command
-- COALESCE tells 'Look at the profile_links column. If it has data, use it. If it is empty (NULL), treat it as an empty array [] instead.'
UPDATE virginia_dev_saayam_rdbms.news_snippets
SET profile_links = COALESCE(profile_links, '[]'::jsonb) || '{"name": "First Person", "url": "..."}'::jsonb
WHERE news_id = 1;
