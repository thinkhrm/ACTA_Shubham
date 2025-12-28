-- Debug script to check master data structure and data
-- Run this to diagnose the "Failed to create item" error for Internal Entities

-- 1. Check if tables exist and their structure
SELECT 
    table_name, 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name IN ('master_data_categories', 'master_data_items')
ORDER BY table_name, ordinal_position;

-- 2. Check if internal_entities category exists
SELECT * FROM master_data_categories WHERE type = 'internal_entities';

-- 3. Check existing internal entities items
SELECT 
    mdi.*,
    mdc.name as category_name,
    mdc.type as category_type
FROM master_data_items mdi
JOIN master_data_categories mdc ON mdi.category_id = mdc.id
WHERE mdc.type = 'internal_entities';

-- 4. Check RLS policies on master_data_items
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'master_data_items';

-- 5. Check constraints on master_data_items
SELECT 
    tc.constraint_name,
    tc.constraint_type,
    kcu.column_name,
    tc.is_deferrable,
    tc.initially_deferred
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu 
    ON tc.constraint_name = kcu.constraint_name
WHERE tc.table_name = 'master_data_items';

-- 6. Test insert permissions (this will show if RLS blocks the insert)
-- Note: This is just a test query, don't actually run the insert
EXPLAIN (ANALYZE, BUFFERS) 
SELECT 1 FROM master_data_categories WHERE type = 'internal_entities';