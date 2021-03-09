public class EditActivityRedirectController {

    public Case_Activity__c activity {get; set;}
    
    public EditActivityRedirectController(ApexPages.StandardController controller) {activity = (Case_Activity__c)controller.getRecord();activity = [select id,IsEnabled__c,createdDate,case__r.type from Case_Activity__c where id=:activity.Id];
    }
    
    public pageReference setRedirect(){
        Datetime tym=Date.newInstance(2018,6,27);if(activity != null && activity.isEnabled__c==false && activity.createdDate > tym && activity.case__r.type=='Provider Audit New'){ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You cannot start working this activity until the pending actions taken on other activities.'));return null;}pageReference p=new pageReference('/'+activity.id+'/e?nooverride=1&retURL=/'+activity.id);p.setRedirect(true);return p;
    }

}