@isTest(seeAlldata=true)
private class redirectToSampleActivityControllerTest{
    
    private testmethod static void redirectToSampleActivityControllerTest(){
        refreshActivityMaster.refreshActivityList();
        
        Activity_Master__c  act=[SELECT Id,Name from Activity_Master__c limit 1];
        
        Test.setCurrentpage(Page.redirectToSampleActivity);
        Apexpages.StandardController s=new Apexpages.StandardController(act);
        redirectToSampleActivityController re=new redirectToSampleActivityController(s);
        re.reDirectToActivity();
    }
    
    private testmethod static void redirectToSampleActivityControllerTest1(){
        refreshActivityMaster.refreshActivityList();
        
        Activity_Master__c  act=[SELECT Id,Name from Activity_Master__c limit 1];
        Case c=new Case(Case_name__c='Sample Case',Program_Name__c='Test');
        insert c;
        
        Test.setCurrentpage(Page.redirectToSampleActivity);
        Apexpages.StandardController s=new Apexpages.StandardController(act);
        redirectToSampleActivityController re=new redirectToSampleActivityController(s);
        re.reDirectToActivity();
    }
    
    private testmethod static void EditActivityRedirectControllerTest(){
        Case_Activity__c ac=[select id from Case_Activity__c order by createddate desc limit 1];
        
        Test.setCurrentpage(Page.EditActivityRedirect);
        Apexpages.StandardController s=new Apexpages.StandardController(ac);
        EditActivityRedirectController re=new EditActivityRedirectController(s);
        re.setRedirect();
        try{
        ac.status__c='Completed';
        update ac;
        }
        Catch(Exception e){
        
        }
    }
}