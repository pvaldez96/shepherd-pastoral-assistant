-- Migration: 0004_people.sql
-- Purpose: Add people and contact management tables
-- Creates households, people, people_milestones, and contact_log tables with RLS policies, indexes, triggers, and full-text search
-- Dependencies: 0001_initial_schema.sql (users table, update_updated_at_column function)

-- Up Migration
BEGIN;

-- ============================================================================
-- TABLES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Households Table
-- Stores family/household groupings for people
-- ----------------------------------------------------------------------------
CREATE TABLE households (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

  -- Household information
  name TEXT NOT NULL,
  address TEXT,

  -- Audit timestamps
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

  -- Constraints
  CONSTRAINT households_name_not_empty CHECK (length(trim(name)) > 0)
);

-- Add comments for documentation
COMMENT ON TABLE households IS 'Family/household groupings for people management';
COMMENT ON COLUMN households.id IS 'UUID primary key (client-generated)';
COMMENT ON COLUMN households.user_id IS 'Foreign key to users table (multi-tenant isolation)';
COMMENT ON COLUMN households.name IS 'Household name (e.g., "Smith Family")';
COMMENT ON COLUMN households.address IS 'Optional household address';

-- ----------------------------------------------------------------------------
-- People Table
-- Stores contact database with categories and pastoral care tracking
-- Categories: elder, member, visitor, leadership, crisis, family, other
-- ----------------------------------------------------------------------------
CREATE TABLE people (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

  -- Personal information
  name TEXT NOT NULL,
  email TEXT,
  phone TEXT,

  -- Categorization
  category TEXT NOT NULL CHECK (category IN (
    'elder', 'member', 'visitor', 'leadership',
    'crisis', 'family', 'other'
  )),

  -- Household relationship
  household_id UUID REFERENCES households(id) ON DELETE SET NULL,

  -- Pastoral care tracking
  last_contact_date DATE,
  contact_frequency_override_days INTEGER,

  -- Additional information
  notes TEXT,
  tags TEXT[] DEFAULT '{}',

  -- Audit timestamps
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

  -- Constraints
  CONSTRAINT people_name_not_empty CHECK (length(trim(name)) > 0),
  CONSTRAINT people_contact_frequency_positive CHECK (
    contact_frequency_override_days IS NULL OR contact_frequency_override_days > 0
  )
);

-- Add comments for documentation
COMMENT ON TABLE people IS 'Contact database with categories and pastoral care tracking';
COMMENT ON COLUMN people.id IS 'UUID primary key (client-generated)';
COMMENT ON COLUMN people.user_id IS 'Foreign key to users table (multi-tenant isolation)';
COMMENT ON COLUMN people.name IS 'Person name (required)';
COMMENT ON COLUMN people.email IS 'Optional email address';
COMMENT ON COLUMN people.phone IS 'Optional phone number';
COMMENT ON COLUMN people.category IS 'Person category: elder, member, visitor, leadership, crisis, family, other';
COMMENT ON COLUMN people.household_id IS 'Optional foreign key to households table';
COMMENT ON COLUMN people.last_contact_date IS 'Date of most recent contact (automatically updated from contact_log)';
COMMENT ON COLUMN people.contact_frequency_override_days IS 'Override default contact frequency for this person (days)';
COMMENT ON COLUMN people.notes IS 'Free-form notes about the person';
COMMENT ON COLUMN people.tags IS 'Array of tags for flexible organization';

-- ----------------------------------------------------------------------------
-- People Milestones Table
-- Tracks birthdays, anniversaries, surgeries, and other important dates
-- ----------------------------------------------------------------------------
CREATE TABLE people_milestones (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  person_id UUID NOT NULL REFERENCES people(id) ON DELETE CASCADE,

  -- Milestone information
  milestone_type TEXT NOT NULL CHECK (milestone_type IN (
    'birthday', 'anniversary', 'surgery', 'other'
  )),

  date DATE NOT NULL,
  description TEXT,
  notify_days_before INTEGER DEFAULT 2,

  -- Audit timestamps
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

  -- Constraints
  CONSTRAINT milestones_notify_days_positive CHECK (
    notify_days_before IS NULL OR notify_days_before >= 0
  )
);

-- Add comments for documentation
COMMENT ON TABLE people_milestones IS 'Tracks birthdays, anniversaries, surgeries, and other important dates for people';
COMMENT ON COLUMN people_milestones.id IS 'UUID primary key (client-generated)';
COMMENT ON COLUMN people_milestones.person_id IS 'Foreign key to people table (CASCADE delete)';
COMMENT ON COLUMN people_milestones.milestone_type IS 'Type: birthday, anniversary, surgery, other';
COMMENT ON COLUMN people_milestones.date IS 'Date of the milestone';
COMMENT ON COLUMN people_milestones.description IS 'Optional description of the milestone';
COMMENT ON COLUMN people_milestones.notify_days_before IS 'Days before milestone to trigger notification (default: 2)';

-- ----------------------------------------------------------------------------
-- Contact Log Table
-- Logs all pastoral contacts (visits, calls, emails, texts, in-person, other)
-- ----------------------------------------------------------------------------
CREATE TABLE contact_log (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  person_id UUID NOT NULL REFERENCES people(id) ON DELETE CASCADE,

  -- Contact information
  contact_date DATE NOT NULL,
  contact_type TEXT NOT NULL CHECK (contact_type IN (
    'visit', 'call', 'email', 'text', 'in_person', 'other'
  )),

  duration_minutes INTEGER,
  notes TEXT,

  -- Audit timestamp (created_at only - contact logs are immutable)
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

  -- Constraints
  CONSTRAINT contact_log_duration_positive CHECK (
    duration_minutes IS NULL OR duration_minutes > 0
  )
);

-- Add comments for documentation
COMMENT ON TABLE contact_log IS 'Logs all pastoral contacts with people';
COMMENT ON COLUMN contact_log.id IS 'UUID primary key (client-generated)';
COMMENT ON COLUMN contact_log.user_id IS 'Foreign key to users table (multi-tenant isolation)';
COMMENT ON COLUMN contact_log.person_id IS 'Foreign key to people table (CASCADE delete)';
COMMENT ON COLUMN contact_log.contact_date IS 'Date of the contact';
COMMENT ON COLUMN contact_log.contact_type IS 'Type: visit, call, email, text, in_person, other';
COMMENT ON COLUMN contact_log.duration_minutes IS 'Optional duration in minutes';
COMMENT ON COLUMN contact_log.notes IS 'Optional notes about the contact';

-- ============================================================================
-- INDEXES
-- ============================================================================

-- Households indexes
CREATE INDEX idx_households_user_id ON households(user_id);

-- People indexes
CREATE INDEX idx_people_user_category ON people(user_id, category);
CREATE INDEX idx_people_user_last_contact ON people(user_id, last_contact_date);
CREATE INDEX idx_people_household_id ON people(household_id);

-- Full-text search on people.name
CREATE INDEX idx_people_name_gin ON people USING gin(to_tsvector('english', name));

-- GIN index for tags array
CREATE INDEX idx_people_tags ON people USING gin(tags);

-- People milestones indexes
CREATE INDEX idx_milestones_person_id ON people_milestones(person_id);
CREATE INDEX idx_milestones_date ON people_milestones(date);
CREATE INDEX idx_milestones_type_date ON people_milestones(milestone_type, date);

-- Contact log indexes
CREATE INDEX idx_contact_log_user_id ON contact_log(user_id);
CREATE INDEX idx_contact_log_person_id ON contact_log(person_id);
CREATE INDEX idx_contact_log_date ON contact_log(user_id, contact_date DESC);
CREATE INDEX idx_contact_log_person_date ON contact_log(person_id, contact_date DESC);

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Trigger to auto-update updated_at timestamp for households
CREATE TRIGGER update_households_updated_at
  BEFORE UPDATE ON households
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Trigger to auto-update updated_at timestamp for people
CREATE TRIGGER update_people_updated_at
  BEFORE UPDATE ON people
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Trigger to auto-update updated_at timestamp for people_milestones
CREATE TRIGGER update_milestones_updated_at
  BEFORE UPDATE ON people_milestones
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ----------------------------------------------------------------------------
-- Trigger to update people.last_contact_date when contact_log is inserted
-- This ensures pastoral care tracking stays current automatically
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION update_last_contact_date()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE people
  SET last_contact_date = NEW.contact_date,
      updated_at = NOW()
  WHERE id = NEW.person_id
    AND (last_contact_date IS NULL OR last_contact_date < NEW.contact_date);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER contact_log_update_last_contact
  AFTER INSERT ON contact_log
  FOR EACH ROW
  EXECUTE FUNCTION update_last_contact_date();

COMMENT ON FUNCTION update_last_contact_date() IS 'Automatically updates people.last_contact_date when contact_log entry is inserted';

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

-- Enable RLS on all tables
ALTER TABLE households ENABLE ROW LEVEL SECURITY;
ALTER TABLE people ENABLE ROW LEVEL SECURITY;
ALTER TABLE people_milestones ENABLE ROW LEVEL SECURITY;
ALTER TABLE contact_log ENABLE ROW LEVEL SECURITY;

-- ----------------------------------------------------------------------------
-- Households RLS Policies
-- ----------------------------------------------------------------------------
CREATE POLICY "Users can view own households"
  ON households FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own households"
  ON households FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own households"
  ON households FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own households"
  ON households FOR DELETE
  USING (auth.uid() = user_id);

-- ----------------------------------------------------------------------------
-- People RLS Policies
-- ----------------------------------------------------------------------------
CREATE POLICY "Users can view own people"
  ON people FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own people"
  ON people FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own people"
  ON people FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own people"
  ON people FOR DELETE
  USING (auth.uid() = user_id);

-- ----------------------------------------------------------------------------
-- People Milestones RLS Policies
-- Milestones inherit permissions from parent person record
-- ----------------------------------------------------------------------------
CREATE POLICY "Users can view milestones for own people"
  ON people_milestones FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM people
    WHERE people.id = people_milestones.person_id
    AND people.user_id = auth.uid()
  ));

CREATE POLICY "Users can insert milestones for own people"
  ON people_milestones FOR INSERT
  WITH CHECK (EXISTS (
    SELECT 1 FROM people
    WHERE people.id = people_milestones.person_id
    AND people.user_id = auth.uid()
  ));

CREATE POLICY "Users can update milestones for own people"
  ON people_milestones FOR UPDATE
  USING (EXISTS (
    SELECT 1 FROM people
    WHERE people.id = people_milestones.person_id
    AND people.user_id = auth.uid()
  ));

CREATE POLICY "Users can delete milestones for own people"
  ON people_milestones FOR DELETE
  USING (EXISTS (
    SELECT 1 FROM people
    WHERE people.id = people_milestones.person_id
    AND people.user_id = auth.uid()
  ));

-- ----------------------------------------------------------------------------
-- Contact Log RLS Policies
-- ----------------------------------------------------------------------------
CREATE POLICY "Users can view own contact logs"
  ON contact_log FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own contact logs"
  ON contact_log FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own contact logs"
  ON contact_log FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own contact logs"
  ON contact_log FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================================
-- ADD FOREIGN KEY CONSTRAINTS TO EXISTING TABLES
-- ============================================================================

-- Add foreign key constraint from tasks.person_id to people.id
-- This was deferred in migration 0002_tasks_table.sql
ALTER TABLE tasks
  ADD CONSTRAINT tasks_person_id_fkey
  FOREIGN KEY (person_id)
  REFERENCES people(id)
  ON DELETE SET NULL;

-- Add foreign key constraint from calendar_events.person_id to people.id
-- This was deferred in migration 0003_calendar_events.sql
ALTER TABLE calendar_events
  ADD CONSTRAINT calendar_events_person_id_fkey
  FOREIGN KEY (person_id)
  REFERENCES people(id)
  ON DELETE SET NULL;

-- Add index for tasks.person_id (for performance)
CREATE INDEX idx_tasks_person_id ON tasks(person_id) WHERE person_id IS NOT NULL;

-- Add index for calendar_events.person_id (for performance)
CREATE INDEX idx_calendar_events_person_id ON calendar_events(person_id) WHERE person_id IS NOT NULL;

COMMIT;

-- ============================================================================
-- Down Migration (Rollback)
-- ============================================================================

-- To rollback this migration, run:
-- BEGIN;
--
-- -- Remove foreign key constraints from existing tables
-- ALTER TABLE tasks DROP CONSTRAINT IF EXISTS tasks_person_id_fkey;
-- ALTER TABLE calendar_events DROP CONSTRAINT IF EXISTS calendar_events_person_id_fkey;
-- DROP INDEX IF EXISTS idx_tasks_person_id;
-- DROP INDEX IF EXISTS idx_calendar_events_person_id;
--
-- -- Drop tables in reverse dependency order
-- DROP TRIGGER IF EXISTS contact_log_update_last_contact ON contact_log;
-- DROP FUNCTION IF EXISTS update_last_contact_date();
-- DROP TABLE IF EXISTS contact_log CASCADE;
-- DROP TABLE IF EXISTS people_milestones CASCADE;
-- DROP TABLE IF EXISTS people CASCADE;
-- DROP TABLE IF EXISTS households CASCADE;
--
-- COMMIT;
