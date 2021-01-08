public with sharing class ModelUtils {

    public static Campaign getCampaign(){
        Campaign camp = new Campaign();
        camp.Name = 'Test Campaign';
        camp.IsActive = true;
        camp.Type = 'Voting';
        return camp;
    }

    public static Nomination__c getNomination(){
        Nomination__c nom = new Nomination__c();
        nom.Name = 'Test Nomination';
        nom.CampaignId__c = getCampaign().Id;
        return nom;
    }

    public static Contact getContact(){
        Contact cont = new Contact();
        cont.LastName = 'Test LastName';
        return cont;
    }

    public static Contact getVoterContact(){
        Contact voter = new Contact();
        voter.LastName = 'Test VoterLastName';
        voter.Email = 'test.voter.email@gmail.com';
        return voter;
    }

    public static CandidateNomination__c getNominee(){
        CandidateNomination__c nominee = new CandidateNomination__c();
        nominee.NominationId__c = getNomination().Id;
        nominee.Nominees__c = getContact().Id;
        nominee.Description__c = 'Test Discription';
        return nominee;
    }

    public static Vote__c getVote(){
        Vote__c vote = new Vote__c();
        vote.CandidateNominationId__c = getNominee().Id;
        vote.VoterId__c = getVoterContact().Id;
        return vote;
    }

}