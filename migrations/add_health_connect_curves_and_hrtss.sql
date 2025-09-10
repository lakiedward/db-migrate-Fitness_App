-- Add running_distance_time_curve, swim_distance_time_curve and HrTSS columns to health_connect_activities

ALTER TABLE health_connect_activities
ADD COLUMN running_distance_time_curve JSON NULL AFTER activity_data,
ADD COLUMN swim_distance_time_curve JSON NULL AFTER running_distance_time_curve,
ADD COLUMN HrTSS DOUBLE NULL AFTER swim_distance_time_curve;