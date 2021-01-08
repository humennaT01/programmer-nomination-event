@isTest
public with sharing class VotingControllerTest {

    @isTest static void testGetNominations() {
        Campaign newCampaign1 = new Campaign(Name='Test Campaign 1', IsActive=true, Type='Voting');
        insert newCampaign1;
        Campaign newCampaign2 = new Campaign(Name='Test Campaign 2', IsActive=true, Type='Voting');
        insert newCampaign2;
        List<Nomination__c> nominations = new List<Nomination__c>();
        for(Integer i = 0; i < 5; i++){
            nominations.add(new Nomination__c(Name=('Test Nomination ' + (i + 1)), CampaignId__c=newCampaign1.Id));
        }
        nominations.add(new Nomination__c(Name='Test Nomination Bad', CampaignId__c=newCampaign2.Id));
        System.debug(nominations);
        insert nominations;

        Test.startTest();
        Nomination__c[] resultNominations = VotingController.getNominationList(newCampaign1.Id);
        Test.stopTest();
        System.assertEquals(5, resultNominations.size());
    } 

    //getCampaignList() returns one Campaign, not a list
    @isTest static void getCampaignListTest(){
        Campaign campaign = ModelUtils.getCampaign();
        insert campaign;
        Id expected = campaign.Id;
        Test.startTest();
        Id actual = VotingController.getCampaignList().Id;
        Test.stopTest();
        System.assertEquals(expected, actual, 'Campaign.Id stored in DB not equals to Campaign.Id received by method.');
    }

    //if cange getCampaignList() return type to List<Campaign>
    // @isTest
    // public static void getEmptyCampaignListTest(){
    //     Test.startTest();
    //     Campaign[] actual = VotingController.getCampaignList();
    //     Test.stopTest();
    //     System.assertEquals(null, actual, 'CampaignListTest is not empty.');
    // }

    @isTest static void createOneVoteTest(){
        System.debug('@_@_@_@_@__@__@_@_@_@__@_@__@_@_@__@__@_@_@_@_@__@@__@_@__@');
        Campaign campaign = ModelUtils.getCampaign();
        insert campaign;
        Nomination__c nomination = ModelUtils.getNomination();
        insert nomination;
        Contact contact = ModelUtils.getContact();
        insert contact;
        CandidateNomination__c nominee = ModelUtils.getNominee();
        //Nominee can get Nomination.Id and Contact.Id after their insert to DB
        nominee.NominationId__c = nomination.Id;
        nominee.Nominees__c = contact.Id;
        nominee.Type__c = 'Master';
        insert nominee;
        System.debug('Inserted nominee: ' + nominee);
        System.debug('type of nominee: ' + nominee.Type__c);
        Contact voter = ModelUtils.getVoterContact();
        insert voter;

        Map<Id,Id> votes = new Map<Id,Id>();
        votes.put(nomination.Id, nominee.Id);
        System.debug('votes -> '+ votes);
        System.debug('voter: '+ voter);
        System.debug('CandidateNomination__c in DB -> ' + [SELECT Id, NominationId__c, Nominees__c FROM CandidateNomination__c]);
        System.debug('SOQL -> ' + [SELECT Id, NominationId__c, Nominees__c FROM CandidateNomination__c WHERE NominationId__c = :nomination.Id AND Nominees__c = :nominee.Id]);// AND Type__c = 'Master']);
        
        Test.startTest();
        VotingController.createVote(votes, voter.Email);
        Test.stopTest();
        List<Vote__c> votesInDB = [SELECT Id, VoterId__c, CandidateNominationId__c FROM Vote__c 
                                WHERE CandidateNominationId__c =:votes.values() AND VoterId__c =: voter.Id];
        System.debug('in DB: ' + votesInDB);
        System.assertEquals(1, votesInDB.size(), 'Vote was not inserted.');
    }

    @isTest static void createSomeVotesTest(){
        System.debug('@_@_@_@_@__@__@_@_@_@__@_@__@_@_@__@__@_@_@_@_@__@@__@_@__@');
        Campaign campaign = ModelUtils.getCampaign();
        insert campaign;
        Nomination__c nomination1 = ModelUtils.getNomination();
        Nomination__c nomination2 = ModelUtils.getNomination();
        Nomination__c nomination3 = ModelUtils.getNomination();
        insert new Nomination__c[]{nomination1, nomination2, nomination3};
        System.debug('nominations -> '+ [SELECT Id FROM Nomination__c ]);
        Contact contact = ModelUtils.getContact();
        insert contact;
        CandidateNomination__c nominee1 = ModelUtils.getNominee();
        nominee1.NominationId__c = nomination1.Id;
        nominee1.Nominees__c = contact.Id;
        nominee1.Type__c = 'Master';
        CandidateNomination__c nominee2 = ModelUtils.getNominee();
        nominee2.NominationId__c = nomination2.Id;
        nominee2.Nominees__c = contact.Id;
        nominee2.Type__c = 'Master';
        CandidateNomination__c nominee3 = ModelUtils.getNominee();
        nominee3.NominationId__c = nomination3.Id;
        nominee3.Nominees__c = contact.Id;
        nominee3.Type__c = 'Master';
        insert new CandidateNomination__c[]{nominee1, nominee2, nominee3};
        System.debug('nominees -> '+ [SELECT Id FROM CandidateNomination__c ]);
        Contact voter = ModelUtils.getVoterContact();
        insert voter;

        Map<Id,Id> votes = new Map<Id,Id>();
        votes.put(nomination1.Id, nominee1.Id);
        votes.put(nomination2.Id, nominee2.Id);
        votes.put(nomination3.Id, nominee3.Id);
        System.debug('votes -> '+ votes);
        System.debug('voter: '+ voter);

        System.debug('SOQL -> ' + [SELECT Id, NominationId__c, Nominees__c FROM CandidateNomination__c WHERE NominationId__c in :votes.keySet() AND Nominees__c in :votes.values() AND Type__c = 'Master']);
        Test.startTest();
        VotingController.createVote(votes, voter.Email);
        System.debug('voter: '+ voter);
        Test.stopTest();
        List<Vote__c> votesInDB = [SELECT Id FROM Vote__c];// WHERE VoterId__c =:voter.Id];
        System.debug('in DB2: ' + votesInDB);

        System.assertNotEquals(0, votesInDB.size(), 'Votes was not inserted.');                        
    }
}