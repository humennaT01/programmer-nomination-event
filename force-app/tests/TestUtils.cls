@isTest
public without sharing class TestUtils {
    public static Campaign buildCampaign(){
        Campaign camp = new Campaign();
        camp.Name = 'Test Campaign';
        camp.IsActive = true;
        camp.Type = 'Voting';
        return camp;
    }

    public static Nomination__c buildNomination(Campaign camp){
        Nomination__c nom = new Nomination__c();
        nom.Name = 'Test Nomination';
        nom.CampaignId__c = camp.Id;
        return nom;
    }

    public static Contact buildContact(){
        Contact cont = new Contact();
        cont.LastName = 'Test LastName';
        return cont;
    }

    public static Contact buildContactWithEmail(){
        Contact voter = new Contact();
        voter.LastName = 'Test LastName With Email';
        voter.Email = 'test.voter.email@gmail.com';
        return voter;
    }

    public static CandidateNomination__c buildCandidateNomination(Nomination__c nomination, Contact cont){
        CandidateNomination__c nominee = new CandidateNomination__c();
        nominee.NominationId__c = nomination.Id;
        nominee.Nominees__c = cont.Id;
        nominee.Description__c = 'Test Discription';
        return nominee;
    }

    public static Vote__c buildVote(CandidateNomination__c nominee, Contact voter){
        Vote__c vote = new Vote__c(VoterId__c=voter.Id, CandidateNominationId__c=nominee.Id);
        return vote;
    }

    public static User buildStandartUser() {
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standtc', Email='standarduser2@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
            UserName=uniqueUserName, UserPermissionsMarketingUser = true, IsActive = true, UserPermissionsSFContentUser=true);
            return u;
    }

    public static User buildSystemAdministrator() {
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='system_administrator4@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
            UserName=uniqueUserName);
            return u;
    }

    public static User buildStandartUserWithBasicPS() {
        String uniqueUserName = 'standarduserc' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standtc', Email='basicPSuser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testingc', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
            UserName=uniqueUserName, UserPermissionsMarketingUser = true, IsActive = true, UserPermissionsSFContentUser=true);
            return u;
    }

    public static PermissionSetAssignment assignBasicPermissionSetToUser(User u) {
        PermissionSet basicPS = [SELECT Id FROM PermissionSet WHERE Name = 'Basic'];
        PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = basicPS.Id, AssigneeId = u.Id);
        return psa;
    }
}
