trigger CaseTrigger on Case (after insert, after update, before update, before insert) {
    
    if(trigger.isAfter && trigger.isInsert){
        CaseAssociationsController.createRecord(trigger.new);
    }

    if(trigger.isBefore && trigger.isInsert){
        for(Case cs : trigger.new){
            if(cs.Payment_Plan__c == 'Yes'){
                cs.No_Of_Installment_Backup__c = cs.No_Of_Installment__c;
                cs.PP_Type_Backup__c = cs.PP_Type__c; 
                cs.Total_PP_Amount_Backup__c = cs.Total_PP_Amount__c;
            }
        }
    }

    if(trigger.isBefore && trigger.isUpdate){
        for(Case cs : trigger.new){
            if(cs.Payment_Plan__c == 'Yes'){
                if((Trigger.OldMap.get(cs.Id).No_Of_Installment__c != cs.No_Of_Installment__c
                    && Trigger.OldMap.get(cs.Id).No_Of_Installment__c == null)
                    || (Trigger.OldMap.get(cs.Id).Payment_Plan__c != cs.Payment_Plan__c 
                    && cs.No_Of_Installment_Backup__c == null)){
                    cs.No_Of_Installment_Backup__c = cs.No_Of_Installment__c;
                }
                if((Trigger.OldMap.get(cs.Id).PP_Type__c != cs.PP_Type__c
                    && Trigger.OldMap.get(cs.Id).PP_Type__c == null)
                    || (Trigger.OldMap.get(cs.Id).Payment_Plan__c != cs.Payment_Plan__c
                    && cs.PP_Type_Backup__c == null)){
                    cs.PP_Type_Backup__c = cs.PP_Type__c; 
                }
                if((Trigger.OldMap.get(cs.Id).Total_PP_Amount__c != cs.Total_PP_Amount__c
                    && Trigger.OldMap.get(cs.Id).Total_PP_Amount__c == null)
                    || (Trigger.OldMap.get(cs.Id).Payment_Plan__c != cs.Payment_Plan__c 
                    && cs.Total_PP_Amount_Backup__c == null)){
                    cs.Total_PP_Amount_Backup__c = cs.Total_PP_Amount__c;
                }
            }
        }
    }
    
    if(trigger.isAfter && trigger.isUpdate){
        Map<Id,Set<String>> caseIdWithActivitiesToClose=new Map<Id,Set<string>>();
        List<Case_Activity__c> ActivitiesToUpdate=new List<Case_Activity__c>();
        Map<Id,Set<String>> caseIdWithActivitiesToEnable=new Map<Id,Set<string>>();
        Case_Activity__c act;
        Map<Id,Map<String,Integer>> caseWithAdditionalMap=new Map<Id,Map<String,Integer>>();  
            
        for(case c:trigger.new){
            if(c.Activities_to_close__c != null && trigger.oldMap.get(c.Id).Activities_to_close__c != c.Activities_to_close__c){
                List<String> activitiesName=c.Activities_to_close__c.split(';');
                caseIdWithActivitiesToClose.put(c.id,new Set<string>(activitiesName));
            } 
            if(c.Activities_to_enable__c != null && trigger.oldMap.get(c.Id).Activities_to_enable__c != c.Activities_to_enable__c){
                List<String> activitiesNameNew=c.Activities_to_enable__c.split(';');
                caseIdWithActivitiesToEnable.put(c.id,new Set<string>(activitiesNameNew));
                
                /*if(!caseWithAdditionalMap.containsKey(c.Id)){
                    caseWithAdditionalMap.put(c.Id,new Map<String,Integer>());
                }
                
                Integer i=1;
                for(string f:activitiesNameNew){
                    String vname='Activity_Due_Days_'+i+'__c';
                    if(c.get(vname) != null){
                        caseWithAdditionalMap.get(c.Id).put(f,Integer.ValueOf(c.get(vname)));
                    }
                    i++;
                }*/
            }
        }
        
        system.debug('****'+caseWithAdditionalMap);
        if((caseIdWithActivitiesToClose.keyset() != null && caseIdWithActivitiesToClose.keyset().size() >0) || (caseIdWithActivitiesToEnable.keyset() != null && caseIdWithActivitiesToEnable.keyset().size() >0)){
            for(Case_Activity__c ca:[select id,case__c,Case_Activity_Type__c,Activity_Business_Status__c,RecordType.Name,Activity_Due_Date__c from Case_Activity__c where (Case__c IN:caseIdWithActivitiesToClose.keyset() OR Case__c IN:caseIdWithActivitiesToEnable.keyset())]){
                if(caseIdWithActivitiesToClose.get(ca.case__c) != null && caseIdWithActivitiesToClose.get(ca.case__c).contains(ca.RecordType.Name)){
                    act=new Case_Activity__c();
                    if(ca.Activity_Business_Status__c == null || ca.Activity_Business_Status__c == '' || ca.Activity_Business_Status__c == 'None'){
                        act.Activity_Business_Status__c='Activity Not Applicable';
                    }
                    act.Activity_End_Date__c=system.today();
                    act.id=ca.id;
                    act.Auto_Closure__c=true;
                    if(act.Status__c!='Completed'){
                        act.Status__c='Completed';
                    }
                    ActivitiesToUpdate.add(act);
                }
                if(caseIdWithActivitiesToEnable.get(ca.case__c) != null && caseIdWithActivitiesToEnable.get(ca.case__c).contains(ca.RecordType.Name)){
                    act=new Case_Activity__c();
                    act.id=ca.id;
                    act.IsEnabled__c=true;
                    /*if(caseWithAdditionalMap.containsKey(ca.Case__c) && caseWithAdditionalMap.get(ca.Case__c) != null && 
                        caseWithAdditionalMap.get(ca.Case__c).ContainsKey(ca.RecordType.Name) && 
                        caseWithAdditionalMap.get(ca.Case__c).get(ca.RecordType.Name) != null && 
                        caseWithAdditionalMap.get(ca.Case__c).get(ca.RecordType.Name) != 0){
                        if(act.Activity_Due_Date__c==null)
                            act.Activity_Due_Date__c=system.today().addDays(caseWithAdditionalMap.get(ca.Case__c).get(ca.RecordType.Name));
                        else
                            act.Activity_Due_Date__c=act.Activity_Due_Date__c.addDays(caseWithAdditionalMap.get(ca.Case__c).get(ca.RecordType.Name));
                    }*/
                    ActivitiesToUpdate.add(act);
                }
            }
        }
        
        if(ActivitiesToUpdate.size() >0)
            update ActivitiesToUpdate;
    }
}