@IsTest    
Public class TestTriggerCaseActivity {

    public Static testMethod void CaseAssociate(){
    
    //insert Case//
    Case case1 = new Case(Case_Name__c='TestCase1', Type='Provider Audit-Onsite', Status='Initated', Priority='P1',  Origin='Data Mining');
    insert case1;
    
    Case_Activity__c ca1 = new Case_Activity__c(Case_Activity_Type__c='Schedule Audit', Name='Schedule Audit', Status__c='Not Started', Case__c=case1.Id);
    insert ca1;
    
    ca1.Activity_Start_Date__c = system.today();
    ca1.Activity_End_Date__c = system.today()+1;
    update ca1; 
    
    List<Case_Activity__c> lstCaseActi = new List<Case_Activity__c>();
    Case_Activity__c objca;
    
    objca = new Case_Activity__c(Case__c = case1.id, Case_Activity_Type__c='Perform Provider & Claims Data Research', Name='1:Perform Provider & Claims Data Research', Status__c='Not Started');
    lstCaseActi.add(objca);
    objca = new Case_Activity__c(Case__c = case1.id, Case_Activity_Type__c='Perform Initial Risk Assessment', Name='2:Perform Initial Risk Assessment', Status__c='Not Started');
    lstCaseActi.add(objca);
    objca = new Case_Activity__c(Case__c = case1.id, Case_Activity_Type__c='Perform Detailed Risk Assessment', Name='3:Perform Detailed Risk Assessment', Status__c='Not Started');
    lstCaseActi.add(objca);
    objca= new Case_Activity__c(Case__c = case1.id, Case_Activity_Type__c='Identify Samples for Audit', Name='4:Identify Samples for Audit', Status__c='Not Started');
    lstCaseActi.add(objca);
    objca = new Case_Activity__c(Case__c = case1.id, Case_Activity_Type__c='Schedule Audit', Name='5:Schedule Audit', Status__c='Not Started');
    lstCaseActi.add(objca);
    objca = new Case_Activity__c(Case__c = case1.id, Case_Activity_Type__c='Perform Audit', Name='6:Perform Audit', Status__c='Not Started');
    lstCaseActi.add(objca);
    objca = new Case_Activity__c(Case__c = case1.id, Case_Activity_Type__c='Compile Audit Findings', Name='7:Compile Audit Findings', Status__c='Not Started');
    lstCaseActi.add(objca);
    
    insert lstCaseActi;
    
    Test.StartTest();
    for(Case_Activity__c irow: lstCaseActi)
    {    
        if(irow.Case_Activity_Type__c =='Perform Initial Risk Assessment'){
            irow.Activity_Business_Status__c = 'Initial Risk Score – Low';
            
        }
        //update irow;
    }   
    Test.StopTest(); 
    }

}