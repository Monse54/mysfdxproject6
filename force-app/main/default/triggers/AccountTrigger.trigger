/* 
	@author			: Ramesh Kumar Gurusamy
	@team			: CFG
	@description	: Trigger for the Account Object.
	@createdDate	: 23-Dec-2023
	@testClass		: AccountTriggerTest
*/
trigger AccountTrigger on Account(before insert, before update) {
	if(trigger.isInsert && trigger.isBefore) { AccountTriggerHandler.onBeforeInsert(trigger.new); }

	if(trigger.isUpdate && trigger.isBefore) { AccountTriggerHandler.onBeforeUpdate(trigger.new, trigger.oldMap); }
}