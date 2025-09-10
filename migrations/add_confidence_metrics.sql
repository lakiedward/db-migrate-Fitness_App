-- Adaugă coloana confidence_metrics pentru metrici detaliate de confidență
ALTER TABLE ftp_history
ADD COLUMN confidence_metrics JSON NULL COMMENT 'Detailed confidence metrics from each estimation source';

-- Actualizează comentariile pentru coloanele existente
ALTER TABLE ftp_history
MODIFY COLUMN confidence FLOAT NOT NULL COMMENT 'Overall confidence in the estimate (0-1)',
MODIFY COLUMN method VARCHAR(50) NOT NULL COMMENT 'Estimation method(s) used (e.g., xgboost+fthr_based)',
MODIFY COLUMN notes TEXT NULL COMMENT 'Detailed notes about the estimation process and confidence factors'; 