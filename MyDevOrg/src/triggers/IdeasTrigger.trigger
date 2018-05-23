/*****
@Description: Trigger to create Request objects when idea object is true request becomes true
@Date Created: 06/09/2017
@Author:Harish
*****/
trigger IdeasTrigger on Idea (After update) {

    List<Idea> ideasList = Trigger.New;
    Map<Id,Idea> oldIdeaMap = Trigger.OldMap;
    List<Idea> ideasToConvertAsRequestList = new List<Idea>();
    List<ART_Request__c> listOfRequestsToBeCreated = new List<ART_Request__c>();
    
    for(Idea ideaObj : ideasList) {
        if(ideaObj.True_Record__c && ideaObj.True_Record__c != oldIdeaMap.get(ideaObj.Id).True_Record__c ) {
            ideasToConvertAsRequestList.add(ideaObj);
        }
    }
    
    if(!ideasToConvertAsRequestList.isEmpty()) {
        for(Idea convertingIdea : ideasToConvertAsRequestList) {
            ART_Request__c requestObj = new ART_Request__c();
            requestObj.name = convertingIdea.Title;
            requestObj.Subject__c = convertingIdea.body;
            requestObj.Type_of_request__c = 'Enhancements';
            requestObj.Status__c = '2-Authorized';
            listOfRequestsToBeCreated.add(requestObj);
        }
    }
    
    if(!listOfRequestsToBeCreated.isEmpty()) {
        Database.Insert(listOfRequestsToBeCreated,false);
    }

}