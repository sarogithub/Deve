public with sharing class PaymentPlanController {
    public static Case caseRecParsed = new Case();
    public static Date endDate;

    @AuraEnabled
    public static string GetCaseAndPPDDetails(Id recordId){
        try{
            Map<String, Object> output = new Map<String, Object>();
            String dontAllowUsertoCreateOrUpdatePPD = 'false';

            Case caseRec = [SELECT Id, Payment_Plan__c, PP_Begin_Date__c, Total_PP_Amount__c, PP_Type__c, PP_Begin_Date_Backup__c,
                            No_Of_Installment__c, No_Of_Installment_Backup__c, PP_Type_Backup__c, Total_PP_Amount_Backup__c     
                            FROM Case WHERE Id =: recordId];
            output.put('caseDetails', caseRec);

            List<Payment_Plan_Detail__c> lstOfPPD = new List<Payment_Plan_Detail__c>();
            for(Payment_Plan_Detail__c ppdRec : [SELECT Id, Amount_to_Repaid__c, Comments__c, 
                                                Installment__c, Payment_Due_Date__c, Received_Amount__c, Status__c     
                                                FROM Payment_Plan_Detail__c WHERE Case__c =: recordId]){
                lstOfPPD.add(ppdRec);
                if(dontAllowUsertoCreateOrUpdatePPD == 'false' && ppdRec.Status__c == 'Paid'){
                    dontAllowUsertoCreateOrUpdatePPD = 'true';
                }
            }

            output.put('dontAllowUsertoCreateOrUpdatePPD', dontAllowUsertoCreateOrUpdatePPD);
            output.put('btnEnablement', (lstOfPPD.size() > 0) ? 'disableGenerateBtn' : 'disableUpdatePPDBtn');

            return JSON.serialize(output);
        }catch(Exception exceptionDetails){
            String errorMessage = ' Error Message -> ' + exceptionDetails.getMessage() + ' Line # ' + exceptionDetails.getLineNumber();
            System.debug(errorMessage);
            throw new AuraHandledException(errorMessage);
        }
    }

    @AuraEnabled
    public static String PaymentPlanInitiation(String caseRecString){
        caseRecParsed = (Case)System.JSON.deserialize(caseRecString, Case.class);
        Map<String, Object> ppdCreationOutput = new Map<String, Object>();

        Case caseRec = [SELECT Id, Payment_Plan__c, PP_Begin_Date__c, Total_PP_Amount__c, PP_Type__c, 
                            No_Of_Installment__c, No_Of_Installment_Backup__c, PP_Type_Backup__c, Total_PP_Amount_Backup__c     
                            FROM Case WHERE Id =: caseRecParsed.Id];

        if(caseRec.Payment_Plan__c == 'Yes'){
            ppdCreationOutput = PaymentPlanCreate(caseRec);
        }

        return JSON.serialize(ppdCreationOutput);
    }   

    public static Map<String, Object> PaymentPlanCreate(Case caseRec){
        try{
            List<Payment_Plan_Detail__c> ppdListForCreation = new List<Payment_Plan_Detail__c>();
            Map<String, Object> ppdCreationOutput = new Map<String, Object>();

            if(caseRec.PP_Type__c == 'One Time'){
                Payment_Plan_Detail__c ppd = new Payment_Plan_Detail__c(
                    Installment__c = 1,
                    Case__c	= caseRec.Id,
                    Status__c = 'Yet to Pay',
                    Payment_Due_Date__c = caseRec.PP_Begin_Date__c,
                    Amount_to_Repaid__c = caseRec.Total_PP_Amount__c
                );
                
                Case cs = new Case(Id = caseRec.Id);
                cs.PP_End_Date__c = caseRec.PP_Begin_Date__c;

                insert ppd;
                update cs;
            }else if((caseRec.PP_Type__c == 'Others' && caseRec.No_Of_Installment__c > 0) || caseRec.PP_Type__c != 'Others'){
                ppdListForCreation = CreatePPDInstance(caseRec);
                if(ppdListForCreation.size() > 0){
                    insert ppdListForCreation;
                }
            }

            ppdCreationOutput.put('status', 'Success');

            return ppdCreationOutput;
        }catch(Exception exceptionDetails){
            String errorMessage = ' Error Message -> ' + exceptionDetails.getMessage() + ' Line # ' + exceptionDetails.getLineNumber();
            System.debug(errorMessage);
            throw new AuraHandledException(errorMessage);
        }
    }

    public static List<Payment_Plan_Detail__c> CreatePPDInstance(Case caseRec){
        List<Payment_Plan_Detail__c> ppdList = new List<Payment_Plan_Detail__c>();
        Decimal amtToBeRepaid = (caseRec.Total_PP_Amount__c > 0) ? (caseRec.Total_PP_Amount__c/caseRec.No_Of_Installment__c) : 0;

        for(Integer noOfInstallment = 1; noOfInstallment <= caseRec.No_Of_Installment__c; noOfInstallment++){
            Payment_Plan_Detail__c ppd = new Payment_Plan_Detail__c(
                Installment__c = noOfInstallment,
                Case__c	= caseRec.Id,
                Status__c = 'Yet to Pay',
                Payment_Due_Date__c = (caseRec.PP_Begin_Date__c != NULL) ? CalculatePaymentDueDate(caseRec, noOfInstallment) : NULL,
                Amount_to_Repaid__c = amtToBeRepaid
            );

            if(noOfInstallment == Integer.valueOf(caseRec.No_Of_Installment__c)){
                endDate = (caseRec.PP_Begin_Date__c != NULL) ? CalculatePaymentDueDate(caseRec, noOfInstallment) : NULL;
            }
            ppdList.add(ppd);
        }

        return ppdList;
    }

    public static Date CalculatePaymentDueDate(Case caseRec, integer installmentNo){
        Integer installmentNoForCalc = (installmentNo == 1) ? installmentNo : (installmentNo - 1);

        if(caseRec.PP_Type__c == 'Monthly' && installmentNo > 1){
            return (caseRec.PP_Begin_Date__c).addMonths((installmentNoForCalc));
        }else if(caseRec.PP_Type__c == 'Weekly' && installmentNo > 1){
            return (caseRec.PP_Begin_Date__c).addDays((installmentNoForCalc*7));
        }else if(caseRec.PP_Type__c == 'Yearly' && installmentNo > 1){
            return (caseRec.PP_Begin_Date__c).addYears((installmentNoForCalc));
        }

        return (installmentNo == 1) ? caseRec.PP_Begin_Date__c : null;
    } 

    @AuraEnabled
    public static String updatePaymentPlanDetails(String inputParams){
        try{

            Map<String, String> parsedInputParams = (Map<String, String>)System.JSON.deserialize(inputParams, Map<String, String>.class);
            Map<String, Object> ppdCreationOutput = new Map<String, Object>();
            ppdCreationOutput.put('status', 'Error');

            Decimal noOfInstallment;
            String ppType;
            Decimal totalPPAmount;
            Date ppBeginDate;
            Id caseId;

            if(parsedInputParams.get('totalPPAmtChange') == 'true'){
                List<Payment_Plan_Detail__c> updatePPD = new List<Payment_Plan_Detail__c>();
                for(Payment_Plan_Detail__c ppdRec : [SELECT Id, Amount_to_Repaid__c, Comments__c, 
                                                    Installment__c, Payment_Due_Date__c, Received_Amount__c, Status__c, Case__r.Id,
                                                    Case__r.No_Of_Installment__c, Case__r.Total_PP_Amount__c, Case__r.PP_Type__c,
                                                    Case__r.PP_Begin_Date__c
                                                    FROM Payment_Plan_Detail__c WHERE Case__c =: parsedInputParams.get('caseId')]){
                    ppdRec.Status__c = 'Yet to Pay';

                    ppdRec.Amount_to_Repaid__c = (ppdRec.Case__r.PP_Type__c != 'One Time') ? (ppdRec.Case__r.Total_PP_Amount__c/ppdRec.Case__r.No_Of_Installment__c) : ppdRec.Case__r.Total_PP_Amount__c;
                    updatePPD.add(ppdRec);

                    caseId = ppdRec.Case__r.Id;
                    ppType = ppdRec.Case__r.PP_Type__c;
                    noOfInstallment = ppdRec.Case__r.No_Of_Installment__c;
                    totalPPAmount = ppdRec.Case__r.Total_PP_Amount__c;
                    ppBeginDate = ppdRec.Case__r.PP_Begin_Date__c;
                }
                
                Case cs = new Case(
                    Id = caseId,
                    PP_Type_Backup__c = ppType,
                    No_Of_Installment_Backup__c = noOfInstallment, 
                    Total_PP_Amount_Backup__c = totalPPAmount,
                    PP_Begin_Date_Backup__c = ppBeginDate
                );

                if(updatePPD.size() > 0){
                    update updatePPD;
                    update cs;
                    ppdCreationOutput.put('status', 'Success');
                }
            }else if(parsedInputParams.get('PPTypeOrNoOfInstallmentChange') == 'true'){
                Delete [SELECT Id, Amount_to_Repaid__c, Comments__c, 
                Installment__c, Payment_Due_Date__c, Received_Amount__c, Status__c,
                Case__r.No_Of_Installment__c, Case__r.Total_PP_Amount__c   
                FROM Payment_Plan_Detail__c WHERE Case__c =: parsedInputParams.get('caseId')];

                Case caseRec = [SELECT Id, Payment_Plan__c, PP_Begin_Date__c, Total_PP_Amount__c, PP_Type__c, PP_Begin_Date_Backup__c,
                                No_Of_Installment__c, No_Of_Installment_Backup__c, PP_Type_Backup__c, Total_PP_Amount_Backup__c     
                                FROM Case WHERE Id =: parsedInputParams.get('caseId')];

                caseRec.PP_Type_Backup__c = caseRec.PP_Type__c;
                caseRec.No_Of_Installment_Backup__c = caseRec.No_Of_Installment__c; 
                caseRec.Total_PP_Amount_Backup__c = caseRec.Total_PP_Amount__c;
                caseRec.PP_Begin_Date_Backup__c = caseRec.PP_Begin_Date__c;

                ppdCreationOutput.put('status', 'Success');
                ppdCreationOutput = PaymentPlanCreate(caseRec);

                caseRec.PP_End_Date__c = endDate; 
                update caseRec;
            }

            return JSON.serialize(ppdCreationOutput);
        }catch(Exception exceptionDetails){
            String errorMessage = ' Error Message -> ' + exceptionDetails.getMessage() + ' Line # ' + exceptionDetails.getLineNumber();
            System.debug(errorMessage);
            throw new AuraHandledException(errorMessage);
        }
    }
}

