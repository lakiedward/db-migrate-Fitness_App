-- ... existing tables ...

ALTER TABLE strava_user_data
ADD COLUMN fthr_cycling INT NULL COMMENT 'Functional Threshold Heart Rate in bpm',
ADD COLUMN fthr_running INT NULL COMMENT 'Functional Threshold Heart Rate for running in bpm',
ADD COLUMN fthr_swimming INT NULL COMMENT 'Functional Threshold Heart Rate for swimming in bpm',
ADD COLUMN fthr_other INT NULL COMMENT 'Functional Threshold Heart Rate for other sports in bpm',
ADD COLUMN fthr_updated_at DATETIME NULL COMMENT 'When FTHR was last updated',
ADD COLUMN fthr_source VARCHAR(20) NULL COMMENT 'Source of FTHR value (manual, auto_estimate, lab_test, field_test)',
ADD INDEX idx_fthr_updated (fthr_updated_at);

CREATE TABLE IF NOT EXISTS ftp_history (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    date DATETIME NOT NULL,
    estimated_ftp FLOAT NOT NULL,
    confidence FLOAT NOT NULL COMMENT 'Overall confidence in the estimate (0-1)',
    source_activities JSON NOT NULL COMMENT 'List of activity IDs used for estimation',
    method VARCHAR(50) NOT NULL COMMENT 'Estimation method(s) used (e.g., xgboost+fthr_based)',
    notes TEXT NULL COMMENT 'Detailed notes about the estimation process and confidence factors',
    confidence_metrics JSON NULL COMMENT 'Detailed confidence metrics from each estimation source',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    INDEX idx_user_date (user_id, date)
);

-- ... rest of the existing code ... 