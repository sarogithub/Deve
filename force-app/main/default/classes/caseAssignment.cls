/* 
Created By   : Orbit Team - Soundar
Date         : 10/10/2017
Description  : For Custom Function (Update a RecordType in visualforce page for manually choosing record type in visualforce page).
last Updated : By Soundar On 11/10/2017 
*/


public class caseAssignment{
    //Variables
    Public Case_Associate__c str;
    public ApexPages.StandardController controller;
    Public String recType{get;set;}
    Private final Case_Associate__c caseSense;
    Public Boolean section;
    public map<string,string> mp_RCnme2RCId = new map<string,string>();
    
    //Constructor | Passing Case Number Into case Associate
    public caseAssignment(ApexPages.StandardController controller) {
        for(RecordType sRecordType : [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Case_Associate__c'])
        {
            mp_RCnme2RCId.put(sRecordType.Name,sRecordType.Id);
        }
        
        this.caseSense = (Case_Associate__c)controller.getRecord();
        caseSense.Case_Number__c = ApexPages.currentPage().getParameters().get('C_A_ID');
        // caseSense.OwnerId = ApexPages.currentPage().getParameters().get('Own');
        system.debug('recType ***** |' + recType);
    }
    
    public PageReference test() {
        return null;
    }
    
    //Get Record Type & Display in VF Pages
    public List<SelectOption> GetRecordTypes() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('--None--','--None--'));
        for(RecordType sRecordType : [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Case_Associate__c'])
        {
            options.add(new SelectOption(sRecordType.Id, sRecordType.Name));
            mp_RCnme2RCId.put(sRecordType.Name,sRecordType.Id);
        }
        system.debug('Options | ' + options);
        return options;
    }
    
    //Update Record Type
    Public void updateRecordType(){
        system.debug('*******  Starting ******'+ caseSense.Entity_Type__c);
        system.debug('*******  mp_RCnme2RCId ******'+ mp_RCnme2RCId);
        system.debug('*******  Contains ******'+ mp_RCnme2RCId.containskey(caseSense.Entity_Type__c));
        
        recType ='';
        if(caseSense.Entity_Type__c != NULL && caseSense.Entity_Type__c != ''){
            if(mp_RCnme2RCId.containskey(caseSense.Entity_Type__c)){
                recType = caseSense.recordTypeId = mp_RCnme2RCId.get(caseSense.Entity_Type__c);
            } 
        }
        
        System.debug(' ***recordTypeId *** ' + recType + '|' +  caseSense.recordTypeId);
        system.debug('recType ***** |' + recType);
    }
    public pageReference Cancel(){
        PageReference pg = new Pagereference('/'+ ApexPages.currentPage().getParameters().get('C_A_ID'));
        return pg;
    }
    
}