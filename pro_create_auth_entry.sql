DROP PROCEDURE IF EXISTS create_auth_entry;

DELIMITER //
CREATE PROCEDURE create_auth_entry (
	IN user_id INT,
	IN user_name VARCHAR( 256 ),
	IN user_password VARCHAR( 100 )
) BEGIN
	DECLARE new_salt VARCHAR( 50 );
	DECLARE generated_hash VARCHAR( 128 );

	SET new_salt = SUBSTRING( MD5( RAND() ) FROM 1 FOR 50 );
	SET generated_hash = SHA2( CONCAT( user_password, new_salt ) , 512 );
	
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
END //