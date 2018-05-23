/*************************
@Name:ContactTriggerTest
@Author:Venkat Neteesh
@description:Class is to make code coverage for the ContactTrigger
*************************/

@isTest
public class ContactTriggerTest {

    /************************
     @Description: Setup required data for the test cases to execute
    *************************/
    @testSetup static void setup() {
        Account acc = new Account();
        acc.name = 'TestAccount';
        Test.startTest();
        insert acc;
        
    }
    
    /************************
     @Description: Method is to cover positive scenario if the user creating contact with 'Primary' relationship
    *************************/
    public static testmethod void positiveTestScenarios() {
        Account accc = [select id, name from Account where name ='TestAccount' Limit 1];        
        Contact con = new Contact();
        con.Relationship__c ='Primary';
        con.LastName = 'TestLastName';
        con.accountId = accc.Id;
        Id memberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
        con.recordTypeId = memberRecordTypeId;
        Test.startTest();
        insert con;
        Test.stopTest();
    }
    
    /************************
     @Description: Method is to cover the exception case where the user is trying to 
     create a duplicate contact for the same account with relationship 'Primary'
    *************************/
    public static testmethod void negitiveTestScenarios() {
        Account accc = [select id, name from Account where name ='TestAccount' Limit 1];         
        Contact con = new Contact();
        con.Relationship__c ='Primary';
        con.LastName = 'TestLastName';
        con.accountId = accc.Id;
        Test.startTest();
        insert con;
        Id memberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
        Contact conDuplicate = new Contact();
        conDuplicate.Relationship__c ='Primary';
        conDuplicate.LastName = 'TestLastName2';
        conDuplicate.accountId = accc.Id;
        conDuplicate.recordTypeId = memberRecordTypeId;
        try {
        insert conDuplicate;
        }catch(Exception e) {        
        }
        Test.stopTest();
    }
    
}