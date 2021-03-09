public class redirectToSampleActivityController {
    
    public Case_Activity__c casActivity;
    public Activity_Master__c activityMaster;
    RecordType r;
    Case c;
    
    public redirectToSampleActivityController(ApexPages.StandardController controller) {
        activityMaster=(Activity_Master__c)controller.getRecord();
        activityMaster=[SELECT Id,Name from Activity_Master__c where Id=:activityMaster.Id];
        r=[SELECT Id,name,isActive,SobjectType from RecordType where name=:activityMaster.Name and isActive=true AND SobjectType='Case_Activity__c'];
        
        try{
            c=[SELECT id from Case where Case_Name__c='Sample Case'];
            casActivity=[SELECT Id,Case__c from Case_Activity__c where Case__r.Case_Name__c='Sample Case' AND RecordType.name=:activityMaster.Name];
        }
        Catch(Exception e){
            
        }
    }
    
    public pageReference reDirectToActivity(){
        if((casActivity == null || casActivity.Id == null) && r != null && c != null){                        
            casActivity=new Case_Activity__c(name=activityMaster.Name,RecordTypeId=r.Id,Case__c=c.Id);
            insert   casActivity;             
        }
            
        pageReference p;
        
        if(casActivity != null && casActivity.Id != null){
            p=new pageReference('/'+casActivity.Id);
        }
        else{
            p=new pageReference('/'+activityMaster.Id);
        }
        
        return p;        
    }

}