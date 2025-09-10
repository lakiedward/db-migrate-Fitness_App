-- Migration: Add oauth_states table for better state token management
-- This table will store OAuth state tokens with expiration times

CREATE TABLE IF NOT EXISTS oauth_states (
    token VARCHAR(500) PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_expires_at (expires_at),
    INDEX idx_username (username)
);

-- Create processed_states table to track processed tokens
CREATE TABLE IF NOT EXISTS processed_states (
    token VARCHAR(500) PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    processed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_processed_at (processed_at)
);