-- Add gpx_path column to store the path of the original GPX file
ALTER TABLE strava_activities
ADD COLUMN gpx_path VARCHAR(255) DEFAULT NULL AFTER HrTSS;

