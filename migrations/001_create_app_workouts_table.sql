-- Migration: Create app_workouts table for storing executed workouts from the app
-- This table stores workout sessions completed by users within the app (separate from Strava activities)

CREATE TABLE IF NOT EXISTS `app_workouts` (
    `id` int NOT NULL AUTO_INCREMENT,
    `user_id` int NOT NULL,
    `training_plan_id` int DEFAULT NULL COMMENT 'Reference to training_plan table if workout was from a plan',
    `workout_name` varchar(255) NOT NULL COMMENT 'Name of the workout',
    `start_time` datetime NOT NULL COMMENT 'When the workout started',
    `end_time` datetime NOT NULL COMMENT 'When the workout ended',
    `duration` int NOT NULL COMMENT 'Total workout duration in seconds',
    `total_power` int DEFAULT NULL COMMENT 'Total power output in watts (for cycling)',
    `average_power` int DEFAULT NULL COMMENT 'Average power output in watts (for cycling)',
    `max_power` int DEFAULT NULL COMMENT 'Maximum power output in watts (for cycling)',
    `average_heart_rate` int DEFAULT NULL COMMENT 'Average heart rate in BPM',
    `max_heart_rate` int DEFAULT NULL COMMENT 'Maximum heart rate in BPM',
    `distance` float DEFAULT NULL COMMENT 'Distance covered in meters',
    `calories_burned` int DEFAULT NULL COMMENT 'Estimated calories burned',
    `workout_data` json DEFAULT NULL COMMENT 'Detailed workout data (steps, intervals, etc.)',
    `performance_metrics` json DEFAULT NULL COMMENT 'Performance metrics and statistics',
    `notes` text DEFAULT NULL COMMENT 'User notes about the workout',
    `workout_type` enum('cycling', 'running', 'swimming', 'strength', 'other') DEFAULT 'cycling' COMMENT 'Type of workout',
    `completed` boolean DEFAULT TRUE COMMENT 'Whether the workout was completed or stopped early',
    `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
    `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_start_time` (`start_time`),
    KEY `idx_workout_type` (`workout_type`),
    KEY `idx_training_plan_id` (`training_plan_id`),
    CONSTRAINT `app_workouts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    CONSTRAINT `app_workouts_ibfk_2` FOREIGN KEY (`training_plan_id`) REFERENCES `training_plan` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Add indexes for better query performance
CREATE INDEX `idx_user_date` ON `app_workouts` (`user_id`, `start_time`);
CREATE INDEX `idx_completed_workouts` ON `app_workouts` (`user_id`, `completed`, `start_time`);