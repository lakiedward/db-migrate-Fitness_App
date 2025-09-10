-- Migration to add processed_oauth_states table for tracking processed OAuth state tokens
CREATE TABLE IF NOT EXISTS processed_oauth_states (
    state_token VARCHAR(500) PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    processed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_processed_at (processed_at)
);