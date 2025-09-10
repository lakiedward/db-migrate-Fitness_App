-- Performance: add indexed start_date_dt used by calendar unified activities
-- Idempotent and compatible with MySQL 8

-- Add column start_date_dt if missing
SET @col_exists := (
  SELECT COUNT(*) FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'strava_activities'
    AND column_name = 'start_date_dt'
);
SET @sql := IF(@col_exists = 0,
  'ALTER TABLE strava_activities ADD COLUMN start_date_dt DATETIME NULL',
  'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Backfill values
UPDATE strava_activities 
  SET start_date_dt = STR_TO_DATE(JSON_UNQUOTE(JSON_EXTRACT(activity_data, '$.start_date')), '%Y-%m-%dT%H:%i:%sZ')
  WHERE start_date_dt IS NULL;

-- Make NOT NULL only if no NULLs remain
SET @nulls := (SELECT COUNT(*) FROM strava_activities WHERE start_date_dt IS NULL);
SET @sql := IF(@nulls = 0,
  'ALTER TABLE strava_activities MODIFY COLUMN start_date_dt DATETIME NOT NULL',
  'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Create index if missing
SET @idx_exists := (
  SELECT COUNT(*) FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name = 'strava_activities'
    AND index_name = 'idx_user_start_date'
);
SET @sql := IF(@idx_exists = 0,
  'CREATE INDEX idx_user_start_date ON strava_activities (user_id, start_date_dt)',
  'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

