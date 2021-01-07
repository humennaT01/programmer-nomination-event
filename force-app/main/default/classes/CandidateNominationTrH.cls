public with sharing class CandidateNominationTrH implements ITriggerHandler{

    public void BeforeInsert(List<SObject> newRecord) {
        Set<Id> nominationsIds = new Set<Id>();
        Set<Id> nomineesIds = new Set<Id>();
        List<CandidateNomination__c> newCNRecord = (List<CandidateNomination__c>)newRecord;
        for(CandidateNomination__c cnItem : newCNRecord){
            nominationsIds.add(cnItem.NominationId__c);
            nomineesIds.add(cnItem.Nominees__c);
        }
        List<CandidateNomination__c> master_candidates = [SELECT ID, NominationId__c, Nominees__c, Description__c, Type__c, CreatedById
                                                        FROM CandidateNomination__c WHERE Type__c = 'Master' AND NominationId__c IN :nominationsIds AND Nominees__c IN :nomineesIds];                             
        for (CandidateNomination__c cc : newCNRecord) {
            cc.Type__c = 'Master';
            for (CandidateNomination__c  ccmaster : master_candidates) {
                if(cc.NominationId__c == ccmaster.NominationId__c && cc.Nominees__c == ccmaster.Nominees__c){
                    cc.Type__c = 'Child';
                    cc.MasterRecordID__c = ccmaster.Id;
                }
            }
            if(cc.Type__c == 'Master'){
                master_candidates.add(cc);
            }
        }
    }

    public void BeforeDelete(Map<Id, SObject> delRecord) {
        Set<String> deleted_cc_id = new Set<String>();
        for(CandidateNomination__c cc : (List<CandidateNomination__c>)delRecord.values()){
            deleted_cc_id.add(cc.id);
        }
        List<CandidateNomination__c> masterList =  [SELECT ID, 
                                                (SELECT ID, NominationId__c, Nominees__c, Description__c FROM ChildCandidateNominations__r)
                                                FROM CandidateNomination__c where ID IN :deleted_cc_id AND Type__c = 'Master'];
        List<CandidateNomination__c> childsForChangesList = new List<CandidateNomination__c>();
        for (CandidateNomination__c ccmaster :masterList) {
            List<CandidateNomination__c> childList = ccmaster.ChildCandidateNominations__r;
            if(!childList.isEmpty()){
                childList[0].Type__c = 'Master';
                childList[0].MasterRecordID__c = NULL;
                for(Integer i = 1;i < childList.size(); i++){
                    childList[i].MasterRecordID__c = childList[0].ID;
                }
                childsForChangesList.addAll(childList);
            } 
        }
        update childsForChangesList;
    }

    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){}
    public void AfterInsert(Map<Id, SObject> newItems){}
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){}
    public void AfterDelete(Map<Id, SObject> oldItems){}
    public void AfterUndelete(Map<Id, SObject> oldItems){}

}
