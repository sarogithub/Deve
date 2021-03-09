/*
Created By : Orbit Team - Soundar
Date       : 11/10/2017 
For        : CaseAssignment
*/

@IsTest    
Public Class caseAssignment_Test{
    public Static testMethod void CaseAssociate(){
        
        RecordType r = [select id,Name from RecordType where SobjectType='Account' and Name='Member'];
        Account a=new Account(lastname='Test Account',RecordtypeId=r.Id);
        insert a;
         
        //Insert record Type
        RecordType rec = New RecordType();
        rec.name = 'Claim';
        
        //Inser Case
        Case cs = new Case();
        cs.Case_Name__c = 'Test Case';
        //cs.RecordType = rec.Id;
        cs.accountid=a.id;
        insert cs;
        
        RecordType rt = [select id,Name from RecordType where SobjectType='Case_Associate__c' and Name='Member' Limit 1];
        
        /*Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account; 
Map<String,Schema.RecordTypeInfo> CaseAssociateRecType = cfrSchema.getRecordTypeInfosByName(); 
Id rtId = CaseAssociateRecType .get('Claim').getRecordTypeId();*/
   
        //Insret Case Associate
        Case_Associate__c ca = New Case_Associate__c();
        ca.Associate_Type__c = 'Primary';
        ca.Case_Number__c = cs.Id;
        ca.Entity1__c=a.id;
        ca.Entity_type__c='Member';
        ca.recordTypeId = rt.Id;
        
        System.debug('@@@@@@@@ record Type | ' + ca.recordTypeId);
        //ca.recordtypeid = CaseAssociateRecType .get('Claim').getRecordTypeId();
        insert ca;
        ca.Associate_Type__c = 'Secondary';
        update ca;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(ca);
        caseAssignment cas = New caseAssignment(sc);
        cas.test();
        cas.GetRecordTypes();
        cas.updateRecordType();
        cas.Cancel();
        
        sc= new ApexPages.StandardController(a);
        CaseAssociationsController caseAssociation=new CaseAssociationsController(sc);
        
    }
}