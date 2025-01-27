DELIMITER $$
CREATE OR REPLACE FUNCTION 'CASEMGNT_IS_PRIMARYKEY'('pinTableName' VARCHAR(255), 'pinColumnName' VARCHAR(255)) RETURNS tinyint(1)
BEGIN
declare val boolean;
select EXISTS (SELECT ku.TABLE_NAME,ku.COLUMN_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS tc INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS ku ON tc.CONSTRAINT_TYPE = 'PRIMARY KEY' 
 AND tc.CONSTRAINT_NAME = ku.CONSTRAINT_NAME group by ku.TABLE_NAME, ku.COLUMN_NAME having ku.TABLE_NAME=pinTableName and ku.COLUMN_NAME=pinColumnName) as val into val;
return val;
END$$
DELIMITER ;