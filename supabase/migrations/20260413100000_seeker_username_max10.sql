-- Reduce username max length from 50 to 10 characters
ALTER TABLE seeker_profiles ALTER COLUMN username TYPE VARCHAR(10);
