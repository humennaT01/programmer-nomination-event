public with sharing class VotingController {
    
    @AuraEnabled
    public static Map<Id, List<Contact>> getContactList(List<Nomination__c> nominations) {                                                
        List<CandidateNomination__c> cnWithCurrentNomination = [SELECT NominationId__c, Nominees__c FROM CandidateNomination__c WHERE NominationId__c in :nominations AND Type__c = 'Master']; 
        Set<Id> nominees = new Set<Id>();
        for(CandidateNomination__c itemCN : cnWithCurrentNomination){
            nominees.add(itemCN.Nominees__c);
        }
        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, FirstName, LastName, Department FROM Contact WHERE Id IN :nominees]);
        Map<Id, List<Contact>> nomineesInNomination = new Map<Id, List<Contact>>();
        for(Nomination__c nominationItem : nominations){
            List<Contact> nomineesForNomination = new List<Contact>();
            for(CandidateNomination__c itemCN : cnWithCurrentNomination){
                if(itemCN.NominationId__c == nominationItem.Id){
                    nomineesForNomination.add(contactMap.get(itemCN.Nominees__c));
                }
            }
            nomineesInNomination.put(nominationItem.Id, nomineesForNomination);
        }
        return nomineesInNomination;
    }

    @AuraEnabled
    public static List<Nomination__c> getNominationList(Id campaign){
        List<Nomination__c> nominations = [SELECT Id, Name FROM Nomination__c WHERE CampaignId__c = :campaign];
        return nominations;
    }

    @AuraEnabled
    public static Campaign getCampaignList(){
        Campaign campaignC =  [SELECT Id, Name FROM Campaign WHERE Type = 'Voting'  AND IsActive = true][0];
        return campaignC;
    }


    private static Id getVoter(String email){
        Contact voter = [SELECT Id FROM Contact WHERE Email = :email];
        return voter.Id;
    }

    @AuraEnabled
    public static void createVote(Map<Id, Id> finalVotes, String email) {
        Id voterId = getVoter(email);
        List<CandidateNomination__c>  nominees  = [SELECT Id, NominationId__c, Nominees__c FROM CandidateNomination__c WHERE NominationId__c in :finalVotes.keySet() AND Nominees__c in :finalVotes.values() AND Type__c = 'Master'];
        List<Vote__c> votes = new List<Vote__c>();
        for(CandidateNomination__c cnItem : nominees){
            if(cnItem.Nominees__c == finalVotes.get(cnItem.NominationId__c)){
                votes.add(new Vote__c(VoterId__c = voterId, CandidateNominationId__c = cnItem.Id));
            }
        }
        try{
            insert votes;
        } catch (DmlException ex){
            throw new AuraHandledException(ex.getDmlMessage(0));
        }
    }
}