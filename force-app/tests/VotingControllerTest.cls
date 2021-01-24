@isTest
public with sharing class VotingControllerTest {

    @TestSetup
    static void makeData(){
        Campaign campaign = TestUtils.buildCampaign();
        insert campaign;
        Nomination__c nomination = TestUtils.buildNomination(campaign);
        insert nomination;
        Contact contact = TestUtils.buildContact();
        insert contact;
        Contact voter = TestUtils.buildContactWithEmail();
        insert voter;
        CandidateNomination__c nominee = TestUtils.buildCandidateNomination(nomination, contact);
        insert nominee;
        User adminUser = TestUtils.buildSystemAdministrator();
        insert adminUser;
    }
    
    @isTest static void testGetNominations() {
        Campaign campaign1 = [SELECT Id, Name FROM Campaign LIMIT 1];
        Campaign campaign2 = new Campaign(Name='Test Campaign 2', IsActive=true, Type='Voting');
        insert campaign2;
        List<Nomination__c> nominations = new List<Nomination__c>();
        for(Integer i = 0; i < 5; i++){
            nominations.add(new Nomination__c(Name=('Test Nomination ' + (i + 1)), CampaignId__c=campaign1.Id));
        }
        nominations.add(new Nomination__c(Name='Test Nomination for Campaign2', CampaignId__c=campaign2.Id));
        System.debug(nominations);
        insert nominations;
        Test.startTest();
        Nomination__c[] resultNominations = VotingController.getNominationList(campaign1.Id);
        Nomination__c[] resultNominations2 = VotingController.getNominationList(campaign2.Id);
        Test.stopTest();
        //1 nomination was created in SetUp + 5 nomination created in Test = 6
        System.assertEquals(6, resultNominations.size());
        System.assertEquals(1, resultNominations2.size());
    } 

    @isTest static void getCampaignListTest(){
        Campaign campaign = [SELECT Id FROM Campaign LIMIT 1];
        Test.startTest();
        Id expected = campaign.Id;
        Id actual = VotingController.getCampaignList().Id;
        Test.stopTest();
        System.assertEquals(expected, actual, 'Campaign.Id stored in DB not equals to Campaign.Id received by method.');
    }

    @isTest static void createOneVoteTest(){
        Campaign campaign = [SELECT Id FROM Campaign LIMIT 1];
        Nomination__c nomination = [SELECT Id, Name, CampaignId__c FROM Nomination__c LIMIT 1];
        Contact voter = [SELECT Id, LastName, UUID__c FROM Contact][1];
        CandidateNomination__c nominee = [SELECT NominationId__c, Nominees__c, Description__c FROM CandidateNomination__c LIMIT 1];

        Map<Id,Id> votes = new Map<Id,Id>();
        votes.put(nomination.Id, nominee.Nominees__c);

        Test.startTest();
        VotingController.createVote(votes, voter.UUID__c);
        Test.stopTest();
        List<Vote__c> votesInDB = [SELECT Id, VoterId__c, CandidateNominationId__c FROM Vote__c 
                                WHERE CandidateNominationId__c =:nominee.Id AND VoterId__c =: voter.Id];
        System.assertEquals(1, votesInDB.size(), 'Vote was not inserted.');
    }

    @isTest static void createSomeVotesTest(){
        Campaign campaign = [SELECT Id, Name FROM Campaign LIMIT 1];
        Nomination__c nomination = [SELECT Id, Name, CampaignId__c FROM Nomination__c LIMIT 1];
        List<Contact> contacts = [SELECT Id, LastName, UUID__c FROM Contact];
        Contact contact = contacts[0];
        Contact voter = contacts[1];

        Nomination__c nomination1 = [SELECT Id FROM Nomination__c LIMIT 1];
        Nomination__c nomination2 = new Nomination__c(Name = 'Test Nomination2');
        Nomination__c nomination3 = new Nomination__c(Name = 'Test Nomination3');
        nomination2.CampaignId__c = campaign.Id;
        nomination3.CampaignId__c = campaign.Id;
        insert new Nomination__c[]{nomination2, nomination3};
        
        CandidateNomination__c nominee1 = [SELECT Id, Nominees__c FROM CandidateNomination__c LIMIT 1];
        CandidateNomination__c nominee2 = new CandidateNomination__c(Description__c = 'Test Discription2');
        nominee2.NominationId__c = nomination2.Id;
        nominee2.Nominees__c = contact.Id;
        CandidateNomination__c nominee3 = new CandidateNomination__c(Description__c = 'Test Discription3');
        nominee3.NominationId__c = nomination3.Id;
        nominee3.Nominees__c = contact.Id;
        insert new CandidateNomination__c[]{nominee2, nominee3};

        Id[] nomineesId = new Id[]{nominee1.Id, nominee2.Id, nominee3.Id};
        
        Map<Id,Id> votes = new Map<Id,Id>();
        votes.put(nomination1.Id, nominee1.Nominees__c);
        votes.put(nomination2.Id, nominee2.Nominees__c);
        votes.put(nomination3.Id, nominee3.Nominees__c);
        
        Test.startTest();
        VotingController.createVote(votes, voter.UUID__c);
        List<Vote__c> votesInDB = [SELECT Id FROM Vote__c  WHERE VoterId__c =: voter.Id];
        Test.stopTest();
        System.assertNotEquals(0, votesInDB.size(), 'Votes was not inserted.');                        
    }

    @isTest static void createVoteWitoutUUIDTest(){
        Campaign campaign = [SELECT Id, Name FROM Campaign LIMIT 1];
        Nomination__c nomination = [SELECT Id, Name, CampaignId__c FROM Nomination__c LIMIT 1];
        Contact voter = new Contact(LastName = 'Test VoterWitoutEmail');
        insert voter;
        CandidateNomination__c nominee = [SELECT Id, Nominees__c FROM CandidateNomination__c LIMIT 1];

        Map<Id,Id> votes = new Map<Id,Id>();
        votes.put(nomination.Id, nominee.Nominees__c);

        Test.startTest();
        try{
            VotingController.createVote(votes, voter.UUID__c);
            System.assert(false,'Vote cannot be created without UUID.');
        }catch(AuraHandledException aex){
            System.assert(true);
        }
        Test.stopTest();  
    }

    @isTest static void createVoteWithInvalidUUIDTest(){
        Nomination__c nomination = [SELECT Id, Name, CampaignId__c FROM Nomination__c LIMIT 1];
        List<Contact> contacts = [SELECT Id, LastName, UUID__c FROM Contact];
        Contact contact = contacts[0];
        Contact voter = contacts[1];
        CandidateNomination__c nominee = [SELECT Id, Nominees__c FROM CandidateNomination__c LIMIT 1];

        Map<Id,Id> votes = new Map<Id,Id>();
        votes.put(nomination.Id, nominee.Nominees__c);

        String invalidUUID = '12345';
        Test.startTest();
        try{
            VotingController.createVote(votes, invalidUUID);
            System.assert(false,'Vote cannot be created with invalid UUID.');
        } catch (AuraHandledException ahe){
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest static void createVoteWithoutChoosenNomineeTest(){
        Nomination__c nomination = [SELECT Id, Name, CampaignId__c FROM Nomination__c LIMIT 1];
        List<Contact> contacts = [SELECT Id, LastName, UUID__c FROM Contact];
        Contact contact = contacts[0];
        Contact voter = contacts[1];
        CandidateNomination__c nominee = [SELECT Id, Nominees__c FROM CandidateNomination__c LIMIT 1];

        Map<Id,Id> votes = new Map<Id,Id>();
        Test.startTest();
        try{
            VotingController.createVote(votes, voter.UUID__c);
            System.assert(false, 'Vote cannot be created without choosen nominee.');
        } catch (AuraHandledException ahe){
            System.assert(true);
        }
        Test.stopTest(); 
    }

    @isTest static void createTheSameTwoVoteTest(){
        Nomination__c nomination = [SELECT Id, Name, CampaignId__c FROM Nomination__c LIMIT 1];
        List<Contact> contacts = [SELECT Id, LastName, UUID__c FROM Contact];
        Contact contact = contacts[0];
        Contact voter = contacts[1];
        CandidateNomination__c nominee = [SELECT Id, Nominees__c FROM CandidateNomination__c LIMIT 1];

        Map<Id,Id> votes = new Map<Id,Id>();
        votes.put(nomination.Id, nominee.Nominees__c);

        Test.startTest();
        Boolean wasException = false;
        try{
            VotingController.createVote(votes, voter.UUID__c);
            VotingController.createVote(votes, voter.UUID__c);
            System.assert(false,'Cannot create the same two votes.');
        } catch (AuraHandledException ahe){
            System.assert(true);
        } 
        Test.stopTest();
    }

    @isTest
    static void testGetDescription() {
        Nomination__c nomination = [SELECT Id, Name, CampaignId__c FROM Nomination__c LIMIT 1];
        List<Contact> contacts = [SELECT Id, LastName, UUID__c FROM Contact];
        Contact contact = contacts[0];
        Contact voter = contacts[1];
        CandidateNomination__c nominee = [SELECT Id, Nominees__c FROM CandidateNomination__c LIMIT 1];

        Test.startTest();
        String result = VotingController.getDescription(contact.Id, nomination.Id);
        Test.stopTest();
        System.assertEquals('Test Discription', result);
    }

    @isTest
    public static void testGetContactList(){
        List<Nomination__c> nominations = [SELECT Id, Name, CampaignId__c FROM Nomination__c];

        Test.startTest();
        Map<Id, List<Contact>> result = VotingController.getContactList(nominations);
        Test.stopTest();
        System.assertEquals(1 , result.size());   
    }

}