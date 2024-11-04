/* 
    @author         : Ramesh Kumar Gurusamy
    @team           : CFG
    @description    : Trigger for the Opportunity Object.
    @createdDate    : 22-Dec-2023
    @testClass      : OpportunityTriggerTest
*/
trigger OpportunityTrigger on Opportunity(after insert, after update, before update, before insert, before delete) {
    if(Trigger.isDelete){OpportunityTriggerHandler.OnbeforeDelete(Trigger.old);}
    if(Trigger.isInsert && Trigger.isAfter) { OpportunityTriggerHandler.onAfterInsert(Trigger.New); }
   
    if(Trigger.isInsert && Trigger.isBefore) {
        OpportunityTriggerHandler.onBeforeInsert(Trigger.New);
        OpportunityTriggerHandler.onClone(Trigger.New);                                   
                                             }
    
    if(Trigger.isUpdate && Trigger.isBefore) { OpportunityTriggerHandler.onBeforeUpdate(Trigger.New, Trigger.OldMap);}
    if(Trigger.isUpdate && Trigger.isAfter) { OpportunityTriggerHandler.onAfterUpdate(Trigger.New, Trigger.Newmap, Trigger.OldMap); }
}