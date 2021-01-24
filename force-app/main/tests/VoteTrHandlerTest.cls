@isTest
public with sharing class VoteTrHandlerTest {
    
    @TestSetup
    static void makeData(){
        Campaign campaign = ModelUtils.buildCampaign();
        insert campaign;
        Nomination__c nomination = ModelUtils.buildNomination(campaign);
        insert nomination;
        Contact contact = ModelUtils.buildContact();
        insert contact;
        Contact voter = ModelUtils.buildContactWithEmail();
        insert voter;
        CandidateNomination__c nominee = ModelUtils.buildCandidateNomination(nomination, contact);
        insert nominee;
        User standartUser = ModelUtils.buildStandartUser();
        insert standartUser;
        User adminUser = ModelUtils.buildSystemAdministrator();
        insert adminUser;
    }

    @isTest
    static void testOneVoteInsert() {
        Contact voter = [SELECT Id, LastName, Email FROM Contact][1];
        Nomination__c nomination = [SELECT Id, Name, CampaignId__c FROM Nomination__c LIMIT 1];
        CandidateNomination__c nominee = [SELECT Id, NominationId__c, Nominees__c, Description__c  FROM CandidateNomination__c LIMIT 1];
        Vote__c newVote = new Vote__c(CandidateNominationId__c = nominee.Id, VoterId__c = voter.Id);
        Test.startTest();
        Database.SaveResult result = Database.insert(newVote, false);
        Test.stopTest();
        System.assert(result.isSuccess());
    }

    @isTest
    static void testTwoVotesFromOneUserInsert() {
        List<Contact> contacts = [SELECT Id, LastName, Email FROM Contact];
        Contact contact1 = contacts[0];
        Contact voter = contacts[1];
        Contact contact2 = new Contact(LastName='TestLastName2');
        insert contact2;
        Nomination__c nomination = [SELECT Id, Name, CampaignId__c FROM Nomination__c LIMIT 1];
        CandidateNomination__c nominee1 = [SELECT Id, NominationId__c, Nominees__c, Description__c  FROM CandidateNomination__c LIMIT 1];
        CandidateNomination__c nominee2 = new CandidateNomination__c(Nominees__c = contact2.Id, NominationId__c = nomination.Id, Description__c = 'Test Discription2');
        insert nominee2;
        Vote__c newVote1 = new Vote__c(CandidateNominationId__c = nominee1.Id, VoterId__c = voter.Id);
        Vote__c newVote2 = new Vote__c(CandidateNominationId__c = nominee2.Id, VoterId__c = voter.Id);
        Test.startTest();
        Database.SaveResult result1 = Database.insert(newVote1, false);
        Database.SaveResult result2 = Database.insert(newVote2, false);
        Test.stopTest();
        System.assert(result1.isSuccess());
        System.assert(!result2.isSuccess());
    } 

    @isTest
    static void testTwoVotesFromUserForSameNomination() {
        Contact voter = [SELECT Id, LastName, Email FROM Contact][1];
        Nomination__c nomination = [SELECT Id, Name, CampaignId__c FROM Nomination__c LIMIT 1];
        CandidateNomination__c nominee = [SELECT Id, NominationId__c, Nominees__c, Description__c  FROM CandidateNomination__c LIMIT 1];
        Vote__c newVote1 = new Vote__c(CandidateNominationId__c=nominee.Id, VoterId__c=voter.Id);
        Vote__c newVote2 = new Vote__c(CandidateNominationId__c=nominee.Id, VoterId__c=voter.Id);
        Test.startTest();
        Database.SaveResult result1 = Database.insert(newVote1, true);
        Database.SaveResult result2 = Database.insert(newVote2, false);
        Test.stopTest();
        System.assert(result1.isSuccess());
        System.assert(!result2.isSuccess());
        System.assertEquals('You have already voted in this nomination!', 
                               result2.getErrors()[0].getMessage());
    }

    @isTest
    static void testVoteForChildNominee(){
        Campaign campaign = [SELECT Id, Name, IsActive, Type FROM Campaign LIMIT 1];
        List<Contact> contacts = [SELECT Id, LastName, Email FROM Contact];
        Contact contact = contacts[0];
        Contact voter = contacts[1];
        Nomination__c nomination = [SELECT Id, Name, CampaignId__c FROM Nomination__c LIMIT 1];

        CandidateNomination__c nominee1 = [SELECT Id, NominationId__c, Nominees__c, Description__c  FROM CandidateNomination__c LIMIT 1];
        CandidateNomination__c nominee2 = new CandidateNomination__c(Nominees__c = contact.Id, NominationId__c = nomination.Id, Description__c='Test Discription2');
        
        User user = ModelUtils.buildSystemAdministrator();
        insert user;
        System.runAs(user) {
            insert nominee2; 
        }
        Test.startTest();
        Vote__c newVote = new Vote__c(CandidateNominationId__c = nominee2.Id, VoterId__c = voter.Id);
        Database.SaveResult result = Database.insert(newVote, false);
        Test.stopTest();

        newVote = [SELECT CandidateNominationId__c, VoterId__c FROM Vote__c WHERE Id = :newVote.Id];
        System.assert(result.isSuccess());
        System.assertEquals(nominee1.Id, newVote.CandidateNominationId__c);
    }
}
