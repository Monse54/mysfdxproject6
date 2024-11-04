trigger OpportunityDeleteTrigger on Opportunity(before delete) {
  	Trigger_Settings__c settings = Trigger_Settings__c.getInstance();
    Boolean isOpportunityTriggerActive = settings.Opportunity_Triggers_Active__c;
  Id userId = UserInfo.getUserId();
  String userProfile = [
    SELECT Name
    FROM Profile
    WHERE Id IN (SELECT ProfileId FROM User WHERE Id = :userId)
  ]
  .Name;

  for (Opportunity opp : Trigger.old) {
    if (isOpportunityTriggerActive &&
      (opp.has_been_closed__c == TRUE) && userProfile != 'System Administrator'
    ) {
      opp.addError(
        'Opportunity cannot be deleted if Opportunity is Closed atleast once.'
      );
    }
  }

}