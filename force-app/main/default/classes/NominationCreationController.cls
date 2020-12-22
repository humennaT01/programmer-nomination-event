public with sharing class NominationCreationController {
    public NominationCreationController() {
    }

    @AuraEnabled(cacheable=true)
    public static List<Campaign> getCampaignList(){
        return [SELECT Id, Name FROM Campaign];
    }

    private static Boolean isNominationAlreadyExist(Id campaignId, String nominationName){
        List<Nomination__c> allNominationInCampaign = [SELECT Name FROM Nomination__c WHERE CampaignId__c = :campaignId ];
        for(Nomination__c nominationItem : allNominationInCampaign){
            if(nominationItem.Name.equals(nominationName)){
                System.debug('If worked!');
                return true;
            }
        }
        System.debug('If not worked!');
        return false;
    }

    @AuraEnabled
    public static void createNomination (Id campaignId, String nominationName){
        if(!isNominationAlreadyExist(campaignId,nominationName)){
            Nomination__c newNomination = new Nomination__c(Name = nominationName, CampaignId__c = campaignId);
            insert newNomination;
        }
        else {
            throw new AuraHandledException('Nomination already exists!');
        }
    }
}
