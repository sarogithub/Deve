@isTest
public class CaseActivity_SK_Test{
    
    public testmethod static Case_Activity__c CaseActCreation(){
        case cas = new Case();
        cas.Case_Name__c = 'Provider Audit';
        cas.Type = 'Provider Audit-Onsite';
        cas.Status = 'In-Progress';
        insert cas;
        
        String recordtypeId = Schema.SObjectType.Case_Activity__c.getRecordTypeInfosByName().get('Contact Provider').getRecordTypeId();
        Case_Activity__c casact = new Case_Activity__c();
        casact.RecordtypeId = recordtypeId;
        casact.Name = 'Provider Audit';
        casact.Case__c = cas.id;
        insert casact;
        
        return casact;
    }
    
    private testmethod static void positiveTest(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();       
        Case_Activity__c cas = CaseActCreation();
        Case_Activity__c caseact1 = [select id from Case_Activity__c where id =: cas.id];
        req.requestURI = '/services/apexrest/CaseActivityDetails/';  
        req.httpMethod = 'POST';
        req.addHeader('Content-Type','application/json');
        String bodyStr='{"caseActId":"'+ caseact1.Id + '"}';
        
        req.Requestbody=Blob.ValueOf(bodyStr);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        CaseActivity_SK.CaseActivityDetails();
        Test.stopTest();       
    }
    
    private testmethod static void negativeTest_1(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();       
        Case_Activity__c cas = CaseActCreation();
        Case_Activity__c caseact1 = [select id from Case_Activity__c where id =: cas.id];
        req.requestURI = '/services/apexrest/CaseActivityDetails/';  
        req.httpMethod = 'POST';
        req.addHeader('Content-Type','application/json');
        String bodyStr='{"caseActId":"'+ caseact1.id+ '"}';
        
        req.Requestbody=Blob.ValueOf(bodyStr);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        CaseActivity_SK.CaseActivityDetails();
        Test.stopTest();       
    }
    
    private testmethod static void negativeTest_2(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();       
        Case_Activity__c cas = CaseActCreation();
        Case_Activity__c caseact1 = [select id from Case_Activity__c where id =: cas.id];
        req.requestURI = '/services/apexrest/CaseActivityDetails/';  
        req.httpMethod = 'POST';
        //req.addHeader('Content-Type','application/json');
        String bodyStr='{"caseActId":"'+ caseact1.id+ '"}';
        
        req.Requestbody=Blob.ValueOf(bodyStr);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        CaseActivity_SK.CaseActivityDetails();
        Test.stopTest();       
    }
    
    private testmethod static void negativeTest_3(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();       
        Case_Activity__c cas = CaseActCreation();
        Case_Activity__c caseact1 = [select id from Case_Activity__c where id =: cas.id];
        //req.requestURI = '/services/apexrest/CaseAndActivityDetails/';  
        //req.httpMethod = 'POST';
        //req.addHeader('Content-Type','application/json');
        String bodyStr='{"caseActId":"'+ caseact1.id+ '"}';
        
        req.Requestbody=Blob.ValueOf(bodyStr);
        //RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        CaseActivity_SK.CaseActivityDetails();
        Test.stopTest();       
    }
    
    private testmethod static void negativeTest_4(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();       
        Case_Activity__c cas = CaseActCreation();
        Case_Activity__c caseact1 = [select id from Case_Activity__c where id =: cas.id];
        req.requestURI = '/services/apexrest/CaseActivityDetails/';  
        req.httpMethod = 'POST';
        req.addHeader('Content-Type','application/json');
        String bodyStr='{"caseActId":"'+ caseact1.id+ '"}';
        
        //req.Requestbody=Blob.ValueOf(bodyStr);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        CaseActivity_SK.CaseActivityDetails();
        Test.stopTest();       
    }
}