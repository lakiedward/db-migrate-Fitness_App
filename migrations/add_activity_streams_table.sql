CREATE TABLE activity_streams (
    id INT PRIMARY KEY AUTO_INCREMENT,
    activity_id INT NOT NULL,
    user_id INT NOT NULL,
    stream_type ENUM('watts', 'heartrate', 'distance', 'time', 'altitude', 'cadence', 'velocity_smooth', 'grade_smooth', 'latlng') NOT NULL,
    data_points JSON NOT NULL,
    resolution INT DEFAULT 1,
    data_length INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (activity_id) REFERENCES strava_activities(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_stream (activity_id, stream_type),
    INDEX idx_activity_streams_activity (activity_id),
    INDEX idx_activity_streams_user (user_id),
    INDEX idx_activity_streams_type (stream_type)
);
