@RestResource(urlMapping='/CaseActivityDetails/*')
global class CaseActivity_SK{
    global class requestWrapper{
        global string caseActId {get; set;}
    }
    
    global class ResponseWrapper{
        global List<string> Errors {get; set;}
        global ResponseWrapper(){
            this.Errors =new List<string>();
        }
    }
    
    @HttpPost   
    global static void CaseActivityDetails(){
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;
        ResponseWrapper wrapResponse=new ResponseWrapper();
        List<String> errorList=new List<String>();
        map<string,string> activityFieldMapping = new map<string,string>();
        Map<string,Schema.DisplayType> activityFieldTypeMapping = new map<string,Schema.DisplayType>();
        string errStr;
        
        res.addHeader('Content-Type','application/json');  
        res.addHeader('Access-Control-Allow-Origin', 'http://demo.ecarevantage.com');
        res.addHeader('Access-Control-Allow-Origin', 'http://localhost');
        res.addHeader('Access-Control-Allow-Origin', 'http://uat.ecarevantage.com');
        res.addHeader('Access-Control-Allow-Origin', 'http://htafds.ecarevntage.com');
        res.addHeader('Access-Control-Allow-Origin', 'http://dev.ecarevantage.com');
        res.addHeader('Access-Control-Allow-Origin', 'http://htsfads.ecarevantage.com');
        
        try{
            if(req != null){
                Map<string,string> requestHeaders=req.headers;
                if(requestHeaders != null && requestHeaders.keyset() != null && 
                    requestHeaders.containsKey('Content-Type') && requestHeaders.get('Content-Type') != null &&
                    requestHeaders.get('Content-Type')=='application/json'){
                    if(req.requestBody != null && req.requestBody.toString() != null){
                        requestWrapper wrap = (requestWrapper)JSON.deSerialize(req.requestBody.toString(),requestWrapper.class);
                        system.debug(' wrap -> '+ wrap);
                        map<string,string> caseLayout2RecordTypeId = new map<string,string>();
                        
                        for(Activity_RecordType_and_Page_Layout_Map__mdt layoutName : [Select Id,Layout_Name__c,Recordtype_Id__c 
                                                                        FROM Activity_RecordType_and_Page_Layout_Map__mdt]){
                            caseLayout2RecordTypeId.put(layoutName.Recordtype_Id__c,'Case_Activity__c-'+layoutName.Layout_Name__c);    
                        }
                        
                        set<String> caseActobjFields = new set<String>();
                        Map<String , Schema.SObjectType> caseActglobalDescription = Schema.getGlobalDescribe();
                        Schema.sObjectType caseActobjType = caseActglobalDescription.get('Case_Activity__c'); 
                        Schema.DescribeSObjectResult caseActr1 = caseActobjType.getDescribe(); 
                        Map<String , Schema.SObjectField> caseActmapFieldList = caseActr1.fields.getMap();  
                        
                        for(Schema.SObjectField caseActfield : caseActmapFieldList.values()){  
                            Schema.DescribeFieldResult caseActfieldResult = caseActfield.getDescribe();  
                            //if(caseActfieldResult.isAccessible()){  
                                caseActobjFields.add(caseActfieldResult.getName());
                                String caseActFieldlabel = (caseActfieldResult.getLabel() == 'Owner ID') ? 'Owner Name' : (caseActfieldResult.getLabel() == 'Created By ID') ? 'Created By' : (caseActfieldResult.getLabel() == 'Last Modified By ID') ? 'Last Modified By' : (caseActfieldResult.getLabel() == 'Record Type ID') ? 'Record Type' : caseActfieldResult.getLabel();
                                activityFieldMapping.put(caseActfieldResult.getName(),caseActFieldlabel);
                                activityFieldTypeMapping.put(caseActfieldResult.getName(),caseActfieldResult.getType());
                            //}  
                        }
                        system.debug('caseActobjFields '+ caseActobjFields);
                        string casAct = wrap.caseActId;
                        system.debug('wrap.CaseId '+ wrap.caseActId);
                        
                        string query = 'Select '+ string.join((Iterable<String>)caseActobjFields, ',')+ ' FROM Case_Activity__c WHERE Id = \''+casAct+'\'';
                        system.debug('query '+ query);
                        
                        List<Case_Activity__c> CaseActivityList = Database.query(query);
                        List<string> LayoutNames = new List<string>();
                        
                        List<RecordType> rts = [select Id,Name from RecordType where SObjectType = :'Case_Activity__c'];
                        map<string,string> recordTypeId2Name = new Map<string,string>();
                        for(RecordType irow : rts){
                            recordTypeId2Name.put(irow.Id,irow.Name);
                        }
                        
                        List<Id> CaseId = new List<Id>();
                        Map<Id, String> caseId2Number = new map<Id,string>();
                        
                        if(CaseActivityList.size()>0){
                            for(Case_Activity__c iCase : CaseActivityList){
                                CaseId.add(iCase.Case__c);
                                if(rts.size()<= 0){
                                    LayoutNames.add(caseLayout2RecordTypeId.get('Default'));
                                }else{
                                    LayoutNames.add(caseLayout2RecordTypeId.get(string.valueof(iCase.get('recordTypeId'))));    
                                }
                            }
                        }
                        
                        for(Case irow : [Select Id, CaseNumber FROM Case WHERE Id IN: CaseId]){
                            caseId2Number.put(irow.Id,irow.CaseNumber);
                        }
                                                
                        map<Id, String> userIdtoName = new map<Id, String>();
                        for(User irow : [Select Id, FirstName, LastName FROM User WHERE isActive = TRUE]){
                            string fullName;
                            if(irow.FirstName != null){
                                fullName = irow.FirstName+ ' ' +irow.LastName;
                            }else{
                                fullName = irow.LastName;
                            }
                            userIdtoName.put(irow.id,fullName);
                        }
                        
                        //LayoutNames.add('Case_Activity__c-Request for Document');
                        system.debug(' caseLayout2RecordTypeId '+ caseLayout2RecordTypeId);
                        system.debug(' LayoutNames '+ LayoutNames);
                        
                        List<Metadata.Metadata> components = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, LayoutNames);
                        
                        Metadata.Layout caseLayout = (Metadata.Layout)components.get(0);
                        List<Metadata.LayoutSection> layoutSections = caseLayout.LayoutSections;
                        List<Metadata.LayoutSection> layoutSectionsCustom = layoutSections;
                        List<Metadata.RelatedListItem> RelatedListItemCustom = caseLayout.relatedLists;
                        List<string> relatedListFields = new List<string>();
                        
                        for(Metadata.RelatedListItem relatedList : RelatedListItemCustom){
                            if(relatedList.relatedList == 'Case_Activity__c.Case__c'){
                                system.debug('relatedList  '+ relatedList.fields);
                                relatedListFields.addall(relatedList.fields);
                            }
                        }
                        
                        List<String> sectionNames = new List<String>();
                        Map<string, list<string>> sectionWithFields= new map<string,list<string>>();
                        for(Metadata.LayoutSection irow : layoutSectionsCustom){
                            if(sectionNames.contains(irow.Label)){
                                irow.Label = irow.Label+' Dupe';    
                            }
                            sectionNames.add(irow.Label);
                            for(Metadata.layoutColumn jrow : irow.layoutColumns){
                                if(jrow.layoutItems != null){
                                    for(Metadata.layoutItem krow : jrow.layoutItems){
                                        if(sectionWithFields.containsKey(irow.label)){
                                            List<string> fields = sectionWithFields.get(irow.label);
                                            fields.add(krow.field);
                                            sectionWithFields.put(irow.label, fields);
                                        }else{
                                            List<string> fields = new list<string>();
                                            fields.add(krow.field);
                                            sectionWithFields.put(irow.label, fields);
                                        }
                                    }
                                }
                            }
                        }
                        system.debug(' sectionWithFields '+ sectionWithFields);
                        system.debug(' activityFieldMapping '+ activityFieldMapping);
                        
                        if(CaseActivityList.size()>0){
                            string response = '{';
                            for(Case_Activity__c iCase : CaseActivityList){
                                string caseResponse = '';
                                for(string sectionHeader : sectionWithFields.keyset()){
                                    string sectionHeaderValue = sectionHeader;
                                    if(sectionHeader.contains('Dupe')){
                                        sectionHeaderValue = sectionHeader.replace('Dupe','');
                                    }
                                    caseResponse += '"'+sectionHeaderValue+'":{';
                                    for(string fields :sectionWithFields.get(sectionHeader)){
                                        if(fields != null){
                                            if(iCase.get(fields) != null){
                                                fields = (fields == 'NAME')?'Name':fields;
                                                Schema.DisplayType typ = activityFieldTypeMapping.get(fields);
                                                
                                                if(typ == Schema.DisplayType.REFERENCE){
                                                    string value = (String)iCase.get(fields);
                                                    if(value != null){
                                                        string fieldValue = (value.startsWith('005')) ? userIdtoName.get(value) : (value.startsWith('012')) ? recordTypeId2Name.get(value) : (value.startsWith('500')) ? caseId2Number.get(value) : value;
                                                        caseResponse += '"'+activityFieldMapping.get(fields)+'":'+'"'+fieldValue +'",'; 
                                                    }else{
                                                        caseResponse += '"'+activityFieldMapping.get(fields)+'":'+'"'+iCase.get(Fields)+'",';
                                                    }
                                                }else if(typ == Schema.DisplayType.DATE){
                                                    Date dat = (Date)iCase.get(fields);
                                                    if(dat != null){
                                                        string dt = (((string.valueof(dat.month()).length()<=1) ? '0': '') + dat.month())+'-'+(((string.valueof(dat.day()).length()<=1) ? '0': '') + dat.day())+'-'+dat.year();
                                                        if(dat != null){
                                                            caseResponse += '"'+activityFieldMapping.get(fields)+'":'+'"'+dt+'",'; 
                                                        }else{
                                                            caseResponse += '"'+activityFieldMapping.get(fields)+'":'+'"'+iCase.get(Fields)+'",'; 
                                                        }
                                                    }
                                                }else if(typ == Schema.DisplayType.DATETIME){
                                                    Datetime dat = (Datetime)iCase.get(fields);
                                                    if(dat != null){
                                                        string dt = (((string.valueof(dat.month()).length()<=1) ? '0': '') + dat.month())+'-'+(((string.valueof(dat.day()).length()<=1) ? '0': '') + dat.day())+'-'+dat.year();
                                                        if(dat != null){
                                                            caseResponse += '"'+activityFieldMapping.get(fields)+'":'+'"'+dt+'",'; 
                                                        }else{
                                                            caseResponse += '"'+activityFieldMapping.get(fields)+'":'+'"'+iCase.get(Fields)+'",'; 
                                                        }                           
                                                    }
                                                }else{
                                                    caseResponse += '"'+activityFieldMapping.get(fields)+'":'+'"'+iCase.get(Fields)+'",';
                                                }
                                            }else{
                                                caseResponse += '"'+activityFieldMapping.get(fields)+'":'+'"'+iCase.get(Fields)+'",';
                                            }
                                        }
                                    }
                                    caseResponse = caseResponse.substringBeforeLast(',');
                                    caseResponse += '},';
                                }
                                caseResponse = caseResponse.substringBeforeLast(',');
                                response += caseResponse;
                            }
                            response += '}';
                            system.debug(' response '+ response);
                            res.statusCode = 200;
                            res.responseBody=Blob.ValueOf(response);
                        }else{
                            res.statusCode=205;
                            errorList.add('No Case Found. Please pass correct case Id');
                            wrapResponse.Errors=errorList;                        
                            errStr=JSON.Serialize(wrapResponse);
                            res.responseBody=Blob.ValueOf(errStr);    
                        }
                    }else{
                        res.statusCode=204;
                        errorList.add('No body content found in the request json');
                        wrapResponse.Errors=errorList;                        
                        errStr=JSON.Serialize(wrapResponse);
                        res.responseBody=Blob.ValueOf(errStr);
                    }
                }else{
                    res.statusCode=406;
                    errorList.add('Valid headers not found in request sent.');
                    wrapResponse.Errors=errorList;                        
                    errStr=JSON.Serialize(wrapResponse);
                    res.responseBody=Blob.ValueOf(errStr); 
                }
            }
        }Catch(Exception ex){            
            res.statusCode=500;
            errorList.add('Exception: '+ex.getMessage()+', Failure Trace: '+ex.getStackTraceString());
            wrapResponse.Errors=errorList;
            errStr=JSON.Serialize(wrapResponse); 
            res.responseBody=Blob.ValueOf(errStr);  
        }
    }
}