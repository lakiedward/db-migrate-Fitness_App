-- Add an indexed datetime column for fast date range queries on activities
-- Option A (preferred, MySQL 8): STORED generated column from JSON
-- If your MySQL supports it, uncomment the following lines and run:
--
-- ALTER TABLE strava_activities 
--   ADD COLUMN start_date_dt DATETIME 
--   GENERATED ALWAYS AS (
--     STR_TO_DATE(JSON_UNQUOTE(JSON_EXTRACT(activity_data, '$.start_date')),
--                 '%Y-%m-%dT%H:%i:%sZ')
--   ) STORED;
-- CREATE INDEX idx_user_start_date ON strava_activities (user_id, start_date_dt DESC);

-- Option B (compatible): materialize + backfill, then index
-- Run these if Option A is not supported
ALTER TABLE strava_activities ADD COLUMN start_date_dt DATETIME NULL;
UPDATE strava_activities 
  SET start_date_dt = STR_TO_DATE(JSON_UNQUOTE(JSON_EXTRACT(activity_data, '$.start_date')), '%Y-%m-%dT%H:%i:%sZ')
  WHERE start_date_dt IS NULL;
ALTER TABLE strava_activities MODIFY start_date_dt DATETIME NOT NULL;
CREATE INDEX idx_user_start_date ON strava_activities (user_id, start_date_dt DESC);

