public inherited sharing class createPrimaryCaseAssociate {
    public static void createPrimaryCaseAssociateRecord(List<Case> triggerNewCaseRecords, Map<Id,Case> triggerOldMapCaseRecords) {
        List<Case_Associate__c> caseAss = new List<Case_Associate__c>();
        Map<Id, Id> caseIdToEntityId = new Map<Id, Id>();
        Set<Id> conId = new Set<Id>();
        Map<Id, Contact> contactIdToCont;

        for(Case ics : triggerNewCaseRecords){
            if(ics.ContactId != null && triggerOldMapCaseRecords.size() <= 0){
                caseIdToEntityId.put(ics.Id, ics.ContactId );
                conId.add(ics.ContactId);
            }else if(triggerOldMapCaseRecords.size() > 0 && 
                triggerOldMapCaseRecords.get(ics.Id).ContactId != ics.ContactId){
                    caseIdToEntityId.put(ics.Id, ics.ContactId);
                    conId.add(ics.ContactId);
                }
        }

        if(conId.size() > 0){
            contactIdToCont = new Map<Id, Contact>([Select Id, AccountId from Contact Where Id IN: conId]);
        }

        if(caseIdToEntityId.size() > 0){
            for(Case_Associate__c caseAssociate : [SELECT Id, Case_Number__c, Entity1__c FROM Case_Associate__c
                WHERE Case_Number__c IN: caseIdToEntityId.keySet() AND 
                Associate_Type__c = 'Primary']){
                if(caseIdToEntityId.containsKey(caseAssociate.Case_Number__c)){
                    if(caseIdToEntityId.get(caseAssociate.Case_Number__c) != caseAssociate.Entity1__c){
                        //caseAssociate.Entity1__c = ;
                    }
                }
            }
        }
    }
}