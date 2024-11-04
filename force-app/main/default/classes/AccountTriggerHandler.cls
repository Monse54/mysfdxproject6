/* 
	@author			: Ramesh Kumar Gurusamy
	@team			: CFG
	@description	: Handler for AccountTrigger
	@createdDate	: 23-Dec-2023
	@testClass		: AccountTriggerTest
*/
public class AccountTriggerHandler {
	private static final String ADVERTISER = 'Advertiser';
	private static final String AGENCY = 'Agency';
	private static final String PARTNER = 'Partner';
	private static final String RESELLER = 'Reseller';
	private static final String BRAND = 'Brand (Client)';
	private static final String ADMIN_PROFILE = '00e5Y000002dkqb';

	public static void onBeforeInsert(List<Account> triggerNew) {
		for(Account acc: triggerNew) {
			if(ADVERTISER.equalsIgnoreCase(acc.Record_Type_Name__c)) { acc.Type = BRAND; }
			else if(AGENCY.equalsIgnoreCase(acc.Record_Type_Name__c)) { acc.Type = AGENCY; }
			else if(PARTNER.equalsIgnoreCase(acc.Record_Type_Name__c)) { acc.Type = RESELLER; }
		}
	}

	public static void onBeforeUpdate(List<Account> triggerNew, Map<Id, Account> triggerOldMap) {
        String profileId = UserInfo.getProfileId();
		for(Account acc: triggerNew) {
			Account accOld = triggerOldMap.get(acc.Id);
			if(acc != null && accOld != null && (acc.RecordTypeId != accOld.RecordTypeId) && (String.isNotBlank(profileId) && profileId.startsWithIgnoreCase(ADMIN_PROFILE))) {
				if(ADVERTISER.equalsIgnoreCase(acc.Record_Type_Name__c)) { acc.Type = BRAND; }
				else if(AGENCY.equalsIgnoreCase(acc.Record_Type_Name__c)) { acc.Type = AGENCY; }
				else if(PARTNER.equalsIgnoreCase(acc.Record_Type_Name__c)) { acc.Type = RESELLER; }
            } else if(acc != null && accOld != null && (acc.RecordTypeId != accOld.RecordTypeId)) { acc.addError('You don\'t have permission to update the record type, please contact your system administrator.'); }
		}
	}
}