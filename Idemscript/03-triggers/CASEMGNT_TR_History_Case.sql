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
	