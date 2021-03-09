trigger GroupUpdateCaseAactivityStatus on Case_Activity__c (after update) {

set<Id> setcaserecid = new set<Id>();
List<Case_Activity__c> lstCaseActivity = new List<Case_Activity__c>();

    for(Case_Activity__c irow: trigger.new){
        if(irow.Case_Activity_Type__c == 'Perform Initial Risk Assessment' && irow.Activity_Business_Status__c == 'Initial Risk Score – Low') {setcaserecid.add(irow.Case__c);}
    }
    
    for(Case_Activity__c icase : [select id, Case__c, Status__c, Activity_Business_Status__c from Case_Activity__c  where Case__c =: setcaserecid and Activity_Business_Status__c = '' and Case_Activity_Type__c != 'Dispose Case']) {
            icase.Status__c = 'Completed'; icase.Activity_Business_Status__c = 'Activity Not Applicable';  Update icase;                        
    }                                
  
}