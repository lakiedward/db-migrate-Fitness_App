-- Migration: Add source column to strava_activities table and modify constraints
-- This enables storing both Strava activities and app workouts in the same table

-- Step 1: Add source column to identify activity origin
ALTER TABLE strava_activities 
ADD COLUMN source ENUM('strava', 'app', 'garmin', 'wahoo', 'manual') DEFAULT 'strava' 
COMMENT 'Source of the activity data';

-- Step 2: Add indexes for source-based queries
CREATE INDEX idx_source ON strava_activities (source);
CREATE INDEX idx_user_source_date ON strava_activities (user_id, source, synced_at);

-- Step 3: Drop existing unique constraint
ALTER TABLE strava_activities DROP INDEX unique_activity;

-- Step 4: Add new unique constraint that handles both Strava and app IDs
ALTER TABLE strava_activities 
ADD UNIQUE KEY unique_activity_source (user_id, strava_id, source);

-- Step 5: Update existing records to have 'strava' as source
UPDATE strava_activities SET source = 'strava' WHERE source IS NULL;