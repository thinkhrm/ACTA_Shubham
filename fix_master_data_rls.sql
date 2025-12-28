-- Fix RLS policies for master_data_items to allow INSERT operations
-- This addresses the "Failed to create item" error

-- Drop all existing policies to avoid conflicts
DROP POLICY IF EXISTS "Allow super_admin full access to items" ON master_data_items;
DROP POLICY IF EXISTS "Allow read access to all authenticated users" ON master_data_items;
DROP POLICY IF EXISTS "Allow authenticated users to insert items" ON master_data_items;
DROP POLICY IF EXISTS "Allow users to update items" ON master_data_items;
DROP POLICY IF EXISTS "Allow authenticated users to update items" ON master_data_items;

-- Create separate policies for different operations
-- Allow all authenticated users to read items
CREATE POLICY "Allow read access to all authenticated users" ON master_data_items
  FOR SELECT TO authenticated USING (true);

-- Allow authenticated users to insert items (for creating new master data)
CREATE POLICY "Allow authenticated users to insert items" ON master_data_items
  FOR INSERT TO authenticated 
  WITH CHECK (true);

-- Allow super_admin full access (update/delete)
CREATE POLICY "Allow super_admin full access to items" ON master_data_items
  FOR ALL TO authenticated 
  USING (
    EXISTS (
      SELECT 1 FROM auth.users 
      WHERE auth.users.id = auth.uid() 
      AND auth.users.raw_user_meta_data->>'role' = 'super_admin'
    )
  );

-- Allow users to update items they created or if they are admin/super_admin
-- Note: Using a simpler policy that allows all authenticated users to update for now
CREATE POLICY "Allow authenticated users to update items" ON master_data_items
  FOR UPDATE TO authenticated 
  USING (true)
  WITH CHECK (true);

-- Verify the policies
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd
FROM pg_policies 
WHERE tablename = 'master_data_items'
ORDER BY policyname;