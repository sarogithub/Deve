trigger colloCodeTrigger on Collo_Codes__c (before insert, before update) {
    
    map<Id, Decimal> caseIdAndAmount = new map<Id, Decimal>();
    set<Id> errorCaseId = new set<Id>();
    set<Id> ccId = new set<Id>();

    for(Collo_Codes__c cc : trigger.new){
        if(cc.Case__c != null){
            system.debug(' cc.Amount__c '+ cc.Amount__c);
            caseIdAndAmount.put(cc.Case__c, cc.Amount__c);
            ccId.add(cc.Id);
        }
    }
    
    system.debug(' caseId -> '+ caseIdAndAmount);

    if(caseIdAndAmount.size() > 0){
        Map<Id, Case> caseDetailsMap = new Map<Id, Case>(
            [SELECT Id, Total_Overpayment__c
                                  FROM Case WHERE Id In: caseIdAndAmount.keyset()]
        );
        
        AggregateResult[] groupedResults = [SELECT Case__c, SUM(Amount__c)
                                  FROM Collo_Codes__c
                                  WHERE Case__c IN: caseIdAndAmount.keyset() 
                                  AND Id NOT IN: ccId
                                  GROUP BY Case__c];
                                  
        for (AggregateResult ar : groupedResults){
            Id caseId = (Id)ar.get('Case__c');
            if(caseDetailsMap.containsKey(caseId)){
                Decimal amount = caseDetailsMap.get(caseId).Total_Overpayment__c;
                Decimal agrValue = (Decimal)ar.get('expr0');
                system.debug(' amount  '+ amount );
                system.debug(' agrValue '+ agrValue );
                
                if(caseIdAndAmount.containsKey(caseId)){
                    agrValue = agrValue + caseIdAndAmount.get(caseId);
                }
                
                if(agrValue > amount){
                    errorCaseId.add(caseId);
                }
            }
        }
    }
    
    system.debug(' errorCaseId '+ errorCaseId);

    if(errorCaseId.size() > 0){
        for(Collo_Codes__c cc : trigger.new){
            system.debug(' case Id -> '+ errorCaseId.contains(cc.Case__c));

            if(errorCaseId.contains(cc.Case__c)){
                cc.addError('Aggregated collo code amount should not exceed the Total Overpayment.');
            }
        }
    }
}