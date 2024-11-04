/* 
	@author			: Ramesh Kumar Gurusamy
	@team			: CFG
	@description	: Handler for OpportunityContactRoleTrigger.
	@createdDate	: 11-Feb-2024
	@testClass		: OpportunityTriggerTest
*/
public class OpportunityContactRoleTriggerHandler {
	private static final String ADMIN_PROFILE_ID = '00e5Y000002dkqbQAA';
	
	public static void onBeforeDelete(List<OpportunityContactRole> ocrs) {
		String profileId = UserInfo.getProfileId();
        System.debug('profileId***' + profileId);
        if(!ADMIN_PROFILE_ID.equalsIgnoreCase(profileId) && !OpportunityTriggerHandler.updateFromOppTrigger) { ocrs[0].addError('You are not allowed to delete the opportunity contact role, please contact system administrator.'); }
	}
}