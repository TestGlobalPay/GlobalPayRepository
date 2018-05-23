@isTest
private class IdeasTrigger_Test {
    static testMethod void runPositiveTestCases() {
        List<Community> communitiess = [Select Name, IsActive, Id From Community where IsActive=true];
        Idea idea_existing = new Idea();
        idea_existing.Title = 'TestIdeaTitle';
        idea_existing.body = 'TestIdeaBody';
        Test.startTest();
        idea_existing.communityId = communitiess[0].Id;
        insert idea_existing;
        idea_existing.True_Record__c = true;
        
        update idea_existing;
        Test.stopTest();
        
    }
}