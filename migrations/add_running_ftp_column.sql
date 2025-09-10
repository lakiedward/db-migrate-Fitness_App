-- Add column to store Functional Threshold Pace for running
ALTER TABLE running_pace_predictions
ADD COLUMN running_ftp FLOAT DEFAULT NULL COMMENT 'Functional threshold pace in min/km';
