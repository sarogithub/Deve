global class refreshActivityMaster{
    
    webservice static void refreshActivityList(){
        Set<String> updatedRecordTypeList=new Set<String>();
        Set<String> currentRecordTypeList=new Set<String>();
        Map<string,Activity_Master__c> masterMap=new Map<string,Activity_Master__c>();
        List<Activity_Master__c> activityMasterToInsert=new List<Activity_Master__c>();
        List<Activity_Master__c> activityMasterToDelete=new List<Activity_Master__c>();
        
        for(RecordType r:[select id,name from recordtype where sobjecttype='Case_Activity__c']){
            updatedRecordTypeList.add(r.name);
        }
        
        for(Activity_Master__c am:[select id,name from Activity_Master__c]){
            masterMap.put(am.name,am);
            if(!updatedRecordTypeList.contains(am.name)){
                activityMasterToDelete.add(new Activity_Master__c(id=am.id));
            }
        }
        
        if(updatedRecordTypeList.size() > 0){
            for(string s:updatedRecordTypeList){
                if(!masterMap.containsKey(s)){
                    activityMasterToInsert.add(new Activity_Master__c(name=s));
                }
            }
        }
        
        if(activityMasterToInsert.size() > 0){
            insert activityMasterToInsert;
        }
        if(activityMasterToDelete.size() > 0){
            delete activityMasterToDelete;
        }
    }
}