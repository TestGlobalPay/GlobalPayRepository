/*************************
@Name:ContactTrigger
@Author:Venkat Neteesh
@description:Trigger is to maintain one primary contact for single account
*************************/
trigger ContactTrigger on Contact (before insert,before update) {    
    ContactTriggerHelper.checkPrimaryContactExists(Trigger.new,Trigger.old,Trigger.oldMap);   
}