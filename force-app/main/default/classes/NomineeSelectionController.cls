public with sharing class NomineeSelectionController {

    @AuraEnabled (cacheable = true)
    public static List<Contact> getContactList(String queryTerm) {
        List<Contact> contacts = (Contact[]) [FIND :queryTerm IN NAME FIELDS RETURNING Contact(FirstName,LastName,Department)][0];
        return contacts;
    }

    @AuraEnabled(cacheable=true)
    public static List<Nomination__c> getNominationList(Id campaign){
        List<Nomination__c> nominations = [SELECT Id, Name FROM Nomination__c WHERE CampaignId__c = :campaign];
        return nominations;
    }

    @AuraEnabled(cacheable=true)
    public static List<Campaign> getCampaignList(){
        return [SELECT Id, Name FROM Campaign WHERE Type = 'Voting' AND IsActive = true];
    }

    @AuraEnabled
    public static void createNominee(Id nominationId, Id contactId, String description) {
        CandidateNomination__c newNominee = new CandidateNomination__c(NominationId__c = nominationId, Nominees__c = contactId, Description__c = description);
        insert newNominee;
    }
}