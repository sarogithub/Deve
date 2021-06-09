public class CaseAssociationsController {
    
    public List<Case_Associate__c> caList {get; set;}
    public Account a;
    public string NewCaseUrl {get; set;}
    
    public CaseAssociationsController(ApexPages.StandardController controller) {
        a=(Account)controller.getRecord();
        caList=[Select Name, Entity1__c, Case_Number__r.Account.Name, Case_Number__r.AccountId, Case_Number__c,
                Case_Number__r.CaseNumber, Case_Number__r.Subject, Case_Number__r.Priority, Case_Number__r.Status,
                Case_Number__r.Owner.Name, Case_Number__r.OwnerId, Case_Number__r.CreatedDate, Case_Number__r.ClosedDate, 
                Case_Number__r.Type, Entity_Type__c, Associate_Type__c 
                FROM Case_Associate__c where Entity1__c=:a.Id Order By CreatedDate];
        NewCaseUrl = URL.getSalesforceBaseUrl().toExternalForm()+'/500/e?def_account_id='+a.Id+'&retURL=/'+a.Id;
    }
    
    public static void createRecord(list<case> caseRec){
        list<Case_Associate__c> CAlist= new list<Case_Associate__c>();
        Case_Associate__c curCA = new Case_Associate__c();
        //list<case> accList= new list<case>([select id,accountid from case where id in:caseRec]);
        list<id> accIds= new list<id>();
        for(case a:caseRec){
            accIds.add(a.accountId);
        }
        map<id,account> acctoRecordTypeMap = new map<id,account>([select id,recordtype.id,recordtype.name from account where id in :accIds]);
        list<RecordType> associationRecordType= new list<RecordType>();
        map<string,id> rmap = new map<String,id>();
        for(RecordType r:[SELECT Name,id FROM RecordType WHERE SobjectType='Case_Associate__c']){
            rmap.put(r.name,r.id);
        }
        
        if(caseRec.size()>0 && caseRec !=null){
            for(case currentCase:caseRec){
                if(currentCase.AccountId != null && rmap.containskey(acctoRecordTypeMap.get(currentCase.AccountId).recordType.name)){
                    curCA.Case_Number__c=currentCase.id;
                    curCA.Associate_Type__c='Primary';
                    curCA.RecordTypeId=(id)rmap.get(acctoRecordTypeMap.get(currentCase.AccountId).recordType.name);
                    curCA.Entity1__c=currentCase.AccountId;
                    CURca.Entity_Type__c=acctoRecordTypeMap.get(currentCase.AccountId).recordType.Name;
                    CAlist.add(curCA);
                    System.debug('Case Association record added to list' +CAlist.size());
                }
            }
            insert CAlist;
            system.debug('Records created' +CAlist.size());
        }
        
    }
}