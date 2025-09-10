-- Add swim_distance_time_curve column to store best swimming segment times
ALTER TABLE strava_activities
ADD COLUMN swim_distance_time_curve JSON NULL AFTER running_distance_time_curve;
