trigger RestrictCaseActivityUpdateOnceApproved on Case_Activity__c (before update) {
    Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    Map <String, Schema.SObjectField> fieldMap = schemaMap.get('Case_Activity__c').getDescribe().fields.getMap();
    List<String> fieldsAllowedToEdit = new List<String>{'Status__c','Activity_Business_Status__c','Supervisor_Approval_Status__c'};

    for(Case_Activity__c ca : trigger.new){
        Case_Activity__c oldMapCa = trigger.oldMap.get(ca.Id);

        if(ca.Supervisor_Approval_Status__c == 'Approved'){
            for(Schema.SObjectField sfield : fieldMap.Values()){
                schema.describefieldresult dfield = sfield.getDescribe();
                String apiName = dfield.getname();
                
                if(!fieldsAllowedToEdit.contains(apiName)){
                    if(oldMapCa.get(apiName) != ca.get(apiName)){
                        ca.addError(System.label.SupervisorApprovedEditAccessMessage);
                    }
                }
            }
        }
    }
}