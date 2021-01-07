public with sharing class ContentDocumentLinkTriggerTrH implements ITriggerHandler {
    public void BeforeInsert(List<SObject> newItems){}
    public void AfterInsert(Map<Id, SObject> newItems){
        List<ContentDocumentLink> contDocList = newItems.values();
        Set<Id> contDocIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        for(ContentDocumentLink contDocItem : contDocList){
            contactIds.add(contDocItem.LinkedEntityId);
            contDocIds.add(contDocItem.ContentDocumentId);
        }
        //add if Contact!!!
        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, FirstName, LastName, Department, Avatar__c FROM Contact WHERE Id IN :contactIds]);
        List<ContentVersion> contVerList = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :contDocIds];//
        for(ContentDocumentLink contDocItem : contDocList){
            for(ContentVersion contVerItem : contVerList){
                if(contVerItem.ContentDocumentId == contDocItem.ContentDocumentId && contactMap.containsKey(contDocItem.LinkedEntityId)){
                    Contact tempContact = contactMap.get(contDocItem.LinkedEntityId);
                    tempContact.Avatar__c = '/sfc/servlet.shepherd/version/download/' + contVerItem.Id;
                }
            }
        }
        update contactMap.values();
    }
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){}
    public void BeforeDelete(Map<Id, SObject> oldItems){}
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){}
    public void AfterDelete(Map<Id, SObject> oldItems){}
    public void AfterUndelete(Map<Id, SObject> oldItems){}
    
}
