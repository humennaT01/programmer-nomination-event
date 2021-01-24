@isTest
public with sharing class NomineeSelectionControllerTest {

    @TestSetup
    static void makeData(){
        Campaign campaign = TestUtils.buildCampaign();
        insert campaign;
        Nomination__c nomination = TestUtils.buildNomination(campaign);
        insert nomination;
        Contact contact = TestUtils.buildContact();
        insert contact;
    }

    @isTest static void testGetCampaignList() {
        Campaign newCampaign = new Campaign(Name = 'Test  New Campaign', Type = 'Webinar', IsActive = false);
        Test.startTest();
        Database.SaveResult result = Database.insert(newCampaign,false);
        List<Campaign> campaignList = NomineeSelectionController.getCampaignList();
        Test.stopTest();
        System.assertEquals(1, campaignList.size());
    }

    @isTest static void testGetEmptyCampaignList() {
        Campaign campaign = [SELECT Name, IsActive, Type FROM Campaign LIMIT 1];
        campaign.IsActive = false;
        Test.startTest();
        Database.SaveResult result = Database.update(campaign,false);
        List<Campaign> campaignList = NomineeSelectionController.getCampaignList();
        Test.stopTest();
        System.assertEquals(0, campaignList.size());
    }


    @isTest static void testGetNominationList() {
        Campaign campaign = [SELECT Id FROM Campaign WHERE Name = 'Test Campaign' LIMIT 1];
        Test.startTest(); 
        List<Nomination__c> nominations = NomineeSelectionController.getNominationList(campaign.Id);
        Test.stopTest();
        System.assertEquals(1, nominations.size());
    }

    @isTest static void testGetEmptyNominationList() {
        Campaign newCampaign = new Campaign(Name='Test New Campaign', Type='Voting', IsActive=true);
        insert newCampaign;
        Test.startTest(); 
        List<Nomination__c> nominations = NomineeSelectionController.getNominationList(newCampaign.Id);
        Test.stopTest();
        System.assertEquals(0, nominations.size());
    }

    @isTest static void testGetContactByEnteringAnyString() {
        Contact testContact = [SELECT LastName FROM Contact WHERE Name = 'Test LastName'];
        Test.startTest();
        Contact[] resultContacts = NomineeSelectionController.getContactList('es');
        Test.stopTest();
        System.assertEquals(true, resultContacts.contains(testContact));
    } 

    @isTest static void testGetContactListByEnteringAnyString() {
        List<Contact> contacts = new List<Contact>();
        contacts.add(TestUtils.buildContact());
        contacts.add(TestUtils.buildContact());
        Contact testContact = [SELECT LastName FROM Contact WHERE Name = 'Test LastName'];
        Test.startTest();
        List<Database.SaveResult> results = Database.insert(contacts, false);
        Contact[] resultContacts = NomineeSelectionController.getContactList('es');
        Test.stopTest();
        System.assertEquals(3, resultContacts.size());
        System.assertEquals(true, resultContacts.contains(testContact));
    } 

    @isTest static void testGetContactByLastName() {
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(LastName = 'Jonson', FirstName = 'Bill'));
        contacts.add(new Contact(LastName = 'Branson', FirstName = 'Alice'));
        Test.startTest();
        List<Database.SaveResult> results = Database.insert(contacts, false);
        Contact[] resultContacts = NomineeSelectionController.getContactList('Jonson');
        System.debug(resultContacts);
        Test.stopTest();
        Contact testContact = [SELECT Id, FirstName, LastName FROM Contact WHERE Name = 'Bill Jonson' LIMIT 1];
        System.assertEquals(1, resultContacts.size());
        System.assertEquals(true, resultContacts.contains(testContact));
    } 

    @isTest static void testGetEmptyContactList() {
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(LastName = 'Jonson', FirstName = 'Bill'));
        contacts.add(new Contact(LastName = 'Branson', FirstName = 'Alice'));
        Test.startTest();
        List<Database.SaveResult> results = Database.insert(contacts, false);
        Contact[] resultContacts = NomineeSelectionController.getContactList('somebody');
        Test.stopTest();
        System.assertEquals(0, resultContacts.size());
    } 

    @isTest static void testCreateNominee() {
        Nomination__c nomination = [SELECT Id FROM Nomination__c];
        Contact contact = [SELECT Id FROM Contact];
        Test.startTest();
        NomineeSelectionController.createNominee(nomination.Id, contact.Id, 'Test Description');
        List<CandidateNomination__c> nominees = [SELECT Id FROM CandidateNomination__c WHERE NominationId__c =:nomination.Id];
        Test.stopTest();
        System.assertEquals(1, nominees.size());
    }

    @isTest static void testCreateNomineeWithIvalidNominationId() {
        Nomination__c nomination = [SELECT Id FROM Nomination__c];
        Contact contact = [SELECT Id FROM Contact];
        Test.startTest();
        try{
            NomineeSelectionController.createNominee(contact.Id, contact.Id, 'Test Description');
            System.assert(false, 'Cannot create nominee with invalid Nomination Id.');
        }catch(AuraHandledException ex){
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest static void testCreateNomineeWithIvalidContactId() {
        Nomination__c nomination = [SELECT Id FROM Nomination__c];
        Contact contact = [SELECT Id FROM Contact];
        Test.startTest();
        try{
            NomineeSelectionController.createNominee(nomination.Id, nomination.Id, 'Test Description');
            System.assert(false, 'Cannot create nominee with invalid Contact Id.');
        }catch(AuraHandledException ex){
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest static void testCreateTheSameTwoNominee() {
        Nomination__c testNomination = [SELECT Id FROM Nomination__c];
        Contact testContact = [SELECT Id FROM Contact];
        Test.startTest();
        try {
            NomineeSelectionController.createNominee(testNomination.Id, testContact.Id, 'Test Description');
            NomineeSelectionController.createNominee(testNomination.Id, testContact.Id, 'Test duplicate');
            System.assert(false, 'Cannot create duplicate nominee.');
        } catch (AuraHandledException e) {
            System.assert(true);
        }  
        Test.stopTest();
    }
}
