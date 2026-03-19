SET foreign_key_checks = 0;

DROP TABLE IF EXISTS ttrss_scheduled_tasks;
DROP TABLE IF EXISTS ttrss_error_log;
DROP TABLE IF EXISTS ttrss_plugin_storage;
DROP TABLE IF EXISTS ttrss_linked_feeds;
DROP TABLE IF EXISTS ttrss_linked_instances;
DROP TABLE IF EXISTS ttrss_access_keys;
DROP TABLE IF EXISTS ttrss_user_labels2;
DROP TABLE IF EXISTS ttrss_labels2;
DROP TABLE IF EXISTS ttrss_feedbrowser_cache;
DROP TABLE IF EXISTS ttrss_labels;
DROP TABLE IF EXISTS ttrss_filters2_rules;
DROP TABLE IF EXISTS ttrss_filters2_actions;
DROP TABLE IF EXISTS ttrss_filters2;
DROP TABLE IF EXISTS ttrss_filters;
DROP TABLE IF EXISTS ttrss_filter_types;
DROP TABLE IF EXISTS ttrss_filter_actions;
DROP TABLE IF EXISTS ttrss_user_prefs;
DROP TABLE IF EXISTS ttrss_user_prefs2;
DROP TABLE IF EXISTS ttrss_prefs;
DROP TABLE IF EXISTS ttrss_prefs_types;
DROP TABLE IF EXISTS ttrss_prefs_sections;
DROP TABLE IF EXISTS ttrss_tags;
DROP TABLE IF EXISTS ttrss_enclosures;
DROP TABLE IF EXISTS ttrss_settings_profiles;
DROP TABLE IF EXISTS ttrss_entry_comments;
DROP TABLE IF EXISTS ttrss_user_entries;
DROP TABLE IF EXISTS ttrss_entries;
DROP TABLE IF EXISTS ttrss_scheduled_updates;
DROP TABLE IF EXISTS ttrss_counters_cache;
DROP TABLE IF EXISTS ttrss_cat_counters_cache;
DROP TABLE IF EXISTS ttrss_archived_feeds;
DROP TABLE IF EXISTS ttrss_feeds;
DROP TABLE IF EXISTS ttrss_feed_categories;
DROP TABLE IF EXISTS ttrss_app_passwords;
DROP TABLE IF EXISTS ttrss_users;
DROP TABLE IF EXISTS ttrss_themes;
DROP TABLE IF EXISTS ttrss_sessions;

DROP FUNCTION IF EXISTS SUBSTRING_FOR_DATE;

SET foreign_key_checks = 1;

CREATE FUNCTION SUBSTRING_FOR_DATE(ts DATETIME, pos INT, len INT)
	RETURNS TEXT DETERMINISTIC RETURN SUBSTRING(CAST(ts AS CHAR), pos, len);

CREATE TABLE ttrss_users (id INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
	login varchar(120) NOT NULL UNIQUE,
	pwd_hash varchar(250) NOT NULL,
	last_login datetime DEFAULT NULL,
	access_level integer NOT NULL DEFAULT 0,
	email varchar(250) NOT NULL DEFAULT '',
	full_name varchar(250) NOT NULL DEFAULT '',
	email_digest TINYINT(1) NOT NULL DEFAULT 0,
	last_digest_sent datetime DEFAULT NULL,
	salt varchar(250) NOT NULL DEFAULT '',
	twitter_oauth longtext DEFAULT NULL,
	otp_enabled TINYINT(1) NOT NULL DEFAULT 0,
	otp_secret varchar(250) DEFAULT NULL,
	resetpass_token varchar(250) DEFAULT NULL,
	last_auth_attempt datetime DEFAULT NULL,
	created datetime DEFAULT NULL) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;

INSERT INTO ttrss_users (login,pwd_hash,access_level) VALUES ('admin',
	'SHA1:5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', 10);

CREATE TABLE ttrss_app_passwords (id INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
	title varchar(250) NOT NULL,
	pwd_hash longtext NOT NULL,
	service varchar(100) NOT NULL,
	created datetime NOT NULL,
	last_used datetime DEFAULT NULL,
	owner_uid integer NOT NULL,
	FOREIGN KEY (owner_uid) REFERENCES ttrss_users(id) ON DELETE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;

CREATE TABLE ttrss_feed_categories (id INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
	owner_uid integer NOT NULL,
	collapsed TINYINT(1) NOT NULL DEFAULT 0,
	order_id integer NOT NULL DEFAULT 0,
	view_settings varchar(250) NOT NULL DEFAULT '',
	parent_cat integer DEFAULT NULL,
	title varchar(200) NOT NULL,
	FOREIGN KEY (owner_uid) REFERENCES ttrss_users(id) ON DELETE CASCADE,
	FOREIGN KEY (parent_cat) REFERENCES ttrss_feed_categories(id) ON DELETE SET NULL) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;

CREATE TABLE ttrss_feeds (id INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
	owner_uid integer NOT NULL,
	title varchar(200) NOT NULL,
	cat_id integer DEFAULT NULL,
	feed_url longtext NOT NULL,
	icon_url varchar(250) NOT NULL DEFAULT '',
	update_interval integer NOT NULL DEFAULT 0,
	purge_interval integer NOT NULL DEFAULT 0,
	last_updated datetime DEFAULT NULL,
	last_unconditional datetime DEFAULT NULL,
	last_error longtext NOT NULL DEFAULT '',
	last_modified longtext NOT NULL DEFAULT '',
	favicon_avg_color varchar(11) DEFAULT NULL,
	favicon_is_custom TINYINT(1) DEFAULT NULL,
	site_url varchar(250) NOT NULL DEFAULT '',
	auth_login varchar(250) NOT NULL DEFAULT '',
	parent_feed integer DEFAULT NULL,
	private TINYINT(1) NOT NULL DEFAULT 0,
	auth_pass text NOT NULL DEFAULT '',
	hidden TINYINT(1) NOT NULL DEFAULT 0,
	include_in_digest TINYINT(1) NOT NULL DEFAULT 1,
	rtl_content TINYINT(1) NOT NULL DEFAULT 0,
	cache_images TINYINT(1) NOT NULL DEFAULT 0,
	hide_images TINYINT(1) NOT NULL DEFAULT 0,
	cache_content TINYINT(1) NOT NULL DEFAULT 0,
	last_viewed datetime DEFAULT NULL,
	last_update_started datetime DEFAULT NULL,
	last_successful_update datetime DEFAULT NULL,
	update_method integer NOT NULL DEFAULT 0,
	always_display_enclosures TINYINT(1) NOT NULL DEFAULT 0,
	order_id integer NOT NULL DEFAULT 0,
	mark_unread_on_update TINYINT(1) NOT NULL DEFAULT 0,
	update_on_checksum_change TINYINT(1) NOT NULL DEFAULT 0,
	strip_images TINYINT(1) NOT NULL DEFAULT 0,
	view_settings varchar(250) NOT NULL DEFAULT '',
	pubsub_state integer NOT NULL DEFAULT 0,
	favicon_last_checked datetime DEFAULT NULL,
	feed_language varchar(100) NOT NULL DEFAULT '',
	auth_pass_encrypted TINYINT(1) NOT NULL DEFAULT 0,
	UNIQUE KEY ttrss_feeds_url_owner (feed_url(255), owner_uid),
	FOREIGN KEY (owner_uid) REFERENCES ttrss_users(id) ON DELETE CASCADE,
	FOREIGN KEY (cat_id) REFERENCES ttrss_feed_categories(id) ON DELETE SET NULL,
	FOREIGN KEY (parent_feed) REFERENCES ttrss_feeds(id) ON DELETE SET NULL) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;

CREATE INDEX ttrss_feeds_owner_uid_index ON ttrss_feeds(owner_uid);
CREATE INDEX ttrss_feeds_cat_id_idx ON ttrss_feeds(cat_id);

CREATE TABLE ttrss_archived_feeds (id integer NOT NULL PRIMARY KEY,
	owner_uid integer NOT NULL,
	created datetime NOT NULL,
	title varchar(200) NOT NULL,
	feed_url longtext NOT NULL,
	site_url varchar(250) NOT NULL DEFAULT '',
	FOREIGN KEY (owner_uid) REFERENCES ttrss_users(id) ON DELETE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;

CREATE TABLE ttrss_counters_cache (
	feed_id integer NOT NULL,
	owner_uid integer NOT NULL,
	updated datetime NOT NULL,
	value integer NOT NULL DEFAULT 0,
	FOREIGN KEY (owner_uid) REFERENCES ttrss_users(id) ON DELETE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;

CREATE INDEX ttrss_counters_cache_feed_id_idx ON ttrss_counters_cache(feed_id);
CREATE INDEX ttrss_counters_cache_owner_uid_idx ON ttrss_counters_cache(owner_uid);
CREATE INDEX ttrss_counters_cache_value_idx ON ttrss_counters_cache(value);

CREATE TABLE ttrss_cat_counters_cache (
	feed_id integer NOT NULL,
	owner_uid integer NOT NULL,
	updated datetime NOT NULL,
	value integer NOT NULL DEFAULT 0,
	FOREIGN KEY (owner_uid) REFERENCES ttrss_users(id) ON DELETE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;

CREATE INDEX ttrss_cat_counters_cache_owner_uid_idx ON ttrss_cat_counters_cache(owner_uid);

CREATE TABLE ttrss_entries (id INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
	title longtext NOT NULL,
	guid longtext NOT NULL,
	link longtext NOT NULL,
	updated datetime NOT NULL,
	content longtext NOT NULL,
	content_hash varchar(250) NOT NULL,
	cached_content longtext,
	no_orig_date TINYINT(1) NOT NULL DEFAULT 0,
	date_entered datetime NOT NULL,
	date_updated datetime NOT NULL,
	num_comments integer NOT NULL DEFAULT 0,
	comments varchar(250) NOT NULL DEFAULT '',
	plugin_data longtext,
	lang varchar(2),
	author varchar(250) NOT NULL DEFAULT '',
	UNIQUE KEY ttrss_entries_guid (guid(191))) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;

CREATE INDEX ttrss_entries_date_entered_index ON ttrss_entries(date_entered);
CREATE INDEX ttrss_entries_updated_idx ON ttrss_entries(updated);
CREATE FULLTEXT INDEX ttrss_entries_title_ft ON ttrss_entries(title);
CREATE FULLTEXT INDEX ttrss_entries_title_content_ft ON ttrss_entries(title, content);

CREATE TABLE ttrss_user_entries (
	int_id INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
	ref_id integer NOT NULL,
	uuid varchar(200) NOT NULL,
	feed_id int DEFAULT NULL,
	orig_feed_id integer DEFAULT NULL,
	owner_uid integer NOT NULL,
	marked TINYINT(1) NOT NULL DEFAULT 0,
	published TINYINT(1) NOT NULL DEFAULT 0,
	tag_cache longtext NOT NULL,
	label_cache longtext NOT NULL,
	last_read datetime,
	score int NOT NULL DEFAULT 0,
	last_marked datetime,
	last_published datetime,
	note longtext,
	unread TINYINT(1) NOT NULL DEFAULT 1,
	FOREIGN KEY (ref_id) REFERENCES ttrss_entries(id) ON DELETE CASCADE,
	FOREIGN KEY (feed_id) REFERENCES ttrss_feeds(id) ON DELETE CASCADE,
	FOREIGN KEY (orig_feed_id) REFERENCES ttrss_archived_feeds(id) ON DELETE SET NULL,
	FOREIGN KEY (owner_uid) REFERENCES ttrss_users(id) ON DELETE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;

CREATE INDEX ttrss_user_entries_owner_uid_index ON ttrss_user_entries(owner_uid);
CREATE INDEX ttrss_user_entries_ref_id_index ON ttrss_user_entries(ref_id);
CREATE INDEX ttrss_user_entries_feed_id ON ttrss_user_entries(feed_id);
CREATE INDEX ttrss_user_entries_unread_idx ON ttrss_user_entries(unread);

CREATE TABLE ttrss_entry_comments (id INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
	ref_id integer NOT NULL,
	owner_uid integer NOT NULL,
	private TINYINT(1) NOT NULL DEFAULT 0,
	date_entered datetime NOT NULL,
	FOREIGN KEY (ref_id) REFERENCES ttrss_entries(id) ON DELETE CASCADE,
	FOREIGN KEY (owner_uid) REFERENCES ttrss_users(id) ON DELETE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;

CREATE INDEX ttrss_entry_comments_ref_id_index ON ttrss_entry_comments(ref_id);

CREATE TABLE ttrss_filter_types (id integer NOT NULL PRIMARY KEY,
	name varchar(120) UNIQUE NOT NULL,
	description varchar(250) NOT NULL UNIQUE) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;

INSERT INTO ttrss_filter_types (id,name,description) VALUES (1, 'title', 'Title');
INSERT INTO ttrss_filter_types (id,name,description) VALUES (2, 'content', 'Content');
INSERT INTO ttrss_filter_types (id,name,description) VALUES (3, 'both', 'Title or Content');
INSERT INTO ttrss_filter_types (id,name,description) VALUES (4, 'link', 'Link');
INSERT INTO ttrss_filter_types (id,name,description) VALUES (5, 'date', 'Article Date');
INSERT INTO ttrss_filter_types (id,name,description) VALUES (6, 'author', 'Author');
INSERT INTO ttrss_filter_types (id,name,description) VALUES (7, 'tag', 'Article Tags');

CREATE TABLE ttrss_filter_actions (id integer NOT NULL PRIMARY KEY,
	name varchar(120) UNIQUE NOT NULL,
	description varchar(250) NOT NULL UNIQUE) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;

INSERT INTO ttrss_filter_actions (id,name,description) VALUES (1, 'filter', 'Delete article');
INSERT INTO ttrss_filter_actions (id,name,description) VALUES (2, 'catchup', 'Mark as read');
INSERT INTO ttrss_filter_actions (id,name,description) VALUES (3, 'mark', 'Set starred');
INSERT INTO ttrss_filter_actions (id,name,description) VALUES (4, 'tag', 'Assign tags');
INSERT INTO ttrss_filter_actions (id,name,description) VALUES (5, 'publish', 'Publish article');
INSERT INTO ttrss_filter_actions (id,name,description) VALUES (6, 'score', 'Modify score');
INSERT INTO ttrss_filter_actions (id,name,description) VALUES (7, 'label', 'Assign label');
INSERT INTO ttrss_filter_actions (id,name,description) VALUES (8, 'stop', 'Stop / Do nothing');
INSERT INTO ttrss_filter_actions (id,name,description) VALUES (9, 'plugin', 'Invoke plugin');
INSERT INTO ttrss_filter_actions (id,name,description) VALUES (10, 'ignore-tag', 'Ignore tags');

CREATE TABLE ttrss_filters2 (id INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
	owner_uid integer NOT NULL,
	match_any_rule TINYINT(1) NOT NULL DEFAULT 0,
	inverse TINYINT(1) NOT NULL DEFAULT 0,
	title varchar(250) NOT NULL DEFAULT '',
	order_id integer NOT NULL DEFAULT 0,
	last_triggered datetime DEFAULT NULL,
	enabled TINYINT(1) NOT NULL DEFAULT 1,
	FOREIGN KEY (owner_uid) REFERENCES ttrss_users(id) ON DELETE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;

CREATE TABLE ttrss_filters2_rules (id INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
	filter_id integer NOT NULL,
	reg_exp longtext NOT NULL,
	inverse TINYINT(1) NOT NULL DEFAULT 0,
	filter_type integer NOT NULL,
	feed_id integer DEFAULT NULL,
	cat_id integer DEFAULT NULL,
	match_on longtext,
	cat_filter TINYINT(1) NOT NULL DEFAULT 0,
	FOREIGN KEY (filter_id) REFERENCES ttrss_filters2(id) ON DELETE CASCADE,
	FOREIGN KEY (filter_type) REFERENCES ttrss_filter_types(id),
	FOREIGN KEY (feed_id) REFERENCES ttrss_feeds(id) ON DELETE CASCADE,
	FOREIGN KEY (cat_id) REFERENCES ttrss_feed_categories(id) ON DELETE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;

CREATE TABLE ttrss_filters2_actions (id INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
	filter_id integer NOT NULL,
	action_id integer NOT NULL DEFAULT 1,
	action_param varchar(250) NOT NULL DEFAULT '',
	FOREIGN KEY (filter_id) REFERENCES ttrss_filters2(id) ON DELETE CASCADE,
	FOREIGN KEY (action_id) REFERENCES ttrss_filter_actions(id) ON DELETE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;

CREATE TABLE ttrss_tags (id INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
	tag_name varchar(250) NOT NULL,
	owner_uid integer NOT NULL,
	post_int_id integer NOT NULL,
	FOREIGN KEY (owner_uid) REFERENCES ttrss_users(id) ON DELETE CASCADE,
	FOREIGN KEY (post_int_id) REFERENCES ttrss_user_entries(int_id) ON DELETE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;

CREATE INDEX ttrss_tags_owner_uid_index ON ttrss_tags(owner_uid);
CREATE INDEX ttrss_tags_post_int_id_idx ON ttrss_tags(post_int_id);

CREATE TABLE ttrss_enclosures (id INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
	content_url longtext NOT NULL,
	content_type varchar(250) NOT NULL,
	title longtext NOT NULL,
	duration longtext NOT NULL,
	width integer NOT NULL DEFAULT 0,
	height integer NOT NULL DEFAULT 0,
	post_id integer NOT NULL,
	FOREIGN KEY (post_id) REFERENCES ttrss_entries(id) ON DELETE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;

CREATE INDEX ttrss_enclosures_post_id_idx ON ttrss_enclosures(post_id);

CREATE TABLE ttrss_settings_profiles (id INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
	title varchar(250) NOT NULL,
	owner_uid integer NOT NULL,
	FOREIGN KEY (owner_uid) REFERENCES ttrss_users(id) ON DELETE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;

CREATE TABLE ttrss_prefs_types (id integer NOT NULL PRIMARY KEY,
	type_name varchar(100) NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;

CREATE TABLE ttrss_prefs_sections (id integer NOT NULL PRIMARY KEY,
	order_id integer NOT NULL,
	section_name varchar(100) NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;

CREATE TABLE ttrss_prefs (pref_name varchar(250) NOT NULL PRIMARY KEY,
	type_id integer NOT NULL,
	section_id integer NOT NULL DEFAULT 1,
	access_level integer NOT NULL DEFAULT 0,
	def_value longtext NOT NULL,
	FOREIGN KEY (type_id) REFERENCES ttrss_prefs_types(id),
	FOREIGN KEY (section_id) REFERENCES ttrss_prefs_sections(id)) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;

CREATE TABLE ttrss_user_prefs (
	owner_uid integer NOT NULL,
	pref_name varchar(250) NOT NULL,
	profile integer DEFAULT NULL,
	value longtext NOT NULL,
	FOREIGN KEY (owner_uid) REFERENCES ttrss_users(id) ON DELETE CASCADE,
	FOREIGN KEY (pref_name) REFERENCES ttrss_prefs(pref_name) ON DELETE CASCADE,
	FOREIGN KEY (profile) REFERENCES ttrss_settings_profiles(id) ON DELETE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;

CREATE INDEX ttrss_user_prefs_owner_uid_index ON ttrss_user_prefs(owner_uid);
CREATE INDEX ttrss_user_prefs_pref_name_idx ON ttrss_user_prefs(pref_name);

CREATE TABLE ttrss_user_prefs2 (
	owner_uid integer NOT NULL,
	pref_name varchar(250) NOT NULL,
	profile integer DEFAULT NULL,
	value longtext NOT NULL,
	FOREIGN KEY (owner_uid) REFERENCES ttrss_users(id) ON DELETE CASCADE,
	FOREIGN KEY (profile) REFERENCES ttrss_settings_profiles(id) ON DELETE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;

CREATE INDEX ttrss_user_prefs2_owner_uid_index ON ttrss_user_prefs2(owner_uid);
CREATE INDEX ttrss_user_prefs2_pref_name_idx ON ttrss_user_prefs2(pref_name);
CREATE UNIQUE INDEX ttrss_user_prefs2_composite_idx ON ttrss_user_prefs2(pref_name, owner_uid, profile);

CREATE TABLE ttrss_sessions (id varchar(250) NOT NULL PRIMARY KEY,
	data longtext,
	expire integer NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;

CREATE INDEX ttrss_sessions_expire_index ON ttrss_sessions(expire);

CREATE TABLE ttrss_feedbrowser_cache (
	feed_url longtext NOT NULL,
	title longtext NOT NULL,
	site_url longtext NOT NULL,
	subscribers integer NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;

CREATE TABLE ttrss_labels2 (id INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
	owner_uid integer NOT NULL,
	fg_color varchar(15) NOT NULL DEFAULT '',
	bg_color varchar(15) NOT NULL DEFAULT '',
	caption varchar(250) NOT NULL,
	FOREIGN KEY (owner_uid) REFERENCES ttrss_users(id) ON DELETE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;

CREATE TABLE ttrss_user_labels2 (
	label_id integer NOT NULL,
	article_id integer NOT NULL,
	FOREIGN KEY (label_id) REFERENCES ttrss_labels2(id) ON DELETE CASCADE,
	FOREIGN KEY (article_id) REFERENCES ttrss_entries(id) ON DELETE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;

CREATE INDEX ttrss_user_labels2_article_id_idx ON ttrss_user_labels2(article_id);
CREATE INDEX ttrss_user_labels2_label_id_idx ON ttrss_user_labels2(label_id);

CREATE TABLE ttrss_access_keys (id INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
	access_key varchar(250) NOT NULL,
	feed_id varchar(250) NOT NULL,
	is_cat TINYINT(1) NOT NULL DEFAULT 0,
	owner_uid integer NOT NULL,
	FOREIGN KEY (owner_uid) REFERENCES ttrss_users(id) ON DELETE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;

CREATE TABLE ttrss_linked_instances (id INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
	last_connected datetime NOT NULL,
	last_status_in integer NOT NULL,
	last_status_out integer NOT NULL,
	access_key varchar(250) NOT NULL UNIQUE,
	access_url longtext NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;

CREATE TABLE ttrss_linked_feeds (
	feed_url longtext NOT NULL,
	site_url longtext NOT NULL,
	title longtext NOT NULL,
	created datetime NOT NULL,
	updated datetime NOT NULL,
	instance_id integer NOT NULL,
	subscribers integer NOT NULL,
	FOREIGN KEY (instance_id) REFERENCES ttrss_linked_instances(id) ON DELETE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;

CREATE TABLE ttrss_plugin_storage (
	id INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
	name varchar(100) NOT NULL,
	owner_uid integer NOT NULL,
	content longtext NOT NULL,
	FOREIGN KEY (owner_uid) REFERENCES ttrss_users(id) ON DELETE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;

CREATE TABLE ttrss_error_log (
	id INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
	owner_uid integer DEFAULT NULL,
	errno integer NOT NULL,
	errstr longtext NOT NULL,
	filename longtext NOT NULL,
	lineno integer NOT NULL,
	context longtext NOT NULL,
	created_at datetime NOT NULL,
	FOREIGN KEY (owner_uid) REFERENCES ttrss_users(id) ON DELETE SET NULL) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;

CREATE TABLE ttrss_scheduled_tasks (
	id INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
	task_name varchar(250) NOT NULL UNIQUE,
	last_duration integer NOT NULL,
	last_rc integer NOT NULL,
	last_run datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
	last_cron_expression varchar(250) NOT NULL,
	owner_uid integer DEFAULT NULL,
	FOREIGN KEY (owner_uid) REFERENCES ttrss_users(id) ON DELETE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;
