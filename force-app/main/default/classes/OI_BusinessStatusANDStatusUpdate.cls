@IsTest
public class OI_BusinessStatusANDStatusUpdate {
    
    Public Static testmethod void Test_OI_BusinessStatusANDStatusUpdate(){
        
        Case cas = New Case();
        cas.Case_Name__c = 'Test Case';        
        Insert cas;
        //String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Case_Activity__c ' and Name = 'Receive Document'].Id;
        Id RecordTypeId = Schema.SObjectType.Case_Activity__c.getRecordTypeInfosByName().get('Receive & Track Credit Balance').getRecordTypeId();
        
        Case_Activity__c casAct = New Case_Activity__c();
        casAct.Case__c = cas.Id;
        casAct.Activity_Business_Status__c = 'Credit Balance Reported';
        casAct.RecordTypeId = RecordTypeId ;
        Insert casAct;
        casAct.Activity_Business_Status__c = 'Activity Not Applicable';
        casAct.Status__c = 'Completed';
        Update casAct;
        
        Case cas1 = New Case();
        cas1.Case_Name__c = 'Test Case';   
        cas1.Type = 'Provider Audit - Onsite';
        Insert cas1;        
        
    }
    
    
}