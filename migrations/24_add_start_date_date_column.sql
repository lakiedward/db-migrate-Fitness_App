-- Add DATE column for Strava activity start date and supporting index
ALTER TABLE strava_activities
    ADD COLUMN start_date_date DATE NULL AFTER start_date_dt;

-- Backfill from existing datetime column when available
UPDATE strava_activities
SET start_date_date = DATE(start_date_dt)
WHERE start_date_dt IS NOT NULL
  AND start_date_date IS NULL;

-- For legacy rows without start_date_dt, attempt to parse from JSON payload once
UPDATE strava_activities
SET start_date_date = DATE(STR_TO_DATE(JSON_UNQUOTE(JSON_EXTRACT(activity_data, '$.start_date')),
                                       '%Y-%m-%dT%H:%i:%s'))
WHERE start_date_date IS NULL
  AND JSON_EXTRACT(activity_data, '$.start_date') IS NOT NULL;

-- Create covering index to accelerate lookups by user and date
CREATE INDEX idx_strava_activities_user_start_date
    ON strava_activities (user_id, start_date_date, start_date_dt, id);