UPDATE virginia_dev_saayam_rdbms.country
SET is_eu_member = TRUE
WHERE country_name IN (
  'Austria','Belgium','Bulgaria','Croatia','Cyprus','Czechia','Denmark',
  'Estonia','Finland','France','Germany','Greece','Hungary','Ireland',
  'Italy','Latvia','Lithuania','Luxembourg','Malta','Netherlands',
  'Poland','Portugal','Romania','Slovakia','Slovenia','Spain','Sweden'
);
