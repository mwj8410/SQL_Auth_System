DROP DATABASE IF EXISTS auth_system;

/* Create the database */
CREATE DATABASE auth_system;

/* Tables */
CREATE TABLE auth_system.auth_credentials (
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

/* Stored Procedures */
DELIMITER //

CREATE PROCEDURE auth_system.validate_login (
	IN providedName VARCHAR(256),
	IN providedPass VARCHAR(256),
	OUT validated_account_id INT
) BEGIN
	DECLARE credential_Id INT;
	
    /* Get the credential entry Id with password descrimination */
	SET credential_Id = (
		SELECT
			login_credential_id
		FROM
			auth_credentials
		WHERE
			indicator_credential = providedName
			AND
			is_active = 1 /* Restrict only to active accounts*/
            AND
            pass_key = SHA2(CONCAT(providedPass, salt), 512) /* validate the password */
    );
	
	IF (credential_Id IS NOT NULL)
		THEN
			UPDATE
				auth_credentials
			SET
				last_activity = CURDATE()
			WHERE
				login_credential_id = credential_Id
				AND
				indicator_credential = providedName
				AND
				is_active = 1
			;
            SET validated_account_id = (
				SELECT
					account_id
				FROM
					auth_credentials
				WHERE
					login_credential_id = credential_Id
					AND
					indicator_credential = providedName
					AND
					is_active = 1
            );
	END IF;
END // /* END Validation Logic */
CREATE PROCEDURE auth_system.validate_login_old (
	IN providedName VARCHAR(256),
	IN providedPass VARCHAR(256),
	OUT validated_account_id INT
) BEGIN
	DECLARE credentialId INT;

	SELECT
		CASE
			WHEN (pass_key = SHA2(CONCAT(providedPass, salt), 512))
				THEN
					(@validated_account_id := account_id )
			ELSE
				(@validated_account_id := NULL )
		END,
        (@validated_indicator_credential := indicator_credential)
	FROM
		auth_credentials
	WHERE
		indicator_credential = providedName
		AND
		is_active = 1
	;
	
	IF
		validated_account_id IS NOT NULL
			THEN
				UPDATE
					auth_credentials
				SET
					last_activity = CURDATE()
				WHERE
					login_credential_id = @validated_indicator_credential
					AND
					indicator_credential = providedName
					AND
					is_active = 1
				;
	END IF;
END //
/* END Validation Logic */

CREATE PROCEDURE auth_system.create_auth_entry (
	IN user_id INT,
	IN user_name VARCHAR( 256 ),
	IN user_password VARCHAR( 100 )
) BEGIN
	DECLARE new_salt VARCHAR( 50 );
	DECLARE generated_hash VARCHAR( 128 );

	SET new_salt = SUBSTRING( MD5( RAND() ) FROM 1 FOR 50 );
	SET generated_hash = SHA2( CONCAT( user_password, new_salt ) , 512 );
	
    /* Inactivate any auth entries that already exist for this account ID */
	UPDATE
		auth_credentials
	SET
		is_active = 0
	WHERE
		account_id = user_id
		AND
		is_active = 1
		AND
		indicator_credential = user_name
		AND
		login_credential_id != 0
	;

	/* Now, create this auth entry. */
	INSERT INTO auth_credentials (
		account_id,
		indicator_credential,
		salt,
		pass_key,
		created_timestamp,
		created_by,
		last_activity,
		is_active
	) VALUE (
		user_id,
		user_name,
		new_salt,
		generated_hash,
		CURDATE(),
		'0',
		CURDATE(),
		'1'
	);
END // /* End Create entry logic */

CREATE PROCEDURE auth_system.disable_account (
	IN user_id INT
) BEGIN
	UPDATE
		auth_credentials
	SET
		is_active = 0
	WHERE
		account_id = 1
        AND
        login_credential_id != 0
	;
END // /* END Disable account */

CREATE PROCEDURE auth_system.log_failed_attempt (
	IN provided_name VARCHAR(256)
) BEGIN
	
	UPDATE
		auth_credentials
	SET			
		failed_attempts = failed_attempts + 1
	WHERE
		indicator_credential = providedName
		AND
		is_active = 1
		AND
		login_credential_id != 0
	;
END // /* END Fail logging */
