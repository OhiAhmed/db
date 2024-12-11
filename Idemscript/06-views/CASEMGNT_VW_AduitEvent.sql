CREATE OR REPLACE ALGORITHM=UNDEFINED SQL SEQURITY DEFINER VIEW 'CASEMGNT_VW_AuditEvent' 
 AS SELECT 'audit'.auditEventId AS 'auditEventId', 'audit'.auditEventTypeId AS 'auditEventTypeId',
 'eventType'.'name' AS 'auditEventTyepName', 'audit'.'description' AS 'description'
FROM('CASEMGNT_AuditEvent' 'audit' left join 'CASEMGNT_R_AuditEventType' 'eventType'
  on('eventType'.'auditEventTypeId' = 'audit'.'auditEventTypeId') );   