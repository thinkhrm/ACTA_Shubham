-- Quick script to create Years category in Supabase Dashboard
-- Copy and paste this into your Supabase SQL Editor

-- Insert Year category into master_data_categories
INSERT INTO master_data_categories (name, type, description, sort_order) VALUES
('Years', 'years', 'Financial and calendar years for reporting and data management', 8)
ON CONFLICT (type) DO NOTHING;

-- Insert year items (covering a reasonable range for business operations)
INSERT INTO master_data_items (category_id, name, code, description, metadata, sort_order) 
SELECT 
  c.id,
  year_data.name,
  year_data.code,
  year_data.description,
  year_data.metadata::jsonb,
  year_data.sort_order
FROM master_data_categories c,
(VALUES 
  ('2020', '2020', 'Year 2020', '{"year": 2020, "isActive": true, "type": "calendar"}', 1),
  ('2021', '2021', 'Year 2021', '{"year": 2021, "isActive": true, "type": "calendar"}', 2),
  ('2022', '2022', 'Year 2022', '{"year": 2022, "isActive": true, "type": "calendar"}', 3),
  ('2023', '2023', 'Year 2023', '{"year": 2023, "isActive": true, "type": "calendar"}', 4),
  ('2024', '2024', 'Year 2024', '{"year": 2024, "isActive": true, "type": "calendar"}', 5),
  ('2025', '2025', 'Year 2025', '{"year": 2025, "isActive": true, "type": "calendar"}', 6),
  ('2026', '2026', 'Year 2026', '{"year": 2026, "isActive": true, "type": "calendar"}', 7),
  ('2027', '2027', 'Year 2027', '{"year": 2027, "isActive": true, "type": "calendar"}', 8),
  ('2028', '2028', 'Year 2028', '{"year": 2028, "isActive": true, "type": "calendar"}', 9),
  ('2029', '2029', 'Year 2029', '{"year": 2029, "isActive": true, "type": "calendar"}', 10),
  ('2030', '2030', 'Year 2030', '{"year": 2030, "isActive": true, "type": "calendar"}', 11),
  -- Financial Years (April to March)
  ('FY 2020-21', 'FY2021', 'Financial Year 2020-21', '{"startYear": 2020, "endYear": 2021, "isActive": true, "type": "financial", "startMonth": 4, "endMonth": 3}', 12),
  ('FY 2021-22', 'FY2022', 'Financial Year 2021-22', '{"startYear": 2021, "endYear": 2022, "isActive": true, "type": "financial", "startMonth": 4, "endMonth": 3}', 13),
  ('FY 2022-23', 'FY2023', 'Financial Year 2022-23', '{"startYear": 2022, "endYear": 2023, "isActive": true, "type": "financial", "startMonth": 4, "endMonth": 3}', 14),
  ('FY 2023-24', 'FY2024', 'Financial Year 2023-24', '{"startYear": 2023, "endYear": 2024, "isActive": true, "type": "financial", "startMonth": 4, "endMonth": 3}', 15),
  ('FY 2024-25', 'FY2025', 'Financial Year 2024-25', '{"startYear": 2024, "endYear": 2025, "isActive": true, "type": "financial", "startMonth": 4, "endMonth": 3}', 16),
  ('FY 2025-26', 'FY2026', 'Financial Year 2025-26', '{"startYear": 2025, "endYear": 2026, "isActive": true, "type": "financial", "startMonth": 4, "endMonth": 3}', 17),
  ('FY 2026-27', 'FY2027', 'Financial Year 2026-27', '{"startYear": 2026, "endYear": 2027, "isActive": true, "type": "financial", "startMonth": 4, "endMonth": 3}', 18),
  ('FY 2027-28', 'FY2028', 'Financial Year 2027-28', '{"startYear": 2027, "endYear": 2028, "isActive": true, "type": "financial", "startMonth": 4, "endMonth": 3}', 19),
  ('FY 2028-29', 'FY2029', 'Financial Year 2028-29', '{"startYear": 2028, "endYear": 2029, "isActive": true, "type": "financial", "startMonth": 4, "endMonth": 3}', 20),
  ('FY 2029-30', 'FY2030', 'Financial Year 2029-30', '{"startYear": 2029, "endYear": 2030, "isActive": true, "type": "financial", "startMonth": 4, "endMonth": 3}', 21)
) AS year_data(name, code, description, metadata, sort_order)
WHERE c.type = 'years'
ON CONFLICT DO NOTHING;

-- Create index for better performance on year queries
CREATE INDEX IF NOT EXISTS idx_master_data_items_year_metadata 
ON master_data_items USING GIN(metadata);