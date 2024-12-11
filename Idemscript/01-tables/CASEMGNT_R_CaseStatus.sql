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