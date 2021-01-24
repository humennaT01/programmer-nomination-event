@isTest
public class CandidateNominationTrHTest {

    @testSetup
    static void makeData(){
        Campaign campaign = TestUtils.buildCampaign();
        insert campaign;
        Nomination__c nomination = TestUtils.buildNomination(campaign);
        insert nomination;
        Contact contact = TestUtils.buildContact();
        insert contact;
        CandidateNomination__c nominee = TestUtils.buildCandidateNomination(nomination, contact);
        insert nominee;
        User systemAdminUser = TestUtils.buildSystemAdministrator();
        insert systemAdminUser;
}
    @isTest
    static void testOneMasterInsert() {
        Test.startTest();
        CandidateNomination__c candidate = [SELECT Type__c, MasterRecordID__c FROM CandidateNomination__c];     
        Test.stopTest();
        System.assertEquals('Master', candidate.Type__c);
        System.assertEquals(null, candidate.MasterRecordID__c);
}
    @isTest
    static void testOneMasterAndChildInsert() {
        CandidateNomination__c master = [SELECT Nominees__c, NominationId__c, Type__c, MasterRecordID__c FROM CandidateNomination__c];
        CandidateNomination__c child = new CandidateNomination__c(NominationId__c = master.NominationId__c, Nominees__c = master.Nominees__c, Description__c = 'Child');
        User testUser = [SELECT Id FROM User WHERE LastName = 'Testing'];
        Test.startTest();
        Database.SaveResult resultChild;
        System.runAs(testUser) {
            resultChild = Database.insert(child, false);
        }
        Test.stopTest();
        CandidateNomination__c childUpdated = [SELECT Type__c, MasterRecordID__c FROM CandidateNomination__c WHERE Id = :child.Id];
        System.assert(resultChild.isSuccess());
        System.assertEquals('Child', childUpdated.Type__c);
        System.assertEquals(master.Id, childUpdated.MasterRecordID__c);
    } 
    @isTest static void testMasterDeletion() {
        User systemAdminUser2 = TestUtils.buildSystemAdministrator();
        insert systemAdminUser2;
        User systemAdminUser3 = TestUtils.buildSystemAdministrator();
        insert systemAdminUser3;
        CandidateNomination__c master = [SELECT Nominees__c, NominationId__c, Type__c, MasterRecordID__c FROM CandidateNomination__c];
        CandidateNomination__c firstChild = new CandidateNomination__c(NominationId__c = master.NominationId__c, Nominees__c = master.Nominees__c, Description__c = 'Child1');
        CandidateNomination__c secondChild = new CandidateNomination__c(NominationId__c = master.NominationId__c, Nominees__c = master.Nominees__c, Description__c = 'Child2');
        System.runAs(systemAdminUser2) {
            insert firstChild;  
        }
        System.runAs(systemAdminUser3) {
            insert secondChild;  
        }
        Test.startTest();
        Database.DeleteResult result = Database.delete(master, false);
        Test.stopTest();
        CandidateNomination__c firstChildUpdated = [SELECT  Type__c, MasterRecordID__c FROM CandidateNomination__c WHERE Id = :firstChild.Id];
        CandidateNomination__c secondChildUpdated = [SELECT Type__c, MasterRecordID__c FROM CandidateNomination__c WHERE Id = :secondChild.Id];
        System.assert(result.isSuccess());
        System.assertEquals('Master', firstChildUpdated.Type__c);
        System.assertEquals(null, firstChildUpdated.MasterRecordID__c);
        System.assertEquals(firstChildUpdated.Id, secondChildUpdated.MasterRecordID__c);
    }
    @IsTest
    static void testDuplicateInsert() {
        Nomination__c testNomination = [SELECT Id FROM Nomination__c WHERE Name = 'Test Nomination'];
        Contact testContact = [SELECT Id FROM Contact WHERE LastName = 'Test LastName'];
        CandidateNomination__c candidate = TestUtils.buildCandidateNomination(testNomination, testContact);
        Test.startTest();
        Database.SaveResult resultForDuplicate = Database.insert(candidate, false);
        Test.stopTest();
        System.assert(!resultForDuplicate.isSuccess());
        System.assert(resultForDuplicate.getErrors().size() > 0);
        System.assertEquals('You have already nominated this person in this category!',
                resultForDuplicate.getErrors()[0].getMessage());
    }

}

