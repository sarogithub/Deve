trigger ActivityTrigger on Case_Activity__c (before update) {
    for(Case_Activity__c a:Trigger.New){
        if(a.Status__c=='Completed' && Trigger.oldMap.get(a.Id).Status__c != 'Completed'){
            a.Activity_End_Date__c=system.today();
        }
    }
}