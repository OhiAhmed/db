-- CASEMGNT Master SQL'n
SET FOREIGN_KEY_CHECKS = 0;
DROP FUNCTION IF EXISTS 'IDEM_FN_UTIL_IS_FIELD_EXISTING';

DELIMITER $$
CREATE FUNCTION 'IDEM_FN_DDL_UTIL_IS_FIELD_EXISTING'(
 'in_tableName' VARCHAR(100),
 'in_fieldName' VARCHAR(100)
) RETURN INT(11) RETURN(
	SELECT COUNT(COLUMN_NAME)
	FROM INFORMATION_SCHEMA.columns
	WHERE TABLE_SCHEMA = "CASEMGNT"
	AND TABLE_NAME = in_tableName	
	AND COLUMN_NAME = in_fieldName
)$$
DELIMITER;

DROP FUNCTION IF EXISTS 'IDEM_FN_DDL_UTIL_IS_CONSTRAINT_EXISTING';

DELIMITER$$
CREATE FUNCTION 'IDEM_FN_DDL_UTIL_IS_CONSTRAINT_EXISTING'(
	'in_tableName' VARCHAR(100),
	'in_constraintName' VARCHAR(100),
	'in_constraintType' VARCHAR(100) -- eg. Foreign key
) RETURN INT(11) RETURN(
	SELECT COUNT(CONSTRAINT_NAME)
	FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
	WHERE TABLE_SCHEMA = "CASEMGNT"
	AND TABLE_NAME = in_tableName	
	AND CONSTRAINT_NAME = in_constraintName
	AND CONSTRAINT_TYPE = in_constraintType
)$$
DELIMITER;


DROP FUNCTION IF EXISTS 'IDEM_FN_DDL_UTIL_IS_INDEX_EXISTING';

DELIMITER$$
CREATE FUNCTION 'IDEM_FN_DDL_UTIL_IS_INDEX_EXISTING'(
	'in_tableName' VARCHAR(100),
	'in_indexName' VARCHAR(100)
) RETURN INT(11) RETURN(
	SELECT COUNT(INDEX_NAME)
	FROM INFORMATION_SCHEMA.STATISTICS
	WHERE TABLE_SCHEMA = "CASEMGNT"
	AND TABLE_NAME = in_tableName	
	AND INDEX_NAME = in_indexName
)$$
DELIMITER;


DROP PROCEDURE IF EXISTS  'IDEM_SP_DDL_UTIL_ADD_FIELD_IF_NOT_EXISTS';

DELIMITER $$
CREATE PROCEDURE 'IDEM_SP_DDL_UTIL_ADD_FIELD_IF_NOT_EXISTS' (IN 'in_tableName' VARCHAR(100), IN 'in_fieldName' VARCHAR(100), IN 'in_fieldDefinition' VARCHAR (500), IN 'in_afterFieldName' VARCHAR(100)) BEGIN
	SET @isFieldThere = IDEM_FN_DDL_UTIL_IS_FIELD_EXISTING(in_tableName, in_fieldName);
        
	IF (@isFieldThere = 0) THEN
		SET @ddl = CONCAT('ALTER TABLE ', in_tableName);
		SET @ddl = CONCAT(@ddl, ' ', 'ADD_COLUMN');
		SET @ddl = CONCAT(@ddl, ' ', in_fieldName);		
		SET @ddl = CONCAT(@ddl, ' ', in_fieldDefinition);
		SET @ddl = CONCAT(@ddl, ' ', 'AFTER');	
		SET @ddl = CONCAT(@ddl, ' ', in_afterFieldName);

		PREPARE stmt FROM @ddl;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
	ELSE
		SET @msg = LEFT(CONCAT("SELECT 'Column ", in_fileName, " on table ", in_tableName, " does not exist - skipping add'"), 128);
		SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = @msg;
	END IF;
END$$
DELIMITER;



DROP PROCEDURE IF EXISTS  'IDEM_SP_DDL_UTIL_DROP_FIELD_IF_EXISTS';

DELIMITER $$
CREATE PROCEDURE 'IDEM_SP_DDL_UTIL_DROP_FIELD_IF_EXISTS' (IN 'in_tableName' VARCHAR(100), IN 'in_fieldName' VARCHAR(100)) BEGIN
	SET @isFieldThere = IDEM_FN_DDL_UTIL_IS_FIELD_EXISTING(in_tableName, in_fieldName);
        
	IF (@isFieldThere = 1) THEN
		SET @ddl = CONCAT('ALTER TABLE ', in_tableName);
		SET @ddl = CONCAT(@ddl, ' ', 'DROP_COLUMN');
		SET @ddl = CONCAT('ALTER TABLE ', in_fieldName);
		
		PREPARE stmt FROM @ddl;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
	ELSE
		SET @msg = LEFT(CONCAT("SELECT 'Column ", in_fileName, " on table ", in_tableName, " does not exist - skipping drop'"), 128);
		SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = @msg;
	END IF;
END$$
DELIMITER;


DROP PROCEDURE IF EXISTS  'IDEM_SP_DDL_UTIL_MODIFY_FIELD_IF_EXISTS';

DELIMITER $$
CREATE PROCEDURE 'IDEM_SP_DDL_UTIL_MODIFY_FIELD_IF_EXISTS' (IN 'in_tableName' VARCHAR(100), IN 'in_fieldName' VARCHAR(100), IN 'in_fieldDefinition' VARCHAR (500), IN 'in_afterFieldName' VARCHAR(100)) BEGIN
	SET @isFieldThere = IDEM_FN_DDL_UTIL_IS_FIELD_EXISTING(in_tableName, in_fieldName);
        
	IF (@isFieldThere = 1) THEN
		SET @ddl = CONCAT('ALTER TABLE ', in_tableName);
		SET @ddl = CONCAT(@ddl, ' ', 'MODIFY_COLUMN');
		SET @ddl = CONCAT('ALTER TABLE ', in_fieldName);
		IF IFNULL(in_afterFieldName, '')<>'' THEN
			SET @ddl = CONCAT(@ddl, ' ', 'AFTER');
			SET @ddl = CONCAT(@ddl, ' ', in_afterFieldName);
		END IF;
		
		PREPARE stmt FROM @ddl;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
	ELSE
		SET @msg = LEFT(CONCAT("SELECT 'Column ", in_fieldName, " on table ", in_tableName, " does not exist - skipping modify'"), 128);
		SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = @msg;
	END IF;
END$$
DELIMITER;


DROP PROCEDURE IF EXISTS 'IDEM_SP_DDL_UTIL_RENAME_FIELD_IF_EXISTS';

DELIMITER $$
CREATE PROCEDURE 'IDEM_SP_DDL_UTIL_RENAME_FIELD_IF_EXISTS'(
	IN 'in_tableName' VARCHAR(100),
	IN 'in_oldFieldName' VARCHAR(100),
	IN 'in_newFieldName' VARCHAR(100),
	IN 'in_newFieldDefinition' VARCHAR(500),
	IN 'in_afterFieldName' VARCHAR(100)
) BEGIN

	SET @isFieldThere = IDEM_FN_DDL_UTIL_IS_FIELD_EXISTING(in_tableName, in_oldFieldName);
	SET @isNewFieldThere = IDEM_FN_DDL_UTIL_IS_FIELD_EXISTING(in_tableName, in_newFieldName);
	
	IF(@isNewFieldThere = 1) THEN
		SET @msg LEFT(CONCAT("SELECT 'Column ", in in_newFieldName, " on table", in_tableName, " exists - skipping rename'", 128));
		SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = @msg;
	ELSE
		IF (@isFieldThere = 1) THEN
			SET @ddl = CONCAT('ALTER TABLE', in_tableName);
			SET @ddl = CONCAT(@ddl, ' ', 'CHANGE');
			SET @ddl = CONCAT(@ddl, ' ', in_oldFieldName);
			SET @ddl = CONCAT(@ddl, ' ', in_newFieldName);
			SET @ddl = CONCAT(@ddl, ' ', in_newFieldDefinition);	
			SET @ddl = CONCAT(@ddl, ' ', 'AFTER');
			SET @ddl = CONCAT(@ddl, ' ', in_afterFieldName);

	     	PREPARE stmt FROM @ddl;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
	ELSE
		SET @msg = LEFT(CONCAT("SELECT 'Column ", in_oldFieldName, " on table ", in_tableName, " does not exist - skipping rename'"), 128);
		SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = @msg;
	END IF;
     END IF;
END$$
DELIMITER;


DROP PROCEDURE IF EXISTS  'IDEM_SP_DDL_UTIL_ADD_CONSTRAINT_IF_NOT_EXISTS';

DELIMITER $$
CREATE PROCEDURE 'IDEM_SP_DDL_UTIL_ADD_CONSTRAINT_IF_NOT_EXISTS' (IN 'in_tableName' VARCHAR(100), IN 'in_constraintName' VARCHAR(100), IN 'in_constraintType' VARCHAR(100), IN 'in_constraintDefinition' VARCHAR (500)) BEGIN
	SET @isConstraintThere = IDEM_FN_DDL_UTIL_IS_CONSTRAINT_EXISTING(in_tableName, in_constraintName, in_constraintType);
        
	IF (@isConstraintThere = 0) THEN
		SET @ddl = CONCAT('ALTER TABLE ', in_tableName);
		SET @ddl = CONCAT(@ddl, ' ', 'ADD_CONSTRAINT');
		SET @ddl = CONCAT(@ddl, ' ', in_constraintName);		
		SET @ddl = CONCAT(@ddl, ' ', in_constraintDefinition);

		PREPARE stmt FROM @ddl;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
	ELSE
		SET @msg = LEFT(CONCAT("SELECT 'Constraint ", in_constraintName, " on table ", in_tableName, " exists - skipping add'"), 128);
		SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = @msg;
	END IF;
END$$
DELIMITER;


DROP PROCEDURE IF EXISTS  'IDEM_SP_DDL_UTIL_DROP_CONSTRAINT_IF_EXISTS';

DELIMITER $$
CREATE PROCEDURE 'IDEM_SP_DDL_UTIL_DROP_CONSTRAINT_IF_EXISTS' (IN 'in_tableName' VARCHAR(100), IN 'in_constraintName' VARCHAR(100), IN 'in_constraintType' VARCHAR(100)) BEGIN
	SET @isConstraintThere = IDEM_FN_DDL_UTIL_IS_CONSTRAINT_EXISTING(in_tableName, in_constraintName, in_constraintType);
        
	IF (@isConstraintThere = 1) THEN
		SET @ddl = CONCAT('ALTER TABLE ', in_tableName);
		SET @ddl = CONCAT(@ddl, ' ', 'DROP');
		SET @ddl = CONCAT(@ddl, ' ', in_constraintType);		
		SET @ddl = CONCAT(@ddl, ' ', in_constraintName);

		PREPARE stmt FROM @ddl;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
	ELSE
		SET @msg = LEFT(CONCAT("SELECT '", in_constraintName, " ", in_constraintName,  " on table ", in_tableName,  " does not exist - skipping drop'"), 128);
		SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = @msg;
	END IF;
END$$
DELIMITER;




DROP PROCEDURE IF EXISTS  'IDEM_SP_DDL_UTIL_ADD_INDEX_IF_NOT_EXISTS';

DELIMITER $$
CREATE PROCEDURE 'IDEM_SP_DDL_UTIL_ADD_CONSTRAINT_IF_NOT_EXISTS' (IN 'in_tableName' VARCHAR(100), IN 'in_indexName' VARCHAR(100), IN 'in_indexColumns' VARCHAR(500)) BEGIN
	SET @isIndexThere = IDEM_FN_DDL_UTIL_IS_INDEX_EXISTING(in_tableName, in_indexName);
        
	IF (@isIndexThere = 0) THEN
		SET @ddl = CONCAT('CREATE INDEX ', in_indexName);
		SET @ddl = CONCAT(@ddl, ' ', 'ON');
		SET @ddl = CONCAT(@ddl, ' ', in_tableName);		
		SET @ddl = CONCAT(@ddl, ' (', in_indexColumns, ')');

		PREPARE stmt FROM @ddl;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
	ELSE
		SET @msg = LEFT(CONCAT("SELECT 'Index ", in_indexName, " on table ", in_tableName, " exists - skipping add'"), 128);
		SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = @msg;
	END IF;
END$$
DELIMITER;
CREATE TABEL IF NOT EXISTS CASEMGNT_Case(
	caseId INTEGER NOT NULL AUTO_INCREMENT,
	statusId INTEGER NOT NULL
	stageId INT(11),
	createdBy VARCHAR(100),
	createdDate TIMESTAMP NOT NULL,
	updatedBy VARCHAR(100),
	updatedDate TIMESTAMP NULL DEFAULT NULL,
	isActive BOOLEAN,
	CONSTRAINT CASEMGNT_R_CaseStatus_pk PRIMARY KEY (statusId)
) COMMENT="This is the central table used for case management";

CALL IDEM_SP_DDL_UTIL_ADD_FIELD_IF_NOT_EXISTS('CASEMGNT_Case', 'currentInvestigationId', 'int(11) NULL', 'stageId');
CREATE TABEL IF NOT EXISTS CASEMGNT_R_CaseStatus(
	'statusId' INTEGER NOT NULL AUTO_INCREMENT,
	'name' VARCHAR(255),
	'createdBy' VARCHAR(100),
	'createdDate' TIMESTAMP,
	'updatedBy' VARCHAR(100),
	'updatedDate' TIMESTAMP,
	'isActive' tinyint(1) DEFAULT NULL,
	PRIMARY KEY ('statusId')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci COMMENT='';
CREATE TABEL IF NOT EXISTS CASEMGNT_R_ReferenceData(
	dataId int(11) NOT NULL AUTO_INCREMENT,
	code varchar(255) DEFULT NULL
	name varchar(100),
	displayName varchar(255),
	displayOrder varcher(255) DEFAULT NULL,
	createdBy VARCHAR(100),
	createdDate TIMESTAMP NOT NULL,
	updatedBy VARCHAR(100),
	updatedDate TIMESTAMP NULL DEFAULT NULL,
	isActive tinyint(1) DEFAULT NULL,
	 PRIMARY KEY (dataId),
	 KEY 'CASEMGNT_R_ReferenceData_Code' ('code') USING BTREE
) COMMENT="This is the general reference table used with multiple entities and the KEY: 'code' will be referenced as Foreign KEY in other tables";
CALL IDEM_SP_UTIL_ADD_CONSTRAINT_IF_NOT_EXISTS('CASEMGNT_Case', 'CASEMGNT_R_CasrStatus_CASEMGNT_FK', 'FOREIGN KEY', 'FOREIGN KEY (caseStatusId) REFERENCES CASEMGNT_R_CaseStatus (statusId) ON DELETE NO ACTION ON UPDATE NO ACTION');
DELIMITER $$
CREATE OR REPLACE TRIGGER 'CASEMGNT_TR_History_Case' AFTER UPDATE 
ON 
	CASEMGNT_Case  FOR EACH ROW
BEGIN
	INSERT INTO CASEMGNT_TR_History_Case(
		caseId,
		satusId
)
VALUES(
	old.caseId,
	old.statusId
);
END$$

DELIMITER $$
CREATE OR REPLACE TRIGGER 'CASEMGNT_TR_History_Case' AFTER INSERT
ON
	CASEMGNT_Case FOR EACH ROW
BEGIN
	INSERT INTO CASEMGNT_TR_History_Case(
		caseId,
		satusId
)
VALUES(
	new.caseId,
	new.statusId
);
END$$
	
DELIMITER $$
CREATE OR REPLACE FUNCTION 'CASEMGNT_IS_PRIMARYKEY'('pinTableName' VARCHAR(255), 'pinColumnName' VARCHAR(255)) RETURNS tinyint(1)
BEGIN
declare val boolean;
select EXISTS (SELECT ku.TABLE_NAME,ku.COLUMN_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS tc INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS ku ON tc.CONSTRAINT_TYPE = 'PRIMARY KEY' 
 AND tc.CONSTRAINT_NAME = ku.CONSTRAINT_NAME group by ku.TABLE_NAME, ku.COLUMN_NAME having ku.TABLE_NAME=pinTableName and ku.COLUMN_NAME=pinColumnName) as val into val;
return val;
END$$
DELIMITER ;
DELIMITER$$
CREATE OR REPLACE FUNCTION 'CASEMGNT_UTIL_CONVERT_DATE_TIME' ('pinDate' VARCHAR(10), 'pinTime', VARCHAR(10)) RETURNS datetime
 RETURN STR_TO_DATE(concat(pinDate,LPAD(pinTime, 4, '0')),'%Y%m%d%H%i')$$
DELIMITER ;
DELIMITER $$
CREATE OR REPLACE DEFINER='CASEMGNT.dsuser'@'%' PROCEDURE 'CASEMGNT_SP_DeleteLockedAssignment' (IN 'entityId' INT(255))
BEGIN
DELETE FROM CASEMGNT_LockedAssignment WHERE caseId = entityId;
END$$
DELIMITER ;
DELIMITER $$
CREATE OR REPLACFE DEFINER='CASEMGNT.duser'@'%' PROCEDURE 'CASEMGNT_SP_GetQuestionResponseStep' (IN 'stepId' VARCHAR(100), IN 'caseId' INT)
	READS SQL DATA
	SQL SECURITY INVOKER
	COMMENT 'Stored procedure for questions & responses by multiple stepIds'
begin

SELECT CIQR.caseInvestigation QuestionResponseId AS reponseId,
 CS.caseStepId As stepId
 CIQ.caseInvestigationQuestionId AS questionId,
 CIQ.name AS questionName,
 CIQR.responseValue AS responseValue,
 CIQR.notApplicable AS notApplicable,
 CIQR.caseId AS caseId,
 CIQ.helpToolTip AS helpToolTip,
 CIQT.name AS questionType,
 CIQS.readOnly AS readOnly,
 CIQS.required AS required,
 CIQ.style AS style,
 CIQ.characterLimit AS characterLimit
 CIQ,maxSelection AS maxSelections,
 CIQ.valueRefKey AS valueREFKey,
 CIQS.sortOrder AS sortOrder
FROM 'CASEMGNT_R_CaseInvestigationQustionStepMapping' CIQS
JOIN 'CASEMGNT_R_CaseInvestigationQuestion CIQ ON CIQ.caseInvestigationQuestionId=CIQ.questionId'
JOIN CASEMGNT_R_CaseInvestigationQuestioType CIQT ON CIQT.caseInvestigationQuestionId=CIQ.questionTypeId
JOIN CASEMGNT_R_CaseSteps CS ON CS.caseStepId=CIQS.stepId
LEFT JOIN CASEMGNT_CaseInvestigationQuestionResponse CIQR ON CIQR.questionId=CIQ.caseInvestigationQuestionId AND CIQR.caseId=caseId AND CIQR.stepID=stepid 
WHERE FIND_IN_SET(CIQS.stepId, stepId)
ORDER BY CIQS.sortOrder ASC;

end$$
DELIMITER ;
DELIMITER $$
CREATE OR REPLACE PROCEDURR 'CASEMGNT_SP_GetSequenceNumber' (IN 'sequenceName'  VARCHAR(100)) begin

	DECLARE EXIT HANDLER FOR SQLEXCEPTION
		BEGIN
			--Get DIAGNOSTICS condiion 1 @p1 = REQUIRED_SQLSTATE, @p2 = MESSAGE_TEXT;
			SELECT 'Sequence Not Found' as message, false as success ;
		END;
		SET @textofstatement = CONCAT('SELECT NEXTVAL(',sequenceName,') as sequence,true as success');
		PREPARE executionstatement FROM @textofstatement;
		EXECUTE executionstatement;
end$$
DELIMITER ;
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
CREATE OR REPLACE ALGORITHM=UNDEFINED SQL SEQURITY DEFINER VIEW 'CASEMGNT_VW_AuditEvent' 
 AS SELECT 'audit'.auditEventId AS 'auditEventId', 'audit'.auditEventTypeId AS 'auditEventTypeId',
 'eventType'.'name' AS 'auditEventTyepName', 'audit'.'description' AS 'description'
FROM('CASEMGNT_AuditEvent' 'audit' left join 'CASEMGNT_R_AuditEventType' 'eventType'
  on('eventType'.'auditEventTypeId' = 'audit'.'auditEventTypeId') );   
TRUNCATE TABLE 'CASEMGNT_R_CaseStatus';

INSERT INTO 'CASEMGNT_R_CaseStatus'('statusId', 'name', 'createdBy', 'createdDate', 'updateBy', 'updatedDate', 'isActive') VALUES
(1, 'New', 'SYSTEM', CURRENT_TIMESTAMP(), 'SYSTEM', CURRENT_TIMESTAMP(), 1),
(2, 'In Progress', 'SYSTEM', CURRENT_TIMESTAMP(), 'SYSTEM', CURRENT_TIMESTAMP(), 1);
CREATE SEQUENCE IF NOT EXISTS 'CASEMGNT_caseIdSequence' START WITH 1 INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775806 CYCLE NOCACHE;
SET FOREIGN_KEY_CHECKS = 1;
-- CASEMGNT Master SQL Build Complete'n
