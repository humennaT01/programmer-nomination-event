@isTest
public with sharing class ContactTrHTest {
    @TestSetup
    static void makeData(){
        Contact contact1 = TestUtils.buildContact();
        insert contact1;
        Contact contact2 = TestUtils.buildContact();
        insert contact2;
        Contact contact3 = TestUtils.buildContact();
        insert contact3;
    }
    @isTest
    static void testContactUUID() {
        Contact testContact = [SELECT UUID__c FROM Contact WHERE LastName = 'Test LastName' LIMIT 1];
        Test.startTest();
        String uuid = testContact.UUID__c;
        Test.stopTest(); 
        System.assertNotEquals(null, uuid, 'There is no UUID');
    }
    @isTest 
    static void testContactListUUID() {
        List<Contact> contacts = [SELECT LastName, UUID__c FROM Contact WHERE Name = 'Test LastName']; 
        Test.startTest();
        List<String> uuidList = new List<String>(); 
        for(Contact contact : contacts){
            uuidList.add(contact.UUID__c);
        } 
        Test.stopTest();
        System.assertEquals(3, uuidList.size(), 'There is no UUID in the List');
    }
}