public with sharing class ContentDocLinkTriggerCtrl {
    public static void updateCaseInContentVersion(List<sObject> newRecordsList, System.TriggerOperation event) {
        System.debug(' newRecordsList ' + newRecordsList);
        Map<Id, Id> mapCaseIdToContentDocuemt = new Map<Id, Id>();

        for(ContentDocumentLink contLink : (List<ContentDocumentLink>)newRecordsList){
            String sObjName = contLink.LinkedEntityId.getSObjectType().getDescribe().getName();
            if(sObjName == 'Case'){
                mapCaseIdToContentDocuemt.put(contLink.ContentDocumentId, contLink.LinkedEntityId);
            }
        }

        System.debug(' mapCaseIdToContentDocuemt ' + mapCaseIdToContentDocuemt);

        if(mapCaseIdToContentDocuemt.size() > 0){
            List<ContentVersion> contVerList = new List<ContentVersion>(); 
            for(ContentVersion conVer : [SELECT Id, ContentDocumentId, Case__c FROM ContentVersion 
                WHERE ContentDocumentId IN: mapCaseIdToContentDocuemt.keySet()]){
                    conVer.Case__c = mapCaseIdToContentDocuemt.get(conVer.ContentDocumentId);
                    contVerList.add(conVer);
            }

            if(contVerList.size() > 0){
                update contVerList;
            }
        }
    }
}
