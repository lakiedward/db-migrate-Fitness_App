-- Add HrTSS column for storing heart rate based training stress
ALTER TABLE strava_activities
ADD COLUMN HrTSS DOUBLE NULL AFTER max_20min_power;
