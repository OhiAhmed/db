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