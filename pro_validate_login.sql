DROP PROCEDURE IF EXISTS validate_login;

DELIMITER //
CREATE PROCEDURE validate_login (
	IN providedName VARCHAR(256),
	IN providedPass VARCHAR(256),
	OUT validated_account_id INT
) BEGIN
	DECLARE credentialID INT;

	SET validated_account_id = (
		SELECT
			CASE
				WHEN (pass_key = SHA2(CONCAT(providedPass, salt), 512))
					THEN
						login_credential_id
				ELSE
					NULL
			END
		FROM
			auth_credentials
		WHERE
			indicator_credential = providedName
			AND
			is_active = 1
	);
	
	IF
		validated_account_id IS NOT NULL
			THEN
				UPDATE
					auth_credentials
				SET
					last_activity = CURDATE()
				WHERE
					login_credential_id = validated_account_id
					AND
					indicator_credential = providedName
					AND
					is_active = 1
				;
				
	END IF;
	
END //