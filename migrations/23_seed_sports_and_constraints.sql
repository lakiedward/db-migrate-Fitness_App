-- Ensure sports table exists and is populated with baseline values
CREATE TABLE IF NOT EXISTS sports (
  id INT NOT NULL AUTO_INCREMENT,
  name VARCHAR(50) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Seed baseline sports (idempotent)
INSERT INTO sports (id, name) VALUES
  (1,'Running'),
  (2,'Cycling'),
  (3,'Swimming'),
  (4,'Weight Training')
ON DUPLICATE KEY UPDATE name = VALUES(name);

-- Ensure unique constraint on user_sports pairs to avoid duplicates
ALTER TABLE user_sports
  ADD UNIQUE KEY uq_user_sport (user_id, sport_id);
