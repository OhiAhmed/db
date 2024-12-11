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