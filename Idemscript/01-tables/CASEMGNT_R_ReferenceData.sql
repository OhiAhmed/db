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
