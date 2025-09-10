-- Migration: Performance optimization for unified strava_activities table
-- Add optimized indexes and computed columns for better query performance

-- Step 1: Add optimized indexes for JSON queries
CREATE INDEX idx_activity_type ON strava_activities ((JSON_UNQUOTE(JSON_EXTRACT(activity_data, '$.type'))));
CREATE INDEX idx_activity_date ON strava_activities ((JSON_UNQUOTE(JSON_EXTRACT(activity_data, '$.start_date'))));
CREATE INDEX idx_has_power ON strava_activities ((JSON_EXTRACT(activity_data, '$.average_watts') IS NOT NULL));
CREATE INDEX idx_has_heartrate ON strava_activities ((JSON_EXTRACT(activity_data, '$.has_heartrate')));

-- Step 2: Add computed columns for frequently queried fields (optional but recommended)
ALTER TABLE strava_activities 
ADD COLUMN activity_type VARCHAR(50) 
GENERATED ALWAYS AS (JSON_UNQUOTE(JSON_EXTRACT(activity_data, '$.type'))) STORED;

ALTER TABLE strava_activities 
ADD COLUMN activity_date DATE 
GENERATED ALWAYS AS (DATE(JSON_UNQUOTE(JSON_EXTRACT(activity_data, '$.start_date')))) STORED;

ALTER TABLE strava_activities 
ADD COLUMN has_power BOOLEAN 
GENERATED ALWAYS AS (JSON_EXTRACT(activity_data, '$.average_watts') IS NOT NULL) STORED;

ALTER TABLE strava_activities 
ADD COLUMN has_heartrate BOOLEAN 
GENERATED ALWAYS AS (JSON_EXTRACT(activity_data, '$.has_heartrate') = true) STORED;

-- Step 3: Index the computed columns for better performance
CREATE INDEX idx_computed_type ON strava_activities (activity_type);
CREATE INDEX idx_computed_date ON strava_activities (activity_date);
CREATE INDEX idx_computed_has_power ON strava_activities (has_power);
CREATE INDEX idx_computed_has_heartrate ON strava_activities (has_heartrate);

-- Step 4: Composite indexes for common query patterns
CREATE INDEX idx_user_type_date ON strava_activities (user_id, activity_type, activity_date);
CREATE INDEX idx_user_source_type ON strava_activities (user_id, source, activity_type);
CREATE INDEX idx_user_power_date ON strava_activities (user_id, has_power, activity_date) WHERE has_power = 1;