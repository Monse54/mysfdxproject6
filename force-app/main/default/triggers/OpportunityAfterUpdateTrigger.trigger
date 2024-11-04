trigger OpportunityAfterUpdateTrigger on Opportunity(after update) {
  for (Opportunity opp : Trigger.New) {
    if (Trigger.oldMap.get(opp.id).CSM__c != opp.CSM__c) {
      Opportunity newOpp = [
        SELECT Id, Pricebook2.Name
        FROM Opportunity
        WHERE id = :opp.Id
      ];
      if (newOpp.Pricebook2.Name == Constants.PRICEBOOK_MANAGED) {
        // Call future method
        System.debug('Calling Am update method');
        CMController.updateAMOnCM(opp.CSM__c, opp.id);
      }
    }
  }
}