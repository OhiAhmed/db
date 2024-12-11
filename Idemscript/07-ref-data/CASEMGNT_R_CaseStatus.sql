TRUNCATE TABLE 'CASEMGNT_R_CaseStatus';

INSERT INTO 'CASEMGNT_R_CaseStatus'('statusId', 'name', 'createdBy', 'createdDate', 'updateBy', 'updatedDate', 'isActive') VALUES
(1, 'New', 'SYSTEM', CURRENT_TIMESTAMP(), 'SYSTEM', CURRENT_TIMESTAMP(), 1),
(2, 'In Progress', 'SYSTEM', CURRENT_TIMESTAMP(), 'SYSTEM', CURRENT_TIMESTAMP(), 1);