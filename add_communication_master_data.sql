-- ACTA: Add Communication master data (Types, Sub Types) and integrity
-- Safe, idempotent: patches schema if needed, inserts/updates items, adds trigger.
-- Notes:
-- - Run with sufficient privileges (service role/admin) if RLS blocks writes.
-- - Uses NOT EXISTS for idempotent inserts to avoid dependency on unique constraints.

BEGIN;

-- 1) Patch schema: ensure master_data_categories.sort_order exists
ALTER TABLE master_data_categories
  ADD COLUMN IF NOT EXISTS sort_order INTEGER DEFAULT 1;

UPDATE master_data_categories
SET sort_order = COALESCE(sort_order, 1);

CREATE INDEX IF NOT EXISTS idx_master_data_categories_sort
  ON master_data_categories(sort_order);

-- 2) Ensure required categories exist (Communication Types, Sub Types, Authorities)
INSERT INTO master_data_categories (name, type, description, is_active, sort_order)
SELECT 'Communication Types', 'communication_types', 'Types of Govt/Authority communications', true, 9
WHERE NOT EXISTS (
  SELECT 1 FROM master_data_categories WHERE type = 'communication_types'
);

INSERT INTO master_data_categories (name, type, description, is_active, sort_order)
SELECT 'Communication Sub Types', 'communication_sub_types', 'Sub types of communications linked to type', true, 10
WHERE NOT EXISTS (
  SELECT 1 FROM master_data_categories WHERE type = 'communication_sub_types'
);

INSERT INTO master_data_categories (name, type, description, is_active, sort_order)
SELECT 'Authorities', 'authorities', 'Government and regulatory authorities', true, 5
WHERE NOT EXISTS (
  SELECT 1 FROM master_data_categories WHERE type = 'authorities'
);

-- 3) Communication Types: insert missing, then align existing via update
WITH type_vals AS (
  SELECT * FROM (
    VALUES
      ('notice'::text, 'Official notice from authority'::text, '{"code":"NOTICE"}'::text, 1),
      ('summon', 'Summon/appearance order', '{"code":"SUMMON"}', 2),
      ('inspection', 'Inspection communication', '{"code":"INSPECTION"}', 3),
      ('general', 'General correspondence', '{"code":"GENERAL"}', 4)
  ) AS v(name, description, metadata, sort_order)
)
INSERT INTO master_data_items (category_id, name, description, metadata, sort_order)
SELECT c.id, v.name, v.description, v.metadata::jsonb, v.sort_order
FROM master_data_categories c
JOIN type_vals v ON TRUE
WHERE c.type = 'communication_types'
  AND NOT EXISTS (
    SELECT 1 FROM master_data_items i
    WHERE i.category_id = c.id AND i.name = v.name
  );

-- Update existing Communication Types to ensure canonical description/metadata/sort
WITH type_vals AS (
  SELECT * FROM (
    VALUES
      ('notice'::text, 'Official notice from authority'::text, '{"code":"NOTICE"}'::text, 1),
      ('summon', 'Summon/appearance order', '{"code":"SUMMON"}', 2),
      ('inspection', 'Inspection communication', '{"code":"INSPECTION"}', 3),
      ('general', 'General correspondence', '{"code":"GENERAL"}', 4)
  ) AS v(name, description, metadata, sort_order)
)
UPDATE master_data_items i
SET description = v.description,
    metadata = v.metadata::jsonb,
    sort_order = v.sort_order
FROM master_data_categories c
JOIN type_vals v ON TRUE
WHERE c.type = 'communication_types'
  AND i.category_id = c.id
  AND i.name = v.name;

-- 4) Communication Sub Types: each has metadata.parent_type referencing a type
WITH subtype_vals AS (
  SELECT * FROM (
    VALUES
      ('Show Cause Notice'::text, 'Explanation request notice'::text, '{"parent_type":"notice","code":"SCN"}'::text, 1),
      ('Compliance Notice', 'Compliance deficiency notice', '{"parent_type":"notice"}', 2),
      ('Court Summon', 'Summon from court', '{"parent_type":"summon"}', 1),
      ('Authority Summon', 'Summon from authority', '{"parent_type":"summon"}', 2),
      ('Routine Inspection', 'Scheduled inspection', '{"parent_type":"inspection"}', 1),
      ('Surprise Inspection', 'Unannounced inspection', '{"parent_type":"inspection"}', 2),
      ('General Advisory', 'Advisory communication', '{"parent_type":"general"}', 1)
  ) AS v(name, description, metadata, sort_order)
)
INSERT INTO master_data_items (category_id, name, description, metadata, sort_order)
SELECT c.id, v.name, v.description, v.metadata::jsonb, v.sort_order
FROM master_data_categories c
JOIN subtype_vals v ON TRUE
WHERE c.type = 'communication_sub_types'
  AND NOT EXISTS (
    SELECT 1 FROM master_data_items i
    WHERE i.category_id = c.id AND i.name = v.name
  );

-- Update existing Sub Types to ensure canonical description/metadata/sort
WITH subtype_vals AS (
  SELECT * FROM (
    VALUES
      ('Show Cause Notice'::text, 'Explanation request notice'::text, '{"parent_type":"notice","code":"SCN"}'::text, 1),
      ('Compliance Notice', 'Compliance deficiency notice', '{"parent_type":"notice"}', 2),
      ('Court Summon', 'Summon from court', '{"parent_type":"summon"}', 1),
      ('Authority Summon', 'Summon from authority', '{"parent_type":"summon"}', 2),
      ('Routine Inspection', 'Scheduled inspection', '{"parent_type":"inspection"}', 1),
      ('Surprise Inspection', 'Unannounced inspection', '{"parent_type":"inspection"}', 2),
      ('General Advisory', 'Advisory communication', '{"parent_type":"general"}', 1)
  ) AS v(name, description, metadata, sort_order)
)
UPDATE master_data_items i
SET description = v.description,
    metadata = v.metadata::jsonb,
    sort_order = v.sort_order
FROM master_data_categories c
JOIN subtype_vals v ON TRUE
WHERE c.type = 'communication_sub_types'
  AND i.category_id = c.id
  AND i.name = v.name;

-- 5) Trigger to enforce that Sub Types reference an existing Communication Type
CREATE OR REPLACE FUNCTION enforce_comm_subtype_parent()
RETURNS TRIGGER AS $$
DECLARE
  cat_type TEXT;
  parent_exists BOOLEAN;
  parent_name TEXT;
BEGIN
  SELECT type INTO cat_type FROM master_data_categories WHERE id = NEW.category_id;

  IF cat_type = 'communication_sub_types' THEN
    parent_name := COALESCE(NEW.metadata->>'parent_type', '');
    IF parent_name = '' THEN
      RAISE EXCEPTION 'communication_sub_type "%" must have metadata.parent_type', NEW.name;
    END IF;

    SELECT EXISTS (
      SELECT 1
      FROM master_data_items i
      JOIN master_data_categories c ON c.id = i.category_id
      WHERE c.type = 'communication_types' AND i.name = parent_name
    ) INTO parent_exists;

    IF NOT parent_exists THEN
      RAISE EXCEPTION 'parent_type "%" not found in communication_types', parent_name;
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_enforce_comm_subtype_parent ON master_data_items;
CREATE TRIGGER trg_enforce_comm_subtype_parent
  BEFORE INSERT OR UPDATE ON master_data_items
  FOR EACH ROW EXECUTE FUNCTION enforce_comm_subtype_parent();

-- 6) Verification (optional)
-- Category overview
SELECT c.name AS category_name, c.type AS category_type, COUNT(i.id) AS items_count
FROM master_data_categories c
LEFT JOIN master_data_items i ON i.category_id = c.id
WHERE c.type IN ('communication_types', 'communication_sub_types', 'authorities')
GROUP BY c.id, c.name, c.type
ORDER BY c.sort_order, c.name;

-- Sub Types with their parent type
SELECT st.name AS sub_type, st.metadata->>'parent_type' AS parent_type
FROM master_data_items st
JOIN master_data_categories c ON c.id = st.category_id
WHERE c.type = 'communication_sub_types'
ORDER BY st.sort_order, st.name;

COMMIT;