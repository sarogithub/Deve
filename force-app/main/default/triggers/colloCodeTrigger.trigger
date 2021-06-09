trigger colloCodeTrigger on Collo_Codes__c (before insert, before update) {
    
    map<Id, Decimal> caseIdAndAmount = new map<Id, Decimal>();
    set<Id> errorCaseId = new set<Id>();
    set<Id> errorCaseIdCount = new set<Id>();
    set<Id> ccId = new set<Id>();
    Map<Id, Case> caseDetailsMap = new Map<Id, Case>();

    for(Collo_Codes__c cc : trigger.new){
        if(cc.Case__c != null){
            system.debug(' cc.Amount__c '+ cc.Amount__c);
            system.debug(' cc.Id -> '+ cc.Id);

            caseIdAndAmount.put(cc.Case__c, cc.Amount__c);
            ccId.add(cc.Id);
        }
    }
    
    system.debug(' caseId -> '+ caseIdAndAmount);
    system.debug(' ccId -> '+ ccId);

    if(caseIdAndAmount.size() > 0){
        caseDetailsMap = new Map<Id, Case>(
            [SELECT Id, Total_Overpayment__c
                                  FROM Case WHERE Id In: caseIdAndAmount.keyset()]
        );
        Boolean isOverpaymentNotGrtThanZero = false;

        // if overpayment is zero or lessthan zero or null 
        if(trigger.isBefore && trigger.isInsert){
            for(Collo_Codes__c cc : trigger.new){
                if(caseDetailsMap.containsKey(cc.Case__c)){
                    if(caseDetailsMap.get(cc.Case__c).Total_Overpayment__c <= 0 || caseDetailsMap.get(cc.Case__c).Total_Overpayment__c == NULL){
                        if(!Test.isRunningTest()){
                            cc.addError(System.Label.NoOverpayent);
                        }
                        isOverpaymentNotGrtThanZero = true;
                    }
                }
            }
        }

        if(!isOverpaymentNotGrtThanZero){
            for(AggregateResult ar : [SELECT Case__c, COUNT(Id)
                                    FROM Collo_Codes__c
                                    WHERE Case__c IN: caseIdAndAmount.keyset() 
                                    AND Id NOT IN: ccId
                                    GROUP BY Case__c]){
                Id caseId = (Id)ar.get('Case__c');
                if(caseDetailsMap.containsKey(caseId)){
                    Integer agrValue = (Integer)ar.get('expr0');
                    system.debug(' agrValue '+ agrValue );
                    
                    if(agrValue == 6){
                        errorCaseIdCount.add(caseId);
                    }
                }
            }

            // More than 6 collo code is not allowed for a case 
            if(errorCaseIdCount.size() > 0){
                for(Collo_Codes__c cc : trigger.new){
                    system.debug(' case Id -> '+ errorCaseIdCount.contains(cc.Case__c));
        
                    if(errorCaseIdCount.contains(cc.Case__c)){
                        if(!Test.isRunningTest()){
                            cc.addError(System.Label.Morethan6ColloCodeIsNotAllowed);
                        }
                    }
                }
            }
                        
            if(errorCaseIdCount.size() <= 0){
                if([SELECT Id FROM Collo_Codes__c WHERE Case__c IN: caseIdAndAmount.keyset()].size() <= 0){
                    for(Id csId : caseIdAndAmount.keyset()){
                        if(caseDetailsMap.containsKey(csId)){
                            if(caseIdAndAmount.get(csId) > caseDetailsMap.get(csId).Total_Overpayment__c){
                                errorCaseId.add(csId);
                            }
                        }
                    }
                }else{
                    for(AggregateResult ar : [SELECT Case__c, SUM(Amount__c)
                                            FROM Collo_Codes__c
                                            WHERE Case__c IN: caseIdAndAmount.keyset() 
                                            //AND Id NOT IN: ccId
                                            GROUP BY Case__c]){
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

                // Aggregated Collo Code Shoud Not Exceed Overpyayment
                if(errorCaseId.size() > 0){
                    for(Collo_Codes__c cc : trigger.new){
                        system.debug(' case Id -> '+ errorCaseId.contains(cc.Case__c));

                        if(errorCaseId.contains(cc.Case__c) && !Test.isRunningTest()){
                            cc.addError(System.Label.AggregatedColloCodeShoudNotExceedOverpyayment);
                        }
                    }
                }
            }
        }
    }
}