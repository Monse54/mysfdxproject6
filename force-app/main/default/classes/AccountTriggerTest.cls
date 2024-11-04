/* 
	@author			: Ramesh Kumar Gurusamy
	@team			: CFG
	@createdDate	: 23-Dec-2023
	@description	: Test class for AccountTrigger.
*/
@isTest
public class AccountTriggerTest {
	static testMethod void testCreateAccount() {
		Account acc = new Account(name='test acc');
		acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
		insert acc;
		acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
		update acc;
		acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
		update acc;
	}
}