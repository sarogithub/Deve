@IsTest    
Public Class CaseTriggerTest{

    public Static testMethod void CaseTriggerTest(){    
        RecordType r = [select id,Name from RecordType where SobjectType='Account' and Name='Member'];
        Account a=new Account(lastname='Test Account',RecordtypeId=r.Id);
        insert a;
        
        //Insert record Type
        RecordType rec = New RecordType();
        rec.name = 'Claim';
        
        //Inser Case
        Case cs = new Case();
        cs.Case_Name__c = 'Test Case';
        cs.type='Provider Audit New';
        insert cs;
        
        List<Case_Activity__c> csActivity=[SELECT ID from Case_Activity__c where Case__c=:cs.Id];
        system.assertEquals(6,csActivity.size());
        
        csActivity=[SELECT ID from Case_Activity__c where Case__c=:cs.Id and name='Perform Review'];
        csActivity[0].status__c='Completed';
        csActivity[0].Activity_Business_Status__c='Need Further Review';
        update csActivity[0];
        
        Case_Activity__c c=new Case_Activity__c(name='Schedule Audit',case__c=cs.Id,Activity_Start_Date__c=system.today());
        insert c;
        
        csActivity=[SELECT ID from Case_Activity__c where Case__c=:cs.Id and name='Contact Provider'];
        csActivity[0].status__c='Completed';
        csActivity[0].Activity_Business_Status__c='Mutually Agreed';
        update csActivity[0];
    }
    
    public Static testMethod void BusinesStatusAndStatusUpdateTest(){    
        RecordType r = [select id,Name from RecordType where SobjectType='Account' and Name='Member'];
        Account a=new Account(lastname='Test Account',RecordtypeId=r.Id);
        insert a;
        
        Id creditbalreportId = Schema.SObjectType.Case_Activity__c.getRecordTypeInfosByName().get('Receive & Track Credit Balance').getRecordTypeId();
        
        //Inser Case
        Case cs = new Case();
        cs.Case_Name__c = 'Test Case';
        cs.type='Provider Audit-Onsite';
        insert cs;
        
        Case_Activity__c c=new Case_Activity__c(recordTypeId=creditbalreportId,name='Schedule Audit',case__c=cs.Id,Activity_Start_Date__c=system.today(),Activity_Business_Status__c='Credit Balance Reported');
        insert c;
        update c;
        
        superSort.TestCoverage();
    }
}