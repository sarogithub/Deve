@IsTest    
Public Class CaseTriggerTest{

    public Static testMethod void CaseTriggerTest(){    
        Id accRectypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing Provider').getRecordTypeId();

        Account acc = new Account(
            LastName = 'Test',
            FirstName = 'Test',
            RecordTypeId = accRectypeId,
            BillingStreet = 'Street', BillingPostalCode = '123', 
            BillingCity = 'chennai', BillingCountry = 'india'
        );
        insert acc;

        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        CaseAssociationsController testAccPlan = new CaseAssociationsController(sc);

        Case csMonthly0 = new Case(
            Case_Name__c = 'Test Case 1',
            No_Of_Installment__c = 2,
            PP_Begin_Date__c = system.today(),
            Payment_Plan__c = 'Yes',
            PP_Type__c = 'Monthly',
            Total_PP_Amount__c = 15000,
            accountId = acc.Id
        );
        insert csMonthly0;

        Case csMonthly1 = new Case(
            Case_Name__c = 'Test Case 1',
            PP_Begin_Date__c = system.today(),
            Payment_Plan__c = 'No',
            PP_Type__c = 'Monthly',
            Total_PP_Amount__c = 15000
        );
        insert csMonthly1;

        Case_Activity__c ca1 = new Case_Activity__c(
            Name = 'Perform Provider Self Review',
            Case__c = csMonthly1.Id,
            Activity_Start_Date__c = system.today(),
            IsEnabled__c = true,
            Case_Activity_Type__c = 'Perform Provider Self Review'
        );
        insert ca1;

        Case_Activity__c ca2 = new Case_Activity__c(
            Name = 'Evaluate Provider Findings',
            Case__c = csMonthly1.Id,
            Activity_Start_Date__c = system.today(),
            IsEnabled__c = false,
            Case_Activity_Type__c = 'Evaluate Provider Findings'
        );
        insert ca2;

        Case csMonthly2 = new Case(
            Id = csMonthly1.Id,
            Case_Name__c = 'Test Case 2',
            No_Of_Installment__c = 2,
            PP_Begin_Date__c = system.today(),
            Payment_Plan__c = 'Yes',
            PP_Type__c = 'Monthly',
            Total_PP_Amount__c = 15000,
            Activities_to_close__c = 'Perform Provider Self Review',
            Activities_to_enable__c = 'Evaluate Provider Findings'
        );
        update csMonthly2;
    }
}