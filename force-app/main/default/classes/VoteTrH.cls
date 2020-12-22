public with sharing class VoteTrH implements ITriggerHandler {
    public void BeforeInsert(List<SObject> newItems){
        List<CandidateNomination__c> masterCN = [SELECT Id FROM CandidateNomination__c WHERE Type__c = 'Master'];
        List<Vote__c> votes = [SELECT Id, VoterId__c, CandidateNominationId__r.NominationId__c
                                FROM Vote__c];
                                
        Map<Id,CandidateNomination__c> candNomMap = new Map<Id,CandidateNomination__c>();
        for(Vote__c v : (List<Vote__c>)newItems){
            candNomMap.put(v.CandidateNominationId__c,null);
        }
        candNomMap.putAll([SELECT Id, NominationId__c FROM CandidateNomination__c WHERE Id IN :candNomMap.keyset()]);

        for(Vote__c vote : votes){
            for(Vote__c newVote : (List<Vote__c>)newItems){
                if(vote.VoterId__c == newVote.VoterId__c
                    && vote.CandidateNominationId__r.NominationId__c == 
                    candNomMap.get(newVote.CandidateNominationId__c).NominationId__c){
                        newVote.addError('You have already voted in this nomination!');    
                }
                else{
                    System.debug('Your vote was taken into consideration!');       
                }
            }
        } 
    }

    public void AfterInsert(Map<Id, SObject> newItems){
        Set<String> insertedVotesId = new Set<String>();
        for(Vote__c vote : (List<Vote__c>)newItems.values()){
            insertedVotesId.add(vote.Id);
        }
        List<Vote__c> votes = [SELECT Id, VoterId__c, CandidateNominationId__r.MasterRecordID__c
                                FROM Vote__c WHERE Id IN :insertedVotesId];
        for(Vote__c vote : votes){
            if(vote.CandidateNominationId__r.MasterRecordID__c != null){
                vote.CandidateNominationId__c = vote.CandidateNominationId__r.MasterRecordID__c;
            }
        }
        update votes;
    }

    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){}
    public void BeforeDelete(Map<Id, SObject> oldItems){}
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){}
    public void AfterDelete(Map<Id, SObject> oldItems){}
    public void AfterUndelete(Map<Id, SObject> oldItems){}
}