trigger AccountTrigger on Account (before insert, before update, after insert, before delete) {

   if (Trigger.isAfter && Trigger.isInsert) {
       AccountTriggerHelper.isParentStatusUpdate(Trigger.new,NULL, true, false, false,null);
   }
    
  if(Trigger.isBefore && Trigger.isUpdate) {
         AccountTriggerHelper.isParentStatusUpdate(Trigger.new,Trigger.old, false, true, false,Trigger.oldMap);                            
   }   

   if(Trigger.isDelete && Trigger.isBefore) {
       AccountTriggerHelper.isParentStatusUpdate(Trigger.new,Trigger.old, false, false, true,null);
   }
}