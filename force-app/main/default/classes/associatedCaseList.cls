public with sharing class associatedCaseList {
    @AuraEnabled
    public static string fetchCaseListAssociated(String caseRecordId){
        List<Case_Associate__c> lstOfCaseAssociate = new List<Case_Associate__c>();
        Map<String, Object> outputMap = new Map<String, Object>();

        try {
            list<string> entityIds = new list<string>();
            for(Case_Associate__c caseAssociate : [SELECT Id, Entity1__c 
                FROM Case_Associate__c 
                WHERE Case_Number__c =: caseRecordId]){
                    entityIds.add(caseAssociate.Entity1__c);
            }

            System.debug('entityIds '+ entityIds);

            if(entityIds.size() > 0){
                for(Case_Associate__c caseAssociate : [SELECT Id, Entity1__r.Id,
                    Entity1__r.Name, Case_Number__r.Id,
                    Case_Number__r.Type, Case_Number__r.CaseNumber, 
                    Case_Number__r.Source__c, Case_Number__r.Origin, 
                    Case_Number__r.Review_Start_Date__c, Case_Number__r.Status, 
                    Case_Number__r.Description, Case_Number__r.Priority, Associate_Type__c 
                    FROM Case_Associate__c 
                    WHERE Entity1__c IN: entityIds
                    AND Case_Number__c <>: caseRecordId]){
                        lstOfCaseAssociate.add(caseAssociate);
                }
            }

            System.debug('lstOfCaseAssociate '+ lstOfCaseAssociate);

            if(lstOfCaseAssociate.size() > 0){
                outputMap.put('status', 'success');
                outputMap.put('caseAssociate', lstOfCaseAssociate);
            }

            System.debug('outputMap '+ outputMap.size());

        } catch (Exception e) {
            outputMap.put('status', 'error');
            throw new AuraHandledException(e.getMessage());
        }

        return JSON.serialize(outputMap);
    }
}
