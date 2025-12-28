-- Master Data Clean Recreate SQL
-- This script will DROP existing tables and recreate them from scratch
-- ⚠️  WARNING: This will DELETE ALL existing master data! ⚠️
-- Use this only if you want to completely reset the master data tables

-- Drop existing tables (CASCADE will remove dependent objects)
DROP TABLE IF EXISTS master_data_items CASCADE;
DROP TABLE IF EXISTS master_data_categories CASCADE;

-- Drop existing functions if they exist
DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;

-- Create master_data_categories table
CREATE TABLE master_data_categories (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  type VARCHAR(100) NOT NULL UNIQUE,
  description TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create master_data_items table
CREATE TABLE master_data_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  category_id UUID NOT NULL REFERENCES master_data_categories(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  code VARCHAR(50),
  description TEXT,
  metadata JSONB DEFAULT '{}',
  is_active BOOLEAN DEFAULT true,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(category_id, name),
  UNIQUE(category_id, code)
);

-- Create indexes for better performance
CREATE INDEX idx_master_data_categories_type ON master_data_categories(type);
CREATE INDEX idx_master_data_categories_active ON master_data_categories(is_active);
CREATE INDEX idx_master_data_items_category ON master_data_items(category_id);
CREATE INDEX idx_master_data_items_active ON master_data_items(is_active);
CREATE INDEX idx_master_data_items_sort ON master_data_items(sort_order);

-- Insert master data categories
INSERT INTO master_data_categories (name, type, description, is_active) VALUES
('States', 'states', 'Indian states and union territories', true),
('Business Types', 'business_types', 'Types of business entities', true),
('Compliance Types', 'compliance_types', 'Types of compliance requirements', true),
('Document Categories', 'document_categories', 'Categories for document classification', true),
('Authorities', 'authorities', 'Government and regulatory authorities', true),
('Services', 'services', 'Available services and license types', true),
('Designations', 'designations', 'Employee designations and roles', true),
('Internal Entities', 'internal_entities', 'Internal company entities', true);

-- Insert States data
INSERT INTO master_data_items (category_id, name, code, description, metadata, sort_order) 
SELECT 
  c.id,
  state_data.name,
  state_data.code,
  'State: ' || state_data.name,
  state_data.metadata::jsonb,
  state_data.sort_order
FROM master_data_categories c
CROSS JOIN (VALUES 
  ('Andhra Pradesh', 'AP', '{"stateCode": "AP", "region": "South", "capital": "Amaravati"}', 1),
  ('Arunachal Pradesh', 'AR', '{"stateCode": "AR", "region": "Northeast", "capital": "Itanagar"}', 2),
  ('Assam', 'AS', '{"stateCode": "AS", "region": "Northeast", "capital": "Dispur"}', 3),
  ('Bihar', 'BR', '{"stateCode": "BR", "region": "East", "capital": "Patna"}', 4),
  ('Chhattisgarh', 'CG', '{"stateCode": "CG", "region": "Central", "capital": "Raipur"}', 5),
  ('Goa', 'GA', '{"stateCode": "GA", "region": "West", "capital": "Panaji"}', 6),
  ('Gujarat', 'GJ', '{"stateCode": "GJ", "region": "West", "capital": "Gandhinagar"}', 7),
  ('Haryana', 'HR', '{"stateCode": "HR", "region": "North", "capital": "Chandigarh"}', 8),
  ('Himachal Pradesh', 'HP', '{"stateCode": "HP", "region": "North", "capital": "Shimla"}', 9),
  ('Jharkhand', 'JH', '{"stateCode": "JH", "region": "East", "capital": "Ranchi"}', 10),
  ('Karnataka', 'KA', '{"stateCode": "KA", "region": "South", "capital": "Bengaluru"}', 11),
  ('Kerala', 'KL', '{"stateCode": "KL", "region": "South", "capital": "Thiruvananthapuram"}', 12),
  ('Madhya Pradesh', 'MP', '{"stateCode": "MP", "region": "Central", "capital": "Bhopal"}', 13),
  ('Maharashtra', 'MH', '{"stateCode": "MH", "region": "West", "capital": "Mumbai"}', 14),
  ('Manipur', 'MN', '{"stateCode": "MN", "region": "Northeast", "capital": "Imphal"}', 15),
  ('Meghalaya', 'ML', '{"stateCode": "ML", "region": "Northeast", "capital": "Shillong"}', 16),
  ('Mizoram', 'MZ', '{"stateCode": "MZ", "region": "Northeast", "capital": "Aizawl"}', 17),
  ('Nagaland', 'NL', '{"stateCode": "NL", "region": "Northeast", "capital": "Kohima"}', 18),
  ('Odisha', 'OR', '{"stateCode": "OR", "region": "East", "capital": "Bhubaneswar"}', 19),
  ('Punjab', 'PB', '{"stateCode": "PB", "region": "North", "capital": "Chandigarh"}', 20),
  ('Rajasthan', 'RJ', '{"stateCode": "RJ", "region": "North", "capital": "Jaipur"}', 21),
  ('Sikkim', 'SK', '{"stateCode": "SK", "region": "Northeast", "capital": "Gangtok"}', 22),
  ('Tamil Nadu', 'TN', '{"stateCode": "TN", "region": "South", "capital": "Chennai"}', 23),
  ('Telangana', 'TS', '{"stateCode": "TS", "region": "South", "capital": "Hyderabad"}', 24),
  ('Tripura', 'TR', '{"stateCode": "TR", "region": "Northeast", "capital": "Agartala"}', 25),
  ('Uttar Pradesh', 'UP', '{"stateCode": "UP", "region": "North", "capital": "Lucknow"}', 26),
  ('Uttarakhand', 'UK', '{"stateCode": "UK", "region": "North", "capital": "Dehradun"}', 27),
  ('West Bengal', 'WB', '{"stateCode": "WB", "region": "East", "capital": "Kolkata"}', 28),
  ('Delhi', 'DL', '{"stateCode": "DL", "region": "North", "capital": "New Delhi"}', 29),
  ('Jammu and Kashmir', 'JK', '{"stateCode": "JK", "region": "North", "capital": "Srinagar"}', 30),
  ('Ladakh', 'LA', '{"stateCode": "LA", "region": "North", "capital": "Leh"}', 31)
) AS state_data(name, code, metadata, sort_order)
WHERE c.type = 'states';

-- Insert Business Types data
INSERT INTO master_data_items (category_id, name, description, metadata, sort_order) 
SELECT 
  c.id,
  bt.name,
  bt.description,
  bt.metadata::jsonb,
  bt.sort_order
FROM master_data_categories c
CROSS JOIN (VALUES 
  ('Private Limited Company', 'Private company limited by shares', '{"incorporationType": "private", "minDirectors": 2, "maxDirectors": 200, "minShareholders": 2, "maxShareholders": 200}', 1),
  ('Public Limited Company', 'Public company limited by shares', '{"incorporationType": "public", "minDirectors": 3, "maxDirectors": null, "minShareholders": 7, "maxShareholders": null}', 2),
  ('Limited Liability Partnership', 'Partnership with limited liability', '{"incorporationType": "llp", "minPartners": 2, "maxPartners": null, "designatedPartners": 2}', 3),
  ('Partnership Firm', 'Traditional partnership business', '{"incorporationType": "partnership", "minPartners": 2, "maxPartners": 20, "registration": "optional"}', 4),
  ('Sole Proprietorship', 'Individual business ownership', '{"incorporationType": "proprietorship", "owners": 1, "liability": "unlimited", "registration": "optional"}', 5),
  ('One Person Company', 'Single person private company', '{"incorporationType": "opc", "members": 1, "directors": 1, "nominee": "required"}', 6)
) AS bt(name, description, metadata, sort_order)
WHERE c.type = 'business_types';

-- Insert Compliance Types data
INSERT INTO master_data_items (category_id, name, description, metadata, sort_order) 
SELECT 
  c.id,
  ct.name,
  ct.description,
  ct.metadata::jsonb,
  ct.sort_order
FROM master_data_categories c
CROSS JOIN (VALUES 
  ('PF Compliance', 'Provident Fund compliance requirements', '{"frequency": "monthly", "responsibility": "all", "weightage": 10, "category": "major"}', 1),
  ('ESI Compliance', 'Employee State Insurance compliance', '{"frequency": "monthly", "responsibility": "all", "weightage": 8, "category": "major"}', 2),
  ('Labour License', 'Labour license compliance', '{"frequency": "annual", "responsibility": "all", "weightage": 9, "category": "major"}', 3),
  ('Shops & Establishment', 'Shops and establishment license', '{"frequency": "annual", "responsibility": "all", "weightage": 7, "category": "moderate"}', 4),
  ('Contract Labour License', 'Contract labour license compliance', '{"frequency": "annual", "responsibility": "contractors", "weightage": 8, "category": "major"}', 5),
  ('Bonus Compliance', 'Bonus payment compliance', '{"frequency": "annual", "responsibility": "all", "weightage": 6, "category": "moderate"}', 6),
  ('Professional Tax', 'Professional tax compliance', '{"frequency": "monthly", "responsibility": "all", "weightage": 5, "category": "moderate"}', 7),
  ('Minimum Wages', 'Minimum wages compliance', '{"frequency": "monthly", "responsibility": "all", "weightage": 8, "category": "major"}', 8)
) AS ct(name, description, metadata, sort_order)
WHERE c.type = 'compliance_types';

-- Insert Document Categories data
INSERT INTO master_data_items (category_id, name, description, metadata, sort_order) 
SELECT 
  c.id,
  dc.name,
  dc.description,
  dc.metadata::jsonb,
  dc.sort_order
FROM master_data_categories c
CROSS JOIN (VALUES 
  ('Incorporation Documents', 'Company incorporation and registration documents', '{"required": true, "retention": "permanent", "access": "restricted"}', 1),
  ('Compliance Certificates', 'Various compliance certificates and licenses', '{"required": true, "retention": "5years", "access": "controlled"}', 2),
  ('Financial Documents', 'Financial statements and audit reports', '{"required": true, "retention": "7years", "access": "restricted"}', 3),
  ('HR Documents', 'Human resources and employee related documents', '{"required": false, "retention": "3years", "access": "hr_only"}', 4),
  ('Legal Documents', 'Legal agreements and contracts', '{"required": true, "retention": "permanent", "access": "legal_only"}', 5),
  ('Tax Documents', 'Tax returns and related documents', '{"required": true, "retention": "7years", "access": "finance_only"}', 6)
) AS dc(name, description, metadata, sort_order)
WHERE c.type = 'document_categories';

-- Insert Authorities data
INSERT INTO master_data_items (category_id, name, description, metadata, sort_order) 
SELECT 
  c.id,
  auth.name,
  auth.description,
  auth.metadata::jsonb,
  auth.sort_order
FROM master_data_categories c
CROSS JOIN (VALUES 
  ('Ministry of Corporate Affairs', 'Central government ministry for corporate regulation', '{"type": "central", "jurisdiction": "national", "website": "mca.gov.in"}', 1),
  ('Registrar of Companies', 'State-wise company registration authority', '{"type": "state", "jurisdiction": "state", "parent": "MCA"}', 2),
  ('Labour Department', 'State labour department for labour law compliance', '{"type": "state", "jurisdiction": "state", "focus": "labour"}', 3),
  ('EPFO', 'Employees Provident Fund Organisation', '{"type": "central", "jurisdiction": "national", "focus": "provident_fund"}', 4),
  ('ESIC', 'Employees State Insurance Corporation', '{"type": "central", "jurisdiction": "national", "focus": "medical_insurance"}', 5),
  ('Income Tax Department', 'Central tax collection authority', '{"type": "central", "jurisdiction": "national", "focus": "income_tax"}', 6),
  ('GST Department', 'Goods and Services Tax authority', '{"type": "central", "jurisdiction": "national", "focus": "gst"}', 7),
  ('Pollution Control Board', 'Environmental compliance authority', '{"type": "state", "jurisdiction": "state", "focus": "environment"}', 8)
) AS auth(name, description, metadata, sort_order)
WHERE c.type = 'authorities';

-- Insert Services data
INSERT INTO master_data_items (category_id, name, description, metadata, sort_order) 
SELECT 
  c.id,
  svc.name,
  svc.description,
  svc.metadata::jsonb,
  svc.sort_order
FROM master_data_categories c
CROSS JOIN (VALUES 
  ('Company Registration', 'New company incorporation services', '{"category": "incorporation", "timeline": "15-20 days", "documents_required": 8}', 1),
  ('GST Registration', 'Goods and Services Tax registration', '{"category": "tax", "timeline": "7-10 days", "documents_required": 5}', 2),
  ('PF Registration', 'Provident Fund registration for employees', '{"category": "compliance", "timeline": "10-15 days", "documents_required": 6}', 3),
  ('ESI Registration', 'Employee State Insurance registration', '{"category": "compliance", "timeline": "10-15 days", "documents_required": 6}', 4),
  ('Labour License', 'Labour license for hiring employees', '{"category": "license", "timeline": "20-30 days", "documents_required": 10}', 5),
  ('Shops & Establishment License', 'License for commercial establishments', '{"category": "license", "timeline": "15-20 days", "documents_required": 7}', 6),
  ('Professional Tax Registration', 'Professional tax registration', '{"category": "tax", "timeline": "5-7 days", "documents_required": 4}', 7),
  ('Contract Labour License', 'License for contract labour', '{"category": "license", "timeline": "25-35 days", "documents_required": 12}', 8)
) AS svc(name, description, metadata, sort_order)
WHERE c.type = 'services';

-- Insert Designations data
INSERT INTO master_data_items (category_id, name, description, metadata, sort_order) 
SELECT 
  c.id,
  des.name,
  des.description,
  des.metadata::jsonb,
  des.sort_order
FROM master_data_categories c
CROSS JOIN (VALUES 
  ('Chief Executive Officer', 'Chief Executive Officer', '{"level": "executive", "department": "executive"}', 1),
  ('Chief Technology Officer', 'Chief Technology Officer', '{"level": "executive", "department": "technology"}', 2),
  ('Chief Financial Officer', 'Chief Financial Officer', '{"level": "executive", "department": "finance"}', 3),
  ('Vice President', 'Vice President', '{"level": "executive", "department": "general"}', 4),
  ('General Manager', 'General Manager', '{"level": "director", "department": "general"}', 5),
  ('Assistant General Manager', 'Assistant General Manager', '{"level": "director", "department": "general"}', 6),
  ('Manager', 'Manager', '{"level": "manager", "department": "general"}', 7),
  ('Assistant Manager', 'Assistant Manager', '{"level": "manager", "department": "general"}', 8),
  ('Senior Executive', 'Senior Executive', '{"level": "senior", "department": "general"}', 9),
  ('Executive', 'Executive', '{"level": "junior", "department": "general"}', 10),
  ('Senior Associate', 'Senior Associate', '{"level": "senior", "department": "general"}', 11),
  ('Associate', 'Associate', '{"level": "junior", "department": "general"}', 12)
) AS des(name, description, metadata, sort_order)
WHERE c.type = 'designations';

-- Insert Internal Entities data
INSERT INTO master_data_items (category_id, name, description, metadata, sort_order) 
SELECT 
  c.id,
  ie.name,
  ie.description,
  ie.metadata::jsonb,
  ie.sort_order
FROM master_data_categories c
CROSS JOIN (VALUES 
  ('Thinkhrm', 'ThinkHRM Solutions', '{"entityType": "parent", "establishedYear": 2015, "headquarters": "Bangalore"}', 1),
  ('IndiThinkk', 'IndiThinkk Technologies', '{"entityType": "subsidiary", "establishedYear": 2018, "headquarters": "Hyderabad"}', 2),
  ('Proxima Global', 'Proxima Global Services', '{"entityType": "subsidiary", "establishedYear": 2020, "headquarters": "Mumbai"}', 3)
) AS ie(name, description, metadata, sort_order)
WHERE c.type = 'internal_entities';

-- Enable Row Level Security
ALTER TABLE master_data_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE master_data_items ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for master_data_categories
CREATE POLICY "Allow read access to all authenticated users" ON master_data_categories
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "Allow super_admin full access to categories" ON master_data_categories
  FOR ALL TO authenticated 
  USING (
    EXISTS (
      SELECT 1 FROM auth.users 
      WHERE auth.users.id = auth.uid() 
      AND auth.users.raw_user_meta_data->>'role' = 'super_admin'
    )
  );

-- Create RLS policies for master_data_items
CREATE POLICY "Allow read access to all authenticated users" ON master_data_items
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "Allow super_admin full access to items" ON master_data_items
  FOR ALL TO authenticated 
  USING (
    EXISTS (
      SELECT 1 FROM auth.users 
      WHERE auth.users.id = auth.uid() 
      AND auth.users.raw_user_meta_data->>'role' = 'super_admin'
    )
  );

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_master_data_categories_updated_at
    BEFORE UPDATE ON master_data_categories
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_master_data_items_updated_at
    BEFORE UPDATE ON master_data_items
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Verify data insertion
SELECT 
    c.name as category_name,
    c.type as category_type,
    COUNT(i.id) as items_count
FROM master_data_categories c
LEFT JOIN master_data_items i ON c.id = i.category_id
WHERE c.is_active = true
GROUP BY c.id, c.name, c.type
ORDER BY c.name;