public with sharing class VoteTrH extends ITriggerHandler {

    public void BeforeInsert(List<SObject> newItems){
        List<Vote__c> newVotes = (List<Vote__c>)newItems;
        Map<Id,CandidateNomination__c> candNomMap = new Map<Id,CandidateNomination__c>();
        for(Vote__c v : newVotes){
            candNomMap.put(v.CandidateNominationId__c,null);
        }
        candNomMap.putAll([SELECT Id, NominationId__c, MasterRecordID__c FROM CandidateNomination__c WHERE Id IN :candNomMap.keyset()]);
        //Added set of new nominations
        Set<Id> newNominations = new Set<Id>();
        for(CandidateNomination__c candNom : candNomMap.values()){
            newNominations.add(candNom.NominationId__c);
        }
        //Take only CN in with same nominations as in new votes
        List<CandidateNomination__c> masterCN = [SELECT Id FROM CandidateNomination__c WHERE Type__c = 'Master' AND NominationId__c IN :newNominations];
        //Take only votes with same nominations as in new votes
        List<Vote__c> votes = [SELECT Id, VoterId__c, CandidateNominationId__r.NominationId__c
                                FROM Vote__c WHERE CandidateNominationId__r.NominationId__c IN :newNominations];
        for(Vote__c newVote : newVotes){
            //To vote only for Master Nominee, not Child
            Id newVoteMasterRecord = candNomMap.get(newVote.CandidateNominationId__c).MasterRecordID__c;
            if(newVoteMasterRecord != null){
                newVote.CandidateNominationId__c = newVoteMasterRecord;
            }
            for(Vote__c vote : votes){  //changed places of inner and outer loop(it probably be more votes in DB then newVotes, so breaking longer loop is a good idea)
                if(vote.VoterId__c == newVote.VoterId__c &&
                vote.CandidateNominationId__r.NominationId__c == candNomMap.get(newVote.CandidateNominationId__c).NominationId__c){
                    newVote.addError('You have already voted in this nomination!');
                    break;//added skip unnecessary loop
                }
            }
        }
    }
}