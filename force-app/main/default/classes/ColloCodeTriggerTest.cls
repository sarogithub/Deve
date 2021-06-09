@isTest
public with sharing class ColloCodeTriggerTest {
    @isTest
    static void ColloCodeAmountExceedOverPayment(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Medicaid PI Audit').getRecordTypeId();

        Case csWeekly1 = new Case(
            Case_Name__c = 'Test Case 1',
            No_Of_Installment__c = 2,
            PP_Begin_Date__c = system.today(),
            Payment_Plan__c = 'Yes',
            PP_Type__c = 'Weekly',
            Total_PP_Amount__c = 15000,
            Total_Overpayment__c = 20,
            RecordTypeId = recordTypeId 
        );
        insert csWeekly1;

        Collo_Codes__c cc1 = new Collo_Codes__c(
            Name = 'CC1',
            Amount__c = 21,
            Case__c = csWeekly1.Id
        );
        Insert cc1;
    }

    @isTest
    static void ZeroOverPayment(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Medicaid PI Audit').getRecordTypeId();

        Case csWeekly2 = new Case(
            Case_Name__c = 'Test Case 1',
            No_Of_Installment__c = 2,
            PP_Begin_Date__c = system.today(),
            Payment_Plan__c = 'Yes',
            PP_Type__c = 'Weekly',
            Total_PP_Amount__c = 15000,
            Total_Overpayment__c = 0,
            RecordTypeId = recordTypeId 
        );
        insert csWeekly2;

        Collo_Codes__c cc2 = new Collo_Codes__c(
            Name = 'CC2',
            Amount__c = 21,
            Case__c = csWeekly2.Id
        );
        Insert cc2;
    }

    @isTest
    static void AggregateValue(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Medicaid PI Audit').getRecordTypeId();

        Case csWeekly2 = new Case(
            Case_Name__c = 'Test Case 1',
            No_Of_Installment__c = 2,
            PP_Begin_Date__c = system.today(),
            Payment_Plan__c = 'Yes',
            PP_Type__c = 'Weekly',
            Total_PP_Amount__c = 15000,
            Total_Overpayment__c = 30,
            RecordTypeId = recordTypeId 
        );
        insert csWeekly2;

        Collo_Codes__c cc2 = new Collo_Codes__c(
            Name = 'CC2',
            Amount__c = 15,
            Case__c = csWeekly2.Id
        );
        Insert cc2;

        Collo_Codes__c cc3 = new Collo_Codes__c(
            Name = 'CC2',
            Amount__c = 16,
            Case__c = csWeekly2.Id
        );
        Insert cc3;
    }

    @isTest
    static void MorethanSixColloCode(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Medicaid PI Audit').getRecordTypeId();

        Case csWeekly2 = new Case(
            Case_Name__c = 'Test Case 1',
            No_Of_Installment__c = 2,
            PP_Begin_Date__c = system.today(),
            Payment_Plan__c = 'Yes',
            PP_Type__c = 'Weekly',
            Total_PP_Amount__c = 15000,
            Total_Overpayment__c = 10,
            RecordTypeId = recordTypeId 
        );
        insert csWeekly2;

        List<Collo_Codes__c> ccList = new List<Collo_Codes__c>();

        for(Integer i = 1; i <= 6; i++){
            Collo_Codes__c cc2 = new Collo_Codes__c(
                Name = 'CC2',
                Amount__c = 1,
                Case__c = csWeekly2.Id
            );
            ccList.add(cc2);
        }

        if(ccList.size() > 0){
            insert ccList;
        }

        Collo_Codes__c cc2 = new Collo_Codes__c(
            Name = 'CC2',
            Amount__c = 1,
            Case__c = csWeekly2.Id
        );
        Insert cc2;

        /*Collo_Codes__c cc3 = new Collo_Codes__c(
            Name = 'CC2',
            Amount__c = 16,
            Case__c = csWeekly2.Id
        );
        Insert cc3;*/
    }
}