@isTest
public class CaseDetailsandCaseActivityList_SK_Test{
    
    public testmethod static case CaseCreation(){
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
        
        return cas;
    }
    
    private testmethod static void positiveTest(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();       
        Case cas = CaseCreation();
        Case case1 = [select id, Casenumber from case where id =: cas.id];
        req.requestURI = '/services/apexrest/CaseAndActivityDetails/';  
        req.httpMethod = 'POST';
        req.addHeader('Content-Type','application/json');
        String bodyStr='{"CaseId":"'+ case1.casenumber + '"}';
        
        req.Requestbody=Blob.ValueOf(bodyStr);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        CaseDetailsandCaseActivityList_SK.createNewCase();
        Test.stopTest();       
    }
    
    private testmethod static void negativeTest_1(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();       
        Case cas = CaseCreation();
        Case case1 = [select id, Casenumber from case where id =: cas.id];
        req.requestURI = '/services/apexrest/CaseAndActivityDetails/';  
        req.httpMethod = 'POST';
        req.addHeader('Content-Type','application/json');
        String bodyStr='{"CaseId":"'+ case1.id+ '"}';
        
        req.Requestbody=Blob.ValueOf(bodyStr);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        CaseDetailsandCaseActivityList_SK.createNewCase();
        Test.stopTest();       
    }
    
    private testmethod static void negativeTest_2(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();       
        Case cas = CaseCreation();
        Case case1 = [select id, Casenumber from case where id =: cas.id];
        req.requestURI = '/services/apexrest/CaseAndActivityDetails/';  
        req.httpMethod = 'POST';
        //req.addHeader('Content-Type','application/json');
        String bodyStr='{"CaseId":"'+ case1.id+ '"}';
        
        req.Requestbody=Blob.ValueOf(bodyStr);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        CaseDetailsandCaseActivityList_SK.createNewCase();
        Test.stopTest();       
    }
    
    private testmethod static void negativeTest_3(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();       
        Case cas = CaseCreation();
        Case case1 = [select id, Casenumber from case where id =: cas.id];
        //req.requestURI = '/services/apexrest/CaseAndActivityDetails/';  
        //req.httpMethod = 'POST';
        //req.addHeader('Content-Type','application/json');
        String bodyStr='{"CaseId":"'+ case1.id+ '"}';
        
        req.Requestbody=Blob.ValueOf(bodyStr);
        //RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        CaseDetailsandCaseActivityList_SK.createNewCase();
        Test.stopTest();       
    }
    
    private testmethod static void negativeTest_4(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();       
        Case cas = CaseCreation();
        Case case1 = [select id, Casenumber from case where id =: cas.id];
        req.requestURI = '/services/apexrest/CaseAndActivityDetails/';  
        req.httpMethod = 'POST';
        req.addHeader('Content-Type','application/json');
        String bodyStr='{"CaseId":"'+ case1.id+ '"}';
        
        //req.Requestbody=Blob.ValueOf(bodyStr);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        CaseDetailsandCaseActivityList_SK.createNewCase();
        Test.stopTest();       
    }
}