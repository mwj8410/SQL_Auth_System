DROP TABLE IF EXISTS auth_credentials;
CREATE TABLE auth_credentials (
	login_credential_id int(11) NOT NULL AUTO_INCREMENT,
	account_id int(11) NOT NULL,
	indicator_credential varchar(256) NOT NULL,
	salt varchar(50) NOT NULL,
	pass_key varchar(128) NOT NULL,
	created_timestamp date NOT NULL,
	created_by int(11) NOT NULL,
	last_activity date NOT NULL,
	is_active tinyint(1) NOT NULL DEFAULT '1',
	PRIMARY KEY (login_credential_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;