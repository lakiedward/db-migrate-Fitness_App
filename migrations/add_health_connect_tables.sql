-- Tabelul principal pentru activitățile Health Connect
CREATE TABLE health_connect_activities (
    id VARCHAR(255) PRIMARY KEY,
    user_id INT NOT NULL,
    health_connect_id VARCHAR(255) UNIQUE NOT NULL,
    exercise_type INT NOT NULL,
    exercise_type_name VARCHAR(100),
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP,
    duration BIGINT,
    steps BIGINT DEFAULT 0,
    calories DECIMAL(10,2) DEFAULT 0,
    distance DECIMAL(12,2) DEFAULT 0,
    avg_heart_rate INT,
    max_heart_rate INT,
    min_heart_rate INT,
    title VARCHAR(255),
    notes TEXT,
    activity_data JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    synced_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id),
    INDEX idx_user_start_time (user_id, start_time),
    INDEX idx_exercise_type (exercise_type),
    INDEX idx_synced_at (synced_at),
    INDEX idx_health_connect_id (health_connect_id)
);

CREATE TABLE health_connect_heart_rate (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    activity_id VARCHAR(255) NOT NULL,
    timestamp TIMESTAMP NOT NULL,
    beats_per_minute INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (activity_id) REFERENCES health_connect_activities(id) ON DELETE CASCADE,
    INDEX idx_activity_timestamp (activity_id, timestamp)
);

CREATE TABLE health_connect_sync_log (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    sync_type ENUM('auto', 'manual') NOT NULL DEFAULT 'auto',
    start_date DATE,
    end_date DATE,
    activities_synced INT DEFAULT 0,
    success BOOLEAN DEFAULT TRUE,
    error_message TEXT,
    sync_duration_ms BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id),
    INDEX idx_user_created (user_id, created_at)
);
