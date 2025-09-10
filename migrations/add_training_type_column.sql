-- Add column to track the sport associated with each workout
ALTER TABLE training_plan
ADD COLUMN workout_type VARCHAR(20) DEFAULT NULL AFTER description;
