@isTest
private class ECareRestResourcesTest{
    
    private testmethod static void ECareRestResourcesSuccessTest(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();       
      
    
        req.requestURI = '/services/apexrest/casecreation/';  
        req.httpMethod = 'POST';
        req.addHeader('Content-Type','application/json');
        String bodyStr='{"CaseName": "Test Name",'+
              '"CaseType": "Trial",'+
              '"CaseReason": "Outliers",'+
              '"ProgramName": "Test",'+
              '"CaseStatus": "Initiated",'+
              '"description": "Test Des",'+
              '"Entities": ['+
                '{'+
                  '"Name": "Kumaresan M",'+
                  '"EntityType": "Provider",'+
                  '"EntityId": "Kum121321",'+
                  '"Associationtype": "Primary"'+
                '},'+
                '{'+
                  '"Name": "Mohan",'+
                  '"EntityType": "Member",'+
                  '"EntityId": "Mohan123",'+
                  '"Associationtype": "Secondary"'+
                '},'+
                '{'+
                  '"Name": "Claims2",'+
                  '"EntityType": "Member",'+
                  '"EntityId": "Anandth123",'+
                  '"Associationtype": "Other"'+
                '},'+
                '{'+
                  '"Name": "Claims3",'+
                  '"EntityType": "Claims",'+
                  '"EntityId": "CL2345",'+
                  '"Associationtype": "Other",'+
                  '"MemberEntityId":"Mohan123",'+
                  '"ProviderEntityId":"Kum121321"'+
                '}'+
              ']'+
            '}';
        req.Requestbody=Blob.ValueOf(bodyStr);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        ECareRestResources.createNewCase();
        Test.stopTest();       
        
    }
    
    private testmethod static void ECareRestResourcesFailureTest1(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();       
      
    
        req.requestURI = '/services/apexrest/casecreation/';  
        req.httpMethod = 'POST';
        req.addHeader('Content-Type','application/xml');
        String bodyStr='{"CaseName": "Test Name",'+
              '"CaseType": "Trial",'+
              '"CaseReason": "Outliers",'+
              '"ProgramName": "Test",'+
              '"CaseStatus": "Initiated",'+
              '"description": "Test Des",'+
              '"Entities": ['+
                '{'+
                  '"Name": "Kumaresan M",'+
                  '"EntityType": "Provider",'+
                  '"EntityId": "Kum121321",'+
                  '"Associationtype": "Primary"'+
                '},'+
                '{'+
                  '"Name": "Mohan",'+
                  '"EntityType": "Member",'+
                  '"EntityId": "Mohan123",'+
                  '"Associationtype": "Secondary"'+
                '},'+
                '{'+
                  '"Name": "Anandth",'+
                  '"EntityType": "Member",'+
                  '"EntityId": "Anandth123",'+
                  '"Associationtype": "Other"'+
                '}'+
              ']'+
            '}';
        req.Requestbody=Blob.ValueOf(bodyStr);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        ECareRestResources.createNewCase();
        Test.stopTest();       
        
    }
    
    private testmethod static void ECareRestResourcesFailureTest2(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();       
      
    
        req.requestURI = '/services/apexrest/casecreation/';  
        req.httpMethod = 'POST';
        req.addHeader('Content-Type','application/json');
        String bodyStr='{"CaseName": "Test Name",}';
        req.Requestbody=Blob.ValueOf(bodyStr);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        ECareRestResources.createNewCase();
        Test.stopTest();       
        
    }
    
    private testmethod static void ECareRestResourcesFailureTest3(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();       
      
    
        req.requestURI = '/services/apexrest/casecreation/';  
        req.httpMethod = 'POST';
        req.addHeader('Content-Type','application/json');
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        ECareRestResources.createNewCase();
        Test.stopTest();       
        
    }

}