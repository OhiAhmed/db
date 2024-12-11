DELIMITER $$
CREATE OR REPLACE PROCEDURE 'CASEMGNT_SP_LockAssignment' (IN 'input' VARCHAR(255), IN 'username' VARCHAR(255), OUT 'caseId' INT) MODIFIES SQL DATA COMMENT 'Locks the single caseId parram passed with the username, input param should include an array of caseIds to loop through e.g. toJson({caseId: v_caseIds})' BEGIN
	--Declare counter variable for iterating through array of Case ID
	DECLARE counter INT DEFAULT 0
 	-- Declare Locked Assignment Error Handler and Initialize it to 0
	DECLARE caseAlreadyAssignedError INT DEFAULT 0;
	--Store length of Case ID and this will be used for looping in next steps
	DECLARE v_caseInstanceCount INT UNSIGNED
		DEFAULT JSON_LENGTH(JSON_QUERY(input, '$.caseId'));
	--Declare duplicate handler
	DECLARE CONTINUE HANDLER
		FOR SQLEXCEPTION
		SET caseAlreadyAssignedError = 1;
	caseInstanceLoop:WHILE (counter < v_caseInstanceCount) DO
		--Try inserting into Lock Assignment technical table
		INSERT INTO 'CASEMGNT_LockedAssginemnt'(
			'caseId',
			'userId',
			'createdBy',
			'createdDate',
			'updatedBy',
			'updatedDate'
		)
		VALUES(
			JSON VALUE(input, CONCAT('$.caseId[',counter,']')),
		  	username,
			'SYSTEM',
			UTC_TIMESTAMP(),
			'SYSTEM',
			UTC_TIMESTAMP()
		);
		--If no error found, it means the Locked Asignment is successful so return the Case Id
		IF caseAlreadyAssignedError = 0 THEN
			SELECT JSON_VALUE(input,CONCAT('$.caseId[',counter,']')) INTO caseId;
			LEAVE caseInstanceLoop;
		END IF;
		--If no Locked Case is assigned, it means the Locked Assignment is unsuccessful so update caseId with NULL and return the same
		IF counter + 1 = v_caseInstanceCount THEN
			SELECT NULL into caseId;
		END IF;
		SET caseAlreadyAssignedError = 0;
		SET counter = counter + 1;
	END WHILE caseInstanceLoop;
END$$
DELIMITER ;