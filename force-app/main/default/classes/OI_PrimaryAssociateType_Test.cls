@ISTest
public class OI_PrimaryAssociateType_Test {
    
    
    
    Public Static testMethod void PrimaryAssociateTypeTest(){
        
        Contact con = New Contact();
        con.LastName = 'Test name';
        insert con;
        
        Case cs = New Case();
        cs.Case_Name__c = 'Test Case';
        cs.Status = 'Completed';
        cs.Origin = 'Referral';
        cs.Type = 'Client Audit';
        insert Cs;
        
        Case_Associate__c ca = New Case_Associate__c();
        // ca.name = 'test Name';
        ca.Case_Number__c = Cs.Id;
        ca.Associate_Type__c = 'Secondary';
        ca.Entity_Type__c = 'Billing Provider';
        boolean b = false;
        for(Apexpages.Message thisMsg : ApexPages.getMessages()){
            system.assert(thisMsg.getDetail().contains('Primary Associate Type was Already Created. So Please Choose "Secondary" or "Other" '));
        }
        insert ca;
        //ca.Associate_Type__c = 'Primary';
        //update ca;
        Map<Id,Case_Associate__c> casMap  = New Map<Id,Case_Associate__c>();
        set<Id> caseId1 = New Set<Id>();
        Map<Id,Case_Associate__c> accMap = New Map<Id,Case_Associate__c>();
        Case_Associate__c ca2 = New Case_Associate__c();
        ca2.Case_Number__c = cs.Id;
        ca2.Entity_Type__c = 'Billing Provider';
        ca2.Associate_Type__c = 'Primary';
        //accMap.put(ca2.Entity1__c,ca2);
        //caseId1.add(ca2.Case_Number__c);
        //casMap.put(ca2.Case_Number__c,ca2);
        insert ca2;
        
        
        cs.ContactId = con.Id;
        update cs;
    }
    
}