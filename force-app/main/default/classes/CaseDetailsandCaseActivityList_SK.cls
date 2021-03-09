@RestResource(urlMapping='/CaseAndActivityDetails/*')
global class CaseDetailsandCaseActivityList_SK{
    
    global class requestWrapper{
        global string caseId {get; set;}
    }
    
    global class ResponseWrapper{
        global List<string> Errors {get; set;}
        global ResponseWrapper(){
            this.Errors =new List<string>();
        }
    }
    
    @HttpPost   
    global static void createNewCase(){
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;
        ResponseWrapper wrapResponse=new ResponseWrapper();
        List<String> errorList=new List<String>();
        Map<string,string> caseFieldMapping = new map<string,string>();
        Map<string,string> activityFieldMapping = new map<string,string>();
        Map<string,Schema.DisplayType> caseFieldTypeMapping = new map<string,Schema.DisplayType>();
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
                        system.debug('req.requestBody -> '+ req.requestBody.toString());
                        requestWrapper wrap = (requestWrapper)JSON.deSerialize(req.requestBody.toString(),requestWrapper.class);
                        system.debug(' wrap -> '+ wrap);
                        map<string,string> caseLayout2RecordTypeId = new map<string,string>();
                        
                        for(Case_RecordType_and_Page_Layout_Mapping__mdt layoutName : [Select Id,Layout_Name__c,Recordtype_Id__c 
                                                                        FROM Case_RecordType_and_Page_Layout_Mapping__mdt]){
                            caseLayout2RecordTypeId.put(layoutName.Recordtype_Id__c,'Case-'+layoutName.Layout_Name__c);    
                        }
                        
                        set<String> caseobjFields = new set<String>();
                        Map<String , Schema.SObjectType> caseglobalDescription = Schema.getGlobalDescribe();
                        Schema.sObjectType caseobjType = caseglobalDescription.get('Case'); 
                        Schema.DescribeSObjectResult caser1 = caseobjType.getDescribe(); 
                        Map<String , Schema.SObjectField> casemapFieldList = caser1.fields.getMap();  
                        
                        for(Schema.SObjectField casefield : casemapFieldList.values())  
                        {  
                            Schema.DescribeFieldResult casefieldResult = casefield.getDescribe();  
                            //if(casefieldResult.isAccessible()){  
                                caseobjFields.add(casefieldResult.getName());
                                String caseFieldlabel = (casefieldResult.getLabel() == 'Owner ID') ? 'Owner Name' : (casefieldResult.getLabel() == 'Created By ID') ? 'Created By' : (casefieldResult.getLabel() == 'Last Modified By ID') ? 'Last Modified By' : (casefieldResult.getLabel() == 'Record Type ID') ? 'Record Type' : casefieldResult.getLabel();

                                caseFieldMapping.put(casefieldResult.getName(),caseFieldlabel );
                                caseFieldTypeMapping.put(casefieldResult.getName(),casefieldResult.getType());
                            //}  
                        }
                        system.debug('caseobjFields '+ caseobjFields);
                        
                        set<String> caseActobjFields = new set<String>();
                        Map<String , Schema.SObjectType> caseActglobalDescription = Schema.getGlobalDescribe();
                        Schema.sObjectType caseActobjType = caseActglobalDescription.get('Case_Activity__c'); 
                        Schema.DescribeSObjectResult caseActr1 = caseActobjType.getDescribe(); 
                        Map<String , Schema.SObjectField> caseActmapFieldList = caseActr1.fields.getMap();  
                        
                        for(Schema.SObjectField caseActfield : caseActmapFieldList.values())  
                        {  
                            Schema.DescribeFieldResult caseActfieldResult = caseActfield.getDescribe();  
                            //if(caseActfieldResult.isAccessible()){  
                                caseActobjFields.add(caseActfieldResult.getName());
                                String caseActFieldlabel = (caseActfieldResult.getLabel() == 'Owner ID') ? 'Owner Name' : (caseActfieldResult.getLabel() == 'Created By ID') ? 'Created By' : (caseActfieldResult.getLabel() == 'Last Modified By ID') ? 'Last Modified By'  : (caseActfieldResult.getLabel() == 'Record Type ID') ? 'Record Type' : caseActfieldResult.getLabel();
                                activityFieldMapping.put(caseActfieldResult.getName(),caseActFieldlabel);
                                activityFieldTypeMapping.put(caseActfieldResult.getName(),caseActfieldResult.getType());
                            //}  
                        }
                        system.debug('caseActobjFields '+ caseActobjFields);
                        string casnu = wrap.CaseId;
                        system.debug('wrap.CaseId '+ wrap.CaseId);
                        
                        string query = 'Select '+ string.join((Iterable<String>)caseobjFields, ',') + ',(Select '+string.join((Iterable<String>)caseActobjFields, ',');
                        query += ' FROM Case_Activities__r) FROM Case WHERE CaseNumber = \''+casnu+'\'';
                        system.debug('query '+ query);
                        
                        List<Case> CaseandActivityList = Database.query(query);
                        List<string> LayoutNames = new List<string>();
                        
                        List<RecordType> rts = [select Id from RecordType where SObjectType = :'Case'];
                        List<String> contactId = new List<String>();
                        
                        if(CaseandActivityList.size()>0){
                            for(Case iCase : CaseandActivityList){
                                contactId.add(iCase.ContactId);
                                if(rts.size()<= 0){
                                    LayoutNames.add(caseLayout2RecordTypeId.get('Default'));
                                }else{
                                    LayoutNames.add(caseLayout2RecordTypeId.get(string.valueof(iCase.get('recordTypeId'))));    
                                }
                            }
                        }
                        
                        map<id,string> contactIdtoString = new map<id,string>();
                        for(Contact irow : [Select Id,Name FROM Contact WHERE Id IN: ContactId]){
                            contactIdtoString.put(irow.Id,irow.Name);
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
                        
                        LayoutNames.add('Case Activity Request');
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
                        system.debug(' userIdtoName '+ userIdtoName);
                        
                        if(CaseandActivityList.size()>0){
                            string response = '{';
                            for(Case iCase : CaseandActivityList){
                                string caseResponse = '';
                                for(string sectionHeader : sectionWithFields.keyset()){
                                    string sectionHeaderValue = sectionHeader;
                                    if(sectionHeader.contains('Dupe')){
                                        sectionHeaderValue = sectionHeader.replace('Dupe','');
                                    }
                                    caseResponse += '"'+sectionHeaderValue+'":{';
                                    for(string fields :sectionWithFields.get(sectionHeader)){
                                        Schema.DisplayType typ = caseFieldTypeMapping.get(fields);
                                        if(typ == Schema.DisplayType.REFERENCE){
                                            string value = (String)iCase.get(fields);
                                            if(value != null){
                                                string fieldValue = (value.startsWith('005')) ? userIdtoName.get(value) : (value.startsWith('003')) ? contactIdtoString.get(value) : value;
                                                caseResponse += '"'+caseFieldMapping.get(fields)+'":'+'"'+ fieldValue +'",'; 
                                            }else{
                                                caseResponse += '"'+caseFieldMapping.get(fields)+'":'+'"'+ iCase.get(fields)+'",'; 
                                            }
                                        }else if(typ == Schema.DisplayType.DATE){
                                            Date dat = (Date)iCase.get(fields);
                                            if(dat != null){
                                                string dt = (((string.valueof(dat.month()).length()<=1) ? '0': '') + dat.month())+'-'+(((string.valueof(dat.day()).length()<=1) ? '0': '') + dat.day())+'-'+dat.year();
                                                if(dat != null){
                                                    caseResponse += '"'+caseFieldMapping.get(fields)+'":'+'"'+ dt+'",'; 
                                                }else{
                                                    caseResponse += '"'+caseFieldMapping.get(fields)+'":'+'"'+ iCase.get(fields)+'",'; 
                                                }
                                            }
                                        }else if(typ == Schema.DisplayType.DATETIME){
                                            Datetime dat = (Datetime)iCase.get(fields);
                                            if(dat != null){
                                                string dt = (((string.valueof(dat.month()).length()<=1) ? '0': '') + dat.month())+'-'+(((string.valueof(dat.day()).length()<=1) ? '0': '') + dat.day())+'-'+dat.year();
                                                if(dat != null){
                                                    caseResponse += '"'+caseFieldMapping.get(fields)+'":'+'"'+ dt+'",'; 
                                                }else{
                                                    caseResponse += '"'+caseFieldMapping.get(fields)+'":'+'"'+ iCase.get(fields)+'",'; 
                                                }                           
                                            }
                                        }else{
                                            caseResponse += '"'+caseFieldMapping.get(fields)+'":'+'"'+ iCase.get(fields)+'",'; 
                                        }
                                    }
                                    caseResponse = caseResponse.substringBeforeLast(',');
                                    caseResponse += '},';
                                }
                                response += caseResponse;
                                if(iCase.Case_Activities__r.size()>0){
                                    response += '"CaseActivityList":[';
                                    for(Case_Activity__c iCaseAct : iCase.Case_Activities__r){
                                        response += '{';
                                        string caseActResponse = '"Id":'+'"'+iCaseAct.get('Id')+'",';
                                        for(string relFields : relatedListFields){
                                            relfields = (relfields == 'NAME')?'Name':relfields;
                                            Schema.DisplayType typ = activityFieldTypeMapping.get(relfields);
                                            if(typ == Schema.DisplayType.REFERENCE){
                                                string value = (String)iCaseAct.get(relfields);
                                                if(value != null){
                                                    string fieldValue = (value.startsWith('005')) ? userIdtoName.get(value) : value;
                                                    caseActResponse += '"'+activityFieldMapping.get(relfields)+'":'+'"'+fieldValue +'",'; 
                                                }else{
                                                    caseActResponse += '"'+activityFieldMapping.get(relfields)+'":'+'"'+iCaseAct.get(relFields)+'",';
                                                }
                                            }else if(typ == Schema.DisplayType.DATE){
                                                Date dat = (Date)iCaseAct.get(relfields);
                                                if(dat != null){
                                                    string dt = (((string.valueof(dat.month()).length()<=1) ? '0': '') + dat.month())+'-'+(((string.valueof(dat.day()).length()<=1) ? '0': '') + dat.day())+'-'+dat.year();
                                                    if(dat != null){
                                                        caseActResponse += '"'+activityFieldMapping.get(relfields)+'":'+'"'+dt+'",'; 
                                                    }else{
                                                        caseActResponse += '"'+activityFieldMapping.get(relfields)+'":'+'"'+iCaseAct.get(relFields)+'",'; 
                                                    }
                                                }else{
                                                    caseActResponse += '"'+activityFieldMapping.get(relfields)+'":'+'"'+iCaseAct.get(relFields)+'",';
                                                }
                                            }else if(typ == Schema.DisplayType.DATETIME){
                                                Datetime dat = (Datetime)iCaseAct.get(relfields);
                                                if(dat != null){
                                                    string dt = (((string.valueof(dat.month()).length()<=1) ? '0': '') + dat.month())+'-'+(((string.valueof(dat.day()).length()<=1) ? '0': '') + dat.day())+'-'+dat.year();
                                                    if(dat != null){
                                                        caseActResponse += '"'+activityFieldMapping.get(relfields)+'":'+'"'+dt+'",'; 
                                                    }else{
                                                        caseActResponse += '"'+activityFieldMapping.get(relfields)+'":'+'"'+iCaseAct.get(relFields)+'",'; 
                                                    }                           
                                                }else{
                                                    caseActResponse += '"'+activityFieldMapping.get(relfields)+'":'+'"'+iCaseAct.get(relFields)+'",';
                                                }
                                            }else{
                                                caseActResponse += '"'+activityFieldMapping.get(relfields)+'":'+'"'+iCaseAct.get(relFields)+'",'; 
                                            }
                                        }
                                        caseActResponse = caseActResponse.substringBeforeLast(',');
                                        response += caseActResponse+'},';
                                    }
                                    response = response.substringBeforeLast(',');
                                    response += ']';
                                }
                            }
                            response += '}';
                            system.debug(' response '+ response);
                            res.statusCode = 200;
                            res.responseBody=Blob.ValueOf(response);
                            //System.JSONParser jsonParser1 = createParser(response);
                            //string str = JSON.stringify(response);
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