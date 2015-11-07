SET @test_user_1_id = 1;
SET @test_user_1_name = 'test_user';
SET @test_user_1_password = 'test_password';
SET @test_user_1_second_password = 'test_password2';
CALL auth_system.create_auth_entry (@test_user_1_id, @test_user_1_name, @test_user_1_password);

SET @test_user_2_id = 2;
SET @test_user_2_name = 'test2_user';
SET @test_user_2_password = 'test2_password';
SET @test_user_2_second_password = 'test2_password2';
CALL auth_system.create_auth_entry (@test_user_2_id, @test_user_2_name, @test_user_2_password);

SET @test_user_3_id = 3;
SET @test_user_3_name = 'test3_user';
SET @test_user_3_password = 'test3_password';
SET @test_user_3_second_password = 'test3_password2';
CALL auth_system.create_auth_entry (@test_user_3_id, @test_user_3_name, @test_user_3_password);

SET @incorrect_password = 'password';

/* Creaate Table for test results */
DROP TABLE IF EXISTS auth_system.test_results;
CREATE TEMPORARY TABLE IF NOT EXISTS auth_system.test_results (
	result varchar(256) NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


/* User can be created and authenticated */
CALL auth_system.validate_login (@test_user_1_name, @test_user_1_password, @userId);
INSERT INTO auth_system.test_results
SELECT CASE WHEN (@userId = @test_user_1_id) THEN NULL ELSE 'User fails to authenticate' END;

/* Authentication can fail with the wrong credentials. */
CALL auth_system.validate_login (@test_user_1_name, @incorrect_password, @userId);
INSERT INTO auth_system.test_results
SELECT CASE WHEN (@userId IS NULL) THEN NULL ELSE 'User authenticates with incorrect password' END;

/* A credentials can be updated for a user. */
CALL auth_system.create_auth_entry (@test_user_1_id, @test_user_1_name, @test_user_1_second_password);
CALL auth_system.validate_login (@test_user_1_name, @test_user_1_password, @userId);
INSERT INTO auth_system.test_results
SELECT CASE WHEN (@userId IS NULL) THEN NULL ELSE 'User continues to Authenticate with old password.' END;

CALL auth_system.validate_login (@test_user_1_name, @test_user_1_second_password, @userId);
INSERT INTO auth_system.test_results
SELECT CASE WHEN (@userId = @test_user_1_id) THEN NULL ELSE 'User fails to Authenticate with new password.' END;

/* Disable Account */
CALL auth_system.disable_account (@test_user_1_id);
CALL auth_system.validate_login (@test_user_1_name, @test_user_1_second_password, @userId);
INSERT INTO auth_system.test_results
SELECT CASE WHEN (@userId IS NULL) THEN NULL ELSE 'User Authenticates after being disabled.' END;

/* Get Test results. */
SELECT * FROM auth_system.test_results WHERE result IS NOT NULL;