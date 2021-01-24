@isTest
public with sharing class NomineeSelectionControllerTest {

    @TestSetup
    static void makeData(){
        Campaign campaign = ModelUtils.buildCampaign();
        insert campaign;
        System.debug('campaign = ' + campaign);
        Nomination__c nomination = ModelUtils.buildNomination(campaign);
        insert nomination;
        System.debug('nomination = ' + nomination);
        Contact contact = ModelUtils.buildContact();
        insert contact;
    }
    @isTest
    static void testGetContactByName() {
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(LastName = 'Jonson', FirstName = 'TestName'));
        contacts.add(new Contact(LastName = 'Branson', FirstName = 'Alice'));
        Contact testContact = [SELECT LastName FROM Contact WHERE Name = 'Test LastName'];
        Test.startTest();
        List<Database.SaveResult> results = Database.insert(contacts, false);
        Contact[] resultContacts = NomineeSelectionController.getContactList('Test');
        Test.stopTest();
        for(Database.SaveResult result : results){
            System.assert(result.isSuccess());
        }
        System.assertEquals(2, resultContacts.size());
        System.assertEquals(true, resultContacts.contains(testContact));
    } 
    @isTest
    static void testGetNominationList() {
        Campaign newCampaign = new Campaign(Name='Test New Campaign', Type='Voting', IsActive=true);
        insert newCampaign;
        Nomination__c newNomination = new Nomination__c(CampaignId__c=newCampaign.Id, Name='Test New Nomination');
        insert newNomination;
        Campaign testCampaign = [SELECT Id FROM Campaign WHERE Name = 'Test Campaign'];
        Test.startTest(); 
        List<Nomination__c> nominations = NomineeSelectionController.getNominationList(testCampaign.Id);
        Test.stopTest();
        System.assertEquals(1, nominations.size());
    }
    @isTest
    static void testGetCampaignList() {
        Campaign newCampaign = new Campaign(Name='Test  New Campaign', Type='Webinar', IsActive=false);
        insert newCampaign;
        Test.startTest();
        List<Campaign> campaignList = NomineeSelectionController.getCampaignList();
        Test.stopTest();
        System.assertEquals(1, campaignList.size());
    }
    @isTest
    static void testCreateNominee() {
        Nomination__c testNomination = [SELECT Id FROM Nomination__c];
        Contact testContact = [SELECT Id FROM Contact];
        Test.startTest();
        NomineeSelectionController.createNominee(testNomination.Id, testContact.Id, 'Test Description');
        List<CandidateNomination__c> nominees = [SELECT Id FROM CandidateNomination__c WHERE NominationId__c =:testNomination.Id];
        Test.stopTest();
        System.assertEquals(1, nominees.size());
    }
    @isTest
    static void testAuraHandledException() {
        Nomination__c testNomination = [SELECT Id FROM Nomination__c];
        Contact testContact = [SELECT Id FROM Contact];
        try {
            NomineeSelectionController.createNominee(testNomination.Id, testContact.Id, 'Test Description');
            NomineeSelectionController.createNominee(testNomination.Id, testContact.Id, 'Test duplicate');
            System.assert(false);
        } catch (AuraHandledException e) {
            System.assert(true);
        }  
    }
}
