-- Add running_distance_time_curve column to store best running segment times
ALTER TABLE strava_activities
ADD COLUMN running_distance_time_curve JSON NULL AFTER power_curve;
