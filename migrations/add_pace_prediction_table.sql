-- Create table for storing running pace prediction results
CREATE TABLE IF NOT EXISTS running_pace_predictions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    predictions JSON NOT NULL,
    running_ftp FLOAT DEFAULT NULL COMMENT 'Functional threshold pace in min/km',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_created (user_id, created_at)
);
