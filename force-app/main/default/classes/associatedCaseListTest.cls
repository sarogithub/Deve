@isTest
public with sharing class associatedCaseListTest {
    @isTest
    static void associatedCaseListTest() {
        Id billingProviderRecordtypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing_Provider').getRecordTypeId();

        Account acc1 = new Account(
            FirstName = 'Test',
            LastName = 'Test 1',
            recordtypeId = billingProviderRecordtypeId,
            Entity_Type__c = 'Billing Provider'
        );
        insert acc1;

        Account acc2 = new Account(
            FirstName = 'Test',
            LastName = 'Test 2',
            recordtypeId = billingProviderRecordtypeId,
            Entity_Type__c = 'Billing Provider'
        );
        insert acc2;

        Case csWeekly1 = new Case(
            Case_Name__c = 'Test Case 1',
            No_Of_Installment__c = 2,
            PP_Begin_Date__c = system.today(),
            Payment_Plan__c = 'Yes',
            PP_Type__c = 'Monthly',
            Total_PP_Amount__c = 15000
        );
        insert csWeekly1;

        Case csWeekly2 = new Case(
            Case_Name__c = 'Test Case 2',
            No_Of_Installment__c = 2,
            PP_Begin_Date__c = system.today(),
            Payment_Plan__c = 'Yes',
            PP_Type__c = 'Monthly',
            Total_PP_Amount__c = 15000
        );
        insert csWeekly2;

        Case_Associate__c caseAssociate1 = new Case_Associate__c(
            Entity1__c = acc1.Id,
            Case_Number__c = csWeekly1.Id,
            Associate_Type__c = 'Primary',
            Entity_Type__c = 'Billing Provider'
        );

        Case_Associate__c caseAssociate2 = new Case_Associate__c(
            Entity1__c = acc2.Id,
            Case_Number__c = csWeekly1.Id,
            Associate_Type__c = 'Secondary',
            Entity_Type__c = 'Billing Provider'
        );

        Case_Associate__c caseAssociate3 = new Case_Associate__c(
            Entity1__c = acc1.Id,
            Case_Number__c = csWeekly2.Id,
            Associate_Type__c = 'Primary',
            Entity_Type__c = 'Billing Provider'
        );

        Case_Associate__c caseAssociate4 = new Case_Associate__c(
            Entity1__c = acc2.Id,
            Case_Number__c = csWeekly2.Id,
            Associate_Type__c = 'Secondary',
            Entity_Type__c = 'Billing Provider'
        );

        List<Case_Associate__c> caseAssociateList = new List<Case_Associate__c>{caseAssociate1, caseAssociate2, caseAssociate3, caseAssociate4};
        insert caseAssociateList;

        String outputMapStr = associatedCaseList.fetchCaseListAssociated(csWeekly1.Id);
        
        System.debug(' outputMapStr -> ' +outputMapStr);
    }
}
