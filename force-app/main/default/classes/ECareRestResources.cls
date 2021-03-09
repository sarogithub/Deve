@RestResource(urlMapping='/casecreation/*')
global class ECareRestResources{

    global class CaseWrapper{
        global string CaseName {get; set;}
        global string CaseType {get; set;}
        global string CaseReason {get; set;}
        global string ProgramName {get; set;}
        global string CaseStatus {get; set;}
        global string description {get; set;}
        global List<entities> Entities {get; set;}
    }
    
    global class entities{
        global string Name;
        global string EntityType;
        global string EntityId;
        global string Associationtype;
        global string ClaimSubmittedDate;
        global string MemberEntityId;
        global string ProviderEntityId;
        global Decimal BilledAmount;
        global Decimal PaidAmount;
        global string ClaimStatus;
    }
    
    global class ResponseWrapper{
        global string CaseId {get; set;}
        global string CaseNumber {get; set;}
        global List<string> Errors {get; set;}
        
        global ResponseWrapper(){
            this.Errors =new List<string>();
        }
    }
    
    @HttpPost   
    global static void createNewCase( ) {
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;
        String resStr='';
        List<String> errorList=new List<String>();
        
        res.addHeader('Content-Type','application/json');  
        res.addHeader('Access-Control-Allow-Origin', 'http://demo.ecarevantage.com');
        res.addHeader('Access-Control-Allow-Origin', 'http://localhost');
        res.addHeader('Access-Control-Allow-Origin', 'http://uat.ecarevantage.com');
        res.addHeader('Access-Control-Allow-Origin', 'http://htafds.ecarevntage.com');
        res.addHeader('Access-Control-Allow-Origin', 'http://dev.ecarevantage.com');
        res.addHeader('Access-Control-Allow-Origin', 'http://htsfads.ecarevantage.com');        
                                                  
        ResponseWrapper wrapResponse=new ResponseWrapper();
        Map<String,Id> RtMap=new Map<String,Id>();
        Map<String,ECareRestResources.entities> entityMap=new Map<String,ECareRestResources.entities>();
        Map<String,string> entityIds=new Map<String,String>();        
        
        for(RecordType rt:[select id,name,IsPersonType, SobjectType from recordtype where SobjectType='Account']){
            RtMap.put(rt.name,rt.Id);
        }
        
        try{
            if(req != null){
                Map<string,string> requestHeaders=req.headers;
                if(requestHeaders != null && requestHeaders.keyset() != null && requestHeaders.containsKey('Content-Type') && requestHeaders.get('Content-Type') != null && requestHeaders.get('Content-Type')=='application/json'){
                    if(req.requestBody != null && req.requestBody.toString() != null){
                        CaseWrapper cw=(CaseWrapper)JSON.deSerialize(req.requestBody.toString(),CaseWrapper.class);
                        if(cw != null){
                            Case newCase=new Case();
                            newCase.Case_Name__c=cw.CaseName;
                            newCase.Type=cw.CaseType;
                            newCase.Reason=cw.CaseReason;
                            newCase.Program_Name__c=cw.ProgramName;
                            newCase.Status=cw.CaseStatus;
                            newCase.description=cw.description;
                            newCase.Origin='Referral';  
                            
                            insert newCase;
                            newCase=[select id,caseNumber from Case where Id=:newCase.Id];
                            
                            List<Case_Associate__c> caseAssociation=new List<Case_Associate__c>();
                            Map<String,Id> entityIdWithSFMap=new Map<String,Id>();
                            List<Account> entitiesToUpsert=new List<Account>();
                            
                            if(cw.Entities != null && cw.Entities.size() >0){
                                for(ECareRestResources.entities cs:cw.Entities){
                                    if(cs.EntityId != null && cs.EntityId != ''){
                                        if(cs.EntityType != null && cs.EntityType != ''){
                                            Account entityEach=new Account(Entity_Id__c=cs.EntityId,Entity_Type__c=cs.EntityType,RecordTypeId=RtMap.get(cs.EntityType),lastname=cs.Name);
                                            if(cs.EntityType == 'Claims'){
                                                entityMap.put(cs.EntityId,cs);
                                                if(cs.ClaimSubmittedDate != null){
                                                    try{
                                                        entityEach.Submitted_date__c=Date.parse(cs.ClaimSubmittedDate);
                                                    }
                                                    Catch(Exception ex){
                                                        errorList.add('Incorrect Claim Entity\'s Submitted date format. Use mm-dd-yyyy format.');
                                                    }
                                                }
                                                if(cs.BilledAmount != null){
                                                    try{
                                                        entityEach.Billed_amount__c=cs.BilledAmount;
                                                    }
                                                    Catch(Exception ex){
                                                        errorList.add('Incorrect format on billed amount.');
                                                    }
                                                }
                                                if(cs.PaidAmount != null){
                                                    try{
                                                        entityEach.Paid_Amount__c=cs.PaidAmount;
                                                    }
                                                    Catch(Exception ex){
                                                        errorList.add('Incorrect format on paid amount.');
                                                    }
                                                }
                                                entityEach.Status__c=cs.ClaimStatus;
                                                if(cs.MemberEntityId != null){
                                                    //entityEach.Member__c=cs.MemberEntityId ;
                                                    entityIds.put(cs.MemberEntityId,null);
                                                }
                                                if(cs.ProviderEntityId != null){
                                                    //entityEach.Provider__c=cs.ProviderEntityId ;
                                                    entityIds.put(cs.ProviderEntityId,null);
                                                }
                                                entitiesToUpsert.add(entityEach);                                           
                                            }
                                            else{
                                                entitiesToUpsert.add(entityEach);
                                            }
                                        }
                                        else{
                                            errorList.add('Entity type is blank for one/more entities sent.');
                                        }
                                    }
                                    else{
                                        errorList.add('Entity ID is blank for one/more entities sent.');
                                    }
                                }
                                
                                if(errorList.size() ==0 && entitiesToUpsert.size() >0){
                                     upsert entitiesToUpsert Entity_Id__c;
                                     if(entityIds.keyset() != null && entityIds.keyset().size() >0){
                                        for(account a:[select id,Entity_Id__c from account where Entity_Id__c IN:entityIds.keyset()]){
                                            entityIds.put(a.Entity_Id__c,a.id);
                                        }
                                        
                                        List<Account> accList=new List<Account>();
                                        for(ECareRestResources.entities e:entityMap.values()){
                                            Account acc=new Account();
                                            acc.Entity_Id__c=e.EntityId;
                                            if(e.MemberEntityId != null && entityIds.containsKey(e.MemberEntityId)){
                                                acc.Member__c=entityIds.get(e.MemberEntityId);
                                            }
                                            if(e.ProviderEntityId != null && entityIds.containsKey(e.ProviderEntityId)){
                                                acc.Provider__c=entityIds.get(e.ProviderEntityId);
                                            }
                                            accList.add(acc);
                                        }
                                        if(accList.size() >0 ){
                                            upsert accList Entity_Id__c;
                                        }
                                     }
                                     for(Account a:entitiesToUpsert){
                                         entityIdWithSFMap.put(a.Entity_Id__c,a.Id);
                                     }
                                     
                                     for(ECareRestResources.entities cs:cw.Entities){
                                        if(entityIdWithSFMap.containsKey(cs.EntityId) && entityIdWithSFMap.get(cs.EntityId) != null){
                                            caseAssociation.add(new Case_Associate__c(Entity1__c=entityIdWithSFMap.get(cs.EntityId),Case_Number__c=newCase.Id,Associate_Type__c=cs.Associationtype,Entity_Type__c=cs.EntityType));
                                        }
                                     }
                                     
                                     if(caseAssociation.size() >0){
                                         insert caseAssociation;
                                     }
                                }
                            }
                            res.statusCode=200;
                            wrapResponse.CaseId=newCase.Id;
                            wrapResponse.CaseNumber=newCase.caseNumber;
                            wrapResponse.Errors=errorList;
                            
                            resStr=JSON.Serialize(wrapResponse);
                            res.responseBody=Blob.ValueOf(resStr);                         
                        }
                    }
                    else{
                        res.statusCode=204;
                        wrapResponse.CaseId=null;
                        wrapResponse.CaseNumber=null;
                        errorList.add('No body content found in the request json');
                        wrapResponse.Errors=errorList;                        
                        resStr=JSON.Serialize(wrapResponse);
                        res.responseBody=Blob.ValueOf(resStr); 
                    }
                }
                else{
                    res.statusCode=406;
                    wrapResponse.CaseId=null;
                    wrapResponse.CaseNumber=null;
                    errorList.add('Valid headers not found in request sent.');
                    wrapResponse.Errors=errorList;                        
                    resStr=JSON.Serialize(wrapResponse);
                    res.responseBody=Blob.ValueOf(resStr); 
                }
            }
        }
        Catch(Exception ex){            
            res.statusCode=500;
            wrapResponse.CaseId=null;
            wrapResponse.CaseNumber=null;
            errorList.add('Exception: '+ex.getMessage()+', Failure Trace: '+ex.getStackTraceString());
            wrapResponse.Errors=errorList;
            resStr=JSON.Serialize(wrapResponse); 
            res.responseBody=Blob.ValueOf(resStr);  
        }        
    }
}