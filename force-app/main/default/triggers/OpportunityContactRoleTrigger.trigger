/* 
	@author			: Ramesh Kumar Gurusamy
	@team			: CFG
	@description	: Trigger for the OpportunityContactRole Object.
	@createdDate	: 11-Feb-2024
	@testClass		: OpportunityTriggerTest
*/
trigger OpportunityContactRoleTrigger on OpportunityContactRole(before delete) {
    if(Trigger.isDelete && Trigger.isBefore) { OpportunityContactRoleTriggerHandler.onBeforeDelete(Trigger.old); }
}