drop table if exists help_category_map

create table if not exists help_category_map (
    parent_id VARCHAR(50),
    child_id VARCHAR(50) PRIMARY KEY, --one parent multiple child
    FOREIGN KEY (parent_id) REFERENCES help_category(category_id),
    FOREIGN KEY (child_id) REFERENCES help_category(category_id)
);

/*
INSERT INTO help_category_map (parent_id, child_id)
SELECT
    CASE
        WHEN array_length(string_to_array(category_id, '.'), 1) = 1 THEN NULL
        ELSE substring(category_id from 1 for length(category_id) - length(split_part(category_id, '.', array_length(string_to_array(category_id, '.'), 1))) - 1)
    END AS parent_id,
    category_id AS child_id
FROM help_category;

CREATE OR REPLACE FUNCTION trg_category_map()
RETURNS TRIGGER AS $$
DECLARE
  parent_id VARCHAR(50);
BEGIN
     -- Determine parent_id from the NEW.category_id
  IF array_length(string_to_array(NEW.category_id, '.'), 1) = 1 THEN
    parent_id := NULL;     -- root level, no parent
  ELSE
    parent_id := substring(NEW.category_id FROM 1 FOR length(NEW.category_id) - length(split_part(NEW.category_id, '.', array_length(string_to_array(NEW.category_id, '.'), 1))) - 1
    );
  END IF;

  -- Insert into hierarchy map if not exists
  IF NOT EXISTS (
    SELECT 1 FROM help_category_map 
    WHERE child_id = NEW.category_id
  ) THEN
    INSERT INTO help_category_map(parent_id, child_id)
    VALUES (parent_id, NEW.category_id);
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_after_help_category
AFTER INSERT ON help_category
FOR EACH ROW
EXECUTE FUNCTION trg_category_map();
*/
