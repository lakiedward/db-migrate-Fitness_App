-- Adaugă câmpuri pentru legătura mai clară cu planul
ALTER TABLE app_workouts 
ADD COLUMN planned_workout_id INT DEFAULT NULL COMMENT 'Direct reference to the specific planned workout',
ADD COLUMN is_planned BOOLEAN DEFAULT FALSE COMMENT 'Whether this workout was from a plan',
ADD COLUMN planned_tss FLOAT DEFAULT NULL COMMENT 'TSS planned for this workout',
ADD COLUMN actual_tss FLOAT DEFAULT NULL COMMENT 'TSS actually achieved',
ADD COLUMN plan_version INT DEFAULT 1 COMMENT 'Version of the plan when workout was executed',
ADD COLUMN execution_date DATE DEFAULT NULL COMMENT 'Date when workout was supposed to be executed';

-- Indexuri pentru performanță
CREATE INDEX idx_planned_workout ON app_workouts (planned_workout_id, is_planned);
CREATE INDEX idx_execution_date ON app_workouts (execution_date);
CREATE INDEX idx_tss_comparison ON app_workouts (planned_tss, actual_tss);

-- Adaugă constraint pentru consistența datelor
ALTER TABLE app_workouts 
ADD CONSTRAINT chk_planned_consistency 
CHECK (
    (planned_workout_id IS NOT NULL AND is_planned = TRUE) OR 
    (planned_workout_id IS NULL AND is_planned = FALSE)
);

-- Adaugă constraint pentru TSS pozitiv
ALTER TABLE app_workouts 
ADD CONSTRAINT chk_positive_tss 
CHECK (planned_tss >= 0 AND actual_tss >= 0);