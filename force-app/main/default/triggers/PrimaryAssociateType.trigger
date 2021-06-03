/* 
Name          : PrimaryAssociateType
Description   : Only one Primary available in Associate Type
Created By    : OrbitTeam_Soundar
Created Date  : 02/11/2017 
*/
trigger PrimaryAssociateType on Case_Associate__c (Before Insert, After Insert) {
    
    Set<Id> caseId = New Set<Id>();
    set<Id> caseId1 = New Set<Id>();
    List<case> updtCon = New List<case>();
    Map<Id,Case_Associate__c> casMap  = New Map<Id,Case_Associate__c>();
    Map<Id,Case_Associate__c> accMap = New Map<Id,Case_Associate__c>();
    List<Case_Activity__c> caActLsit1 = New List<Case_Activity__c>();
    
    /*Restriction Error : Don't create Primary Associate Type more than one time */
    if(Trigger.isBefore && Trigger.isInsert){
        For(Case_Associate__c  ca : Trigger.New){
            If(ca.Case_Number__c != Null){
                CaseId.add(ca.Case_Number__c);
                System.debug('Case Number | ' + CaseId);
            }
        }
        
        IF(CaseId.size() > 0){
            List<Case_Associate__c> cas = [Select id,name,Case_Number__c,Associate_Type__c from Case_Associate__c Where Case_Number__c =:CaseId AND Associate_Type__c = 'Primary'];
            System.debug('Case Associate Type With Primary |' + cas);
            System.debug('Size Of Primary | ' + cas.Size());
            Case_Associate__c cast1 = New Case_Associate__c();
            String curPage = (ApexPages.currentPage() != null ? ApexPages.currentPage().getUrl() : null);
            IF(curPage != null && cas.Size() > 0 && curPage.contains('Primary')){
                System.debug('Primary is Already Created');
                for(Case_Associate__c  cas1 : Trigger.New){
                    cas1.addError('Primary Associate Type was Already Created. So Please Choose "Secondary" or "Other" ');
                } 
            } else if(curPage != null) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Case Associate Created Successfully'));
                System.debug('Secondary || Other');
            }
        }
    }
    
    /*Update Contact in case from Case Associate when Entity Type = Provider & Associate Type = Primary */
    if(Trigger.isAfter && Trigger.isInsert){  
        For(Case_Associate__c ca1 : Trigger.New){
            //IF(ca1.Case_Number__c != Null && ca1.Entity_Type__c == 'Provider' && ca1.Associate_Type__c == 'Primary' ){
            IF(ca1.Case_Number__c != Null && ca1.Associate_Type__c == 'Primary' ){
                accMap.put(ca1.Entity1__c,ca1);
                caseId1.add(ca1.Case_Number__c);
                casMap.put(ca1.Case_Number__c,ca1);
                System.debug('Case Number 1 | ' + caseId1);
            }
        } 
        
        System.debug('caseId1.size() | ' + caseId1.size());
        IF(caseId1.size() > 0){
            map<string, contact> mp = new  map<string, contact>();
            for(contact jrow : [Select id,firstName, LastName,AccountId from Contact Where accountId IN :accMap.keySet()]){
                mp.put(jrow.accountid, jrow);
                
            }
            for(String irow : casMap.keySet()){
                Case c = New Case(id=irow);
                System.debug('&&&&&&& irow |'+ irow);
                c.ContactID = (casMap.containsKey(irow) && casMap.get(irow) != null && casMap.get(irow).Entity1__c != null && mp.containsKey(casMap.get(irow).Entity1__c) && mp.get(casMap.get(irow).Entity1__c) !=null) ? mp.get(casMap.get(irow).Entity1__c).id : null;
                system.debug('Contact Id |' + c.ContactId);
                updtCon.add(c);
                
            }
            System.debug('&&&&&&&&&  Size Of updtCon |' + updtCon.size());
            If(updtCon.size() > 0){
                Update updtcon;
            }
            //Update Email Id to All Activities From Case.
            Case cs = [Select id,Case_Name__c,ContactEmail from Case Where ID In:caseId1];
            /*List<Case_Activity__c> casActList = [Select id,name,Case__c,Provider_Email__c from Case_Activity__c Where Case__c IN: caseId1];
            for(Case_Activity__c caAct : casActList){
                caAct.Provider_Email__c = cs.ContactEmail;
                caActLsit1.add(caAct);
            }
            
            If(caActLsit1.size() > 0){
                Update caActLsit1;
            }*/
        }
    }
}