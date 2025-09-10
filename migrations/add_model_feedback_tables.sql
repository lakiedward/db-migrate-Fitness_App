-- Creare tabel pentru feedback model
CREATE TABLE IF NOT EXISTS model_feedback (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    actual_ftp FLOAT NOT NULL,
    predicted_ftp FLOAT NOT NULL,
    error FLOAT NOT NULL,
    error_pct FLOAT NOT NULL,
    timestamp DATETIME NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    INDEX idx_user_timestamp (user_id, timestamp)
);

-- Creare tabel pentru calibrare utilizator
CREATE TABLE IF NOT EXISTS user_calibration (
    user_id INT PRIMARY KEY,
    tss_threshold FLOAT NOT NULL DEFAULT 300,
    decay_rate FLOAT NOT NULL DEFAULT 0.005,
    maintenance_factor FLOAT NOT NULL DEFAULT 0.5,
    last_updated DATETIME NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Adăugare index pentru performanță
-- Notă: Indexurile sunt create direct în CREATE TABLE de mai sus
-- pentru a evita probleme cu DROP INDEX 