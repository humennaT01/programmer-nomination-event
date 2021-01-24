public with sharing class ContactTrH extends ITriggerHandler {
    public override void BeforeInsert(List<SObject> newRecord) {
        Blob b;
        String h;
        String guid;
        for(Contact contactItem : (List<Contact>)newRecord){
            b = Crypto.GenerateAESKey(128);
            h = EncodingUtil.ConvertTohex(b);
            guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
            contactItem.UUID__c = guid;
        }
    }
}
