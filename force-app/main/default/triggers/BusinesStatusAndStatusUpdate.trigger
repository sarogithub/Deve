/* 
Name          : BusinesStatusAndStatusUpdate
Description   : Update Receive Document , Receive & Track Credit Balance, Contact Provider, Confirm Credit Balance,Verify Provider Billing Issues And Create a New Case
Created By    : OrbitTeam_Soundar
Created Date  : 08/11/2017 
*/

trigger BusinesStatusAndStatusUpdate on Case_Activity__c (After Update) {
    Set<Id> caseId = New Set<Id>();
    List<Case_Activity__c> casActList = New List<Case_Activity__c>();
    List<Case_Activity__c> Up_casActList = New List<Case_Activity__c>();
    Set<Id> OwnerId1 = New Set<Id>();

    Id creditbalreportId = Schema.SObjectType.Case_Activity__c.getRecordTypeInfosByName().get('Receive & Track Credit Balance').getRecordTypeId();
    string ownerId =''; 
    For(Case_Activity__c ca : Trigger.New){
        If(ca.Case__c != Null && ca.RecordtypeId == creditbalreportId && ca.Activity_Business_Status__c == 'Credit Balance Reported'){
            ownerId  = ca.Case__r.OwnerId;
            caseId.add(ca.Case__c);
            OwnerId1.add(ca.CreatedById);
        }
    }
    Id receiveDocId = Schema.SObjectType.Case_Activity__c.getRecordTypeInfosByName().get('Receive Document').getRecordTypeId();
    Id ContProviderId = Schema.SObjectType.Case_Activity__c.getRecordTypeInfosByName().get('Contact Provider').getRecordTypeId();
    Id ConCredBalId = Schema.SObjectType.Case_Activity__c.getRecordTypeInfosByName().get('Confirm Credit Balance').getRecordTypeId();
    Id BillIssueId = Schema.SObjectType.Case_Activity__c.getRecordTypeInfosByName().get('Verify Provider Billing Issues').getRecordTypeId();
    
    list<id> st_RecTyId = new list<id>();
    st_RecTyId.add(creditbalreportId);
    st_RecTyId.add(receiveDocId);
    st_RecTyId.add(ContProviderId);
    st_RecTyId.add(ConCredBalId);
    st_RecTyId.add(BillIssueId);
    
    List<Case_Activity__c> caActList = [Select id,Name, Case__c,Activity_Business_Status__c,Status__c  from Case_Activity__c Where Case__c  =:CaseId AND RecordTypeId IN: st_RecTyId];
    System.debug('Case Activity List |  ' + caActList);
    for(Case_Activity__c cAct : caActList){
        If(cAct.Activity_Business_Status__c != 'Activity Not Applicable'){
            cAct.Activity_Business_Status__c = 'Activity Not Applicable';
        }
        if(cAct.Status__c != 'Completed'){
            cAct.Status__c = 'Completed';
        }
        Up_casActList.add(cAct);
    }
    
    If(Up_casActList.size() > 0){
        Update Up_casActList;
        Case cs = new Case();
        cs.Case_Name__c= 'Provider Audit - Onsite';
        cs.Type='Provider Audit-Onsite';
        IF(UserInfo.getUserName() != Null){
            cs.OwnerId = UserInfo.getUserId();
        }
        insert cs;
    }
    
}