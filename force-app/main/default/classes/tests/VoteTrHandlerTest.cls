@isTest
public with sharing class VoteTrHandlerTest {
    
    @isTest
    static void testOneVoteInsert() {
        Campaign newCampaign = new Campaign(Name='Test Campaign', Type='Voting', IsActive=true);
        insert newCampaign;
        Contact newContact = new Contact(LastName='TestLastName');
        insert newContact;
        Nomination__c newNomination = new Nomination__c(CampaignId__c=newCampaign.Id, Name='Test Nomination');
        insert newNomination;
        CandidateNomination__c newCN = new CandidateNomination__c(Nominees__c=newContact.Id, NominationId__c=newNomination.Id, Description__c='Test Discription');
        insert newCN;
        Contact newVoter = new Contact(LastName='TestVoterLastName');
        insert newVoter;
        Vote__c newVote = new Vote__c(CandidateNominationId__c=newCN.Id, VoterId__c=newVoter.Id);
        Test.startTest();
        Database.SaveResult result = Database.insert(newVote, false);
        Test.stopTest();
        System.assert(result.isSuccess());
    }

    @isTest
    static void testTwoVotesFromOneUserInsert() {
        Campaign newCampaign = new Campaign(Name='Test Campaign', Type='Voting', IsActive=true);
        insert newCampaign;
        Contact newContact1 = new Contact(LastName='TestLastName1');
        insert newContact1;
        Contact newContact2 = new Contact(LastName='TestLastName2');
        insert newContact2;
        Nomination__c newNomination = new Nomination__c(CampaignId__c=newCampaign.Id, Name='Test Nomination');
        insert newNomination;
        CandidateNomination__c newCN1 = new CandidateNomination__c(Nominees__c=newContact1.Id, NominationId__c=newNomination.Id, Description__c='Test Discription1');
        insert newCN1;
        CandidateNomination__c newCN2 = new CandidateNomination__c(Nominees__c=newContact2.Id, NominationId__c=newNomination.Id, Description__c='Test Discription2');
        insert newCN2;
        Contact newVoter = new Contact(LastName='TestVoterLastName');
        insert newVoter;
        Vote__c newVote1 = new Vote__c(CandidateNominationId__c=newCN1.Id, VoterId__c=newVoter.Id);
        Vote__c newVote2 = new Vote__c(CandidateNominationId__c=newCN2.Id, VoterId__c=newVoter.Id);
        Test.startTest();
        Database.SaveResult result1 = Database.insert(newVote1, false);
        Database.SaveResult result2 = Database.insert(newVote2, false);
        Test.stopTest();
        System.assert(result1.isSuccess());
        System.assert(!result2.isSuccess());
    } 

    @isTest
    static void testVoteForChildNominee(){
        // Campaign newCampaign = new Campaign(Name='Test Campaign', Type='Voting', IsActive=true);
        // insert newCampaign;
        // Contact newContact = new Contact(LastName='TestLastName');
        // insert newContact;
        // Nomination__c newNomination = new Nomination__c(CampaignId__c=newCampaign.Id, Name='Test Nomination');
        // insert newNomination;
        // CandidateNomination__c newCN = new CandidateNomination__c(Nominees__c='00309000004izUiAAI', NominationId__c='a00090000038jMSAAY', Description__c='Test Discription');
        // insert newCN;
        // CandidateNomination__c newCN2 = new CandidateNomination__c(Nominees__c=newContact.Id, NominationId__c=newNomination.Id, Description__c='Test Discription2');
        // insert newCN2;
        String name = 'CN-00097';
        System.debug('name' + name);
        CandidateNomination__c andy = [SELECT Id FROM CandidateNomination__c WHERE Name = 'CN-00097' ];
        Contact newVoter = new Contact(LastName='TestVoterLastName');
        insert newVoter;
        Vote__c newVote = new Vote__c(CandidateNominationId__c=andy.Id, VoterId__c=newVoter.Id);
        System.debug('name' + name);
        Test.startTest();
        System.debug(newVote);
        Database.SaveResult result = Database.insert(newVote, true);
        Test.stopTest();
        System.assert(result.isSuccess());
    }
}
