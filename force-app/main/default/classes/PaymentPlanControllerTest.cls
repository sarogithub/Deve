@isTest
public with sharing class PaymentPlanControllerTest {
    @testSetup
    static void makeData(){
        Case csWeekly1 = new Case(
            Case_Name__c = 'Test Case 1',
            No_Of_Installment__c = 2,
            PP_Begin_Date__c = system.today(),
            Payment_Plan__c = 'Yes',
            PP_Type__c = 'Weekly',
            Total_PP_Amount__c = 15000
        );
        insert csWeekly1;

        Case csMonthly = new Case(
            Case_Name__c = 'Test Case 2',
            No_Of_Installment__c = 2,
            PP_Begin_Date__c = system.today(),
            Payment_Plan__c = 'Yes',
            PP_Type__c = 'Monthly',
            Total_PP_Amount__c = 15000
        );
        insert csMonthly;

        Case csOneTime = new Case(
            Case_Name__c = 'Test Case 3',
            No_Of_Installment__c = 2,
            PP_Begin_Date__c = system.today(),
            Payment_Plan__c = 'Yes',
            PP_Type__c = 'One Time',
            Total_PP_Amount__c = 15000
        );
        insert csOneTime;

        Case csWeekly2 = new Case(
            Case_Name__c = 'Test Case 4',
            No_Of_Installment__c = 2,
            PP_Begin_Date__c = system.today(),
            Payment_Plan__c = 'Yes',
            PP_Type__c = 'Weekly',
            Total_PP_Amount__c = 15000
        );
        insert csWeekly2;

        Case csUpdate = new Case(
            Case_Name__c = 'Test Case 5',
            No_Of_Installment__c = 2,
            PP_Begin_Date__c = system.today(),
            Payment_Plan__c = 'Yes',
            PP_Type__c = 'Yearly',
            Total_PP_Amount__c = 15000,
            No_Of_Installment_Backup__c = 1,
            Total_PP_Amount_Backup__c = 10000, 
            PP_Type_Backup__c = 'Monthly'
        );
        insert csUpdate;

        // Update Payment Plan Header in Case for test coverage
        Case csUpdateTrigger = new Case(
            Case_Name__c = 'Test Case 6',
            PP_Begin_Date__c = system.today(),
            Activities_to_close__c = 'Compile Audit Findings; Confirm Credit Balance',
            Activities_to_enable__c = 'Contact Provider'
        );
        insert csUpdateTrigger;

        Payment_Plan_Detail__c ppd = new Payment_Plan_Detail__c(
            Case__c = csWeekly1.Id,
            Amount_to_Repaid__c = 1500,
            Status__c = 'Paid',
            Payment_Due_Date__c = system.today().addMonths(1),
            Installment__c = 1,
            Received_Amount__c = 1500
        );
        insert ppd;

        String recordtypeId1 = Schema.SObjectType.Case_Activity__c.getRecordTypeInfosByName().get('Compile Audit Findings').getRecordTypeId();
        String recordtypeId2 = Schema.SObjectType.Case_Activity__c.getRecordTypeInfosByName().get('Confirm Credit Balance').getRecordTypeId();
        String recordtypeId3 = Schema.SObjectType.Case_Activity__c.getRecordTypeInfosByName().get('Contact Provider').getRecordTypeId();

        Case_Activity__c casact1 = new Case_Activity__c(
            RecordtypeId = recordtypeId1,
            Name = 'Compile Audit Findings',
            Case__c = csUpdateTrigger.id,
            IsEnabled__c = true
        );
        insert casact1;

        Case_Activity__c casact2 = new Case_Activity__c(
            RecordtypeId = recordtypeId2,
            Name = 'Confirm Credit Balance',
            Case__c = csUpdateTrigger.id,
            IsEnabled__c = true
        );
        insert casact2;
    }

    @isTest
    static void GetCaseAndPPDDetailsTest(){
        Case cs = [SELECT Id FROM Case WHERE Case_Name__c = 'Test Case 1'];
        PaymentPlanController.GetCaseAndPPDDetails(cs.Id);
    }

    @isTest
    static void PaymentPlanInitiationTest(){
        // Monthly
        Case caseRecMonthly = [SELECT Id, Payment_Plan__c, PP_Begin_Date__c, Total_PP_Amount__c, PP_Type__c, 
                            No_Of_Installment__c, No_Of_Installment_Backup__c, PP_Type_Backup__c, Total_PP_Amount_Backup__c     
                            FROM Case WHERE Case_Name__c = 'Test Case 2'];
        PaymentPlanController.PaymentPlanInitiation(JSON.serialize(caseRecMonthly));

        // One Time 
        Case caseRecOneTime = [SELECT Id, Payment_Plan__c, PP_Begin_Date__c, Total_PP_Amount__c, PP_Type__c, 
                            No_Of_Installment__c, No_Of_Installment_Backup__c, PP_Type_Backup__c, Total_PP_Amount_Backup__c     
                            FROM Case WHERE Case_Name__c = 'Test Case 3'];
        PaymentPlanController.PaymentPlanInitiation(JSON.serialize(caseRecOneTime));

        // Weekly
        Case caseRecWeekly = [SELECT Id, Payment_Plan__c, PP_Begin_Date__c, Total_PP_Amount__c, PP_Type__c, 
                            No_Of_Installment__c, No_Of_Installment_Backup__c, PP_Type_Backup__c, Total_PP_Amount_Backup__c     
                            FROM Case WHERE Case_Name__c = 'Test Case 4'];
        PaymentPlanController.PaymentPlanInitiation(JSON.serialize(caseRecWeekly));
    }

    @isTest
    static void updatePaymentPlanDetailsTest(){
        // Monthly
        Case caseRecUpdate = [SELECT Id, Payment_Plan__c, PP_Begin_Date__c, Total_PP_Amount__c, PP_Type__c, 
                            No_Of_Installment__c, No_Of_Installment_Backup__c, PP_Type_Backup__c, Total_PP_Amount_Backup__c     
                            FROM Case WHERE Case_Name__c = 'Test Case 5'];

        Map<String,String> parsedInputParams = new Map<String,String>{
            'totalPPAmtChange' => 'false',
            'PPTypeOrNoOfInstallmentChange' => 'true',
            'caseId' => caseRecUpdate.Id
        };

        PaymentPlanController.updatePaymentPlanDetails(JSON.serialize(parsedInputParams));

        Map<String,String> parsedInputParamstotalPPAmtChange = new Map<String,String>{
            'totalPPAmtChange' => 'true',
            'PPTypeOrNoOfInstallmentChange' => 'false',
            'caseId' => caseRecUpdate.Id
        };

        PaymentPlanController.updatePaymentPlanDetails(JSON.serialize(parsedInputParamstotalPPAmtChange));
    }

    @isTest
    static void updateCaseTriggerTest(){
        Case caseRecUpdate = [SELECT Id, Payment_Plan__c, PP_Begin_Date__c, Total_PP_Amount__c, PP_Type__c, 
                            No_Of_Installment__c, No_Of_Installment_Backup__c, PP_Type_Backup__c, Total_PP_Amount_Backup__c     
                            FROM Case WHERE Case_Name__c = 'Test Case 6'];

        caseRecUpdate.No_Of_Installment__c = 5;
        caseRecUpdate.PP_Type__c = 'Yearly';
        caseRecUpdate.Total_PP_Amount__c = 19000;
        caseRecUpdate.Payment_Plan__c = 'Yes';
        caseRecUpdate.Activities_to_close__c = 'Compile Audit Findings; Confirm Credit Balance; Contact Provider';
        caseRecUpdate.Activities_to_enable__c = 'Compile Audit Findings; Contact Provider';
        update caseRecUpdate;
    }
}
