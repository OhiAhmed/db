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