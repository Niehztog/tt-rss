ALTER TABLE ttrss_scheduled_tasks ADD COLUMN owner_uid integer DEFAULT NULL;
ALTER TABLE ttrss_scheduled_tasks ADD COLUMN last_cron_expression varchar(250);

UPDATE ttrss_scheduled_tasks SET last_cron_expression = '';

ALTER TABLE ttrss_scheduled_tasks MODIFY COLUMN last_cron_expression varchar(250) NOT NULL;

ALTER TABLE ttrss_scheduled_tasks ADD FOREIGN KEY (owner_uid) REFERENCES ttrss_users(id) ON DELETE CASCADE;

DROP FUNCTION IF EXISTS SUBSTRING_FOR_DATE;
CREATE FUNCTION SUBSTRING_FOR_DATE(ts DATETIME, pos INT, len INT) RETURNS TEXT DETERMINISTIC RETURN SUBSTRING(CAST(ts AS CHAR), pos, len);
