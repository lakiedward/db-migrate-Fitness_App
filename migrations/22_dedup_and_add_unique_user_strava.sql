-- Deduplicate strava_activities by (user_id, strava_id) keeping the oldest row
DELETE s1 FROM strava_activities s1
JOIN strava_activities s2
  ON s1.user_id = s2.user_id
 AND s1.strava_id = s2.strava_id
 AND s1.id > s2.id;

-- Add a unique index to prevent future duplicates
-- If it already exists, the runner will treat the error as benign and continue
CREATE UNIQUE INDEX uq_user_strava ON strava_activities(user_id, strava_id);
