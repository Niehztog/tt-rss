CREATE TABLE ttrss_scheduled_tasks (
	id INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
	task_name varchar(250) NOT NULL UNIQUE,
	last_duration integer NOT NULL,
	last_rc integer NOT NULL,
	last_run datetime NOT NULL DEFAULT CURRENT_TIMESTAMP) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;
