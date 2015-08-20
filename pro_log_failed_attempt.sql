DROP PROCEDURE IF EXISTS log_failed_attempt;

DELIMITER //
CREATE PROCEDURE log_failed_attempt (
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
END //