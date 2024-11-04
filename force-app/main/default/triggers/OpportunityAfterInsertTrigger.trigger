trigger OpportunityAfterInsertTrigger on Opportunity(after insert) {
  List<Opportunity_Seller__c> osList = new List<Opportunity_Seller__c>();
  for (Opportunity opp : Trigger.new) {
    List<Opportunity_Seller__c> existingOs = [
      SELECT id
      FROM Opportunity_Seller__c
      WHERE Opportunity__c = :opp.Id AND Seller__c = :opp.OwnerId
    ];
    if (existingOs.size() == 0) {
      Opportunity_Seller__c os = new Opportunity_Seller__c();
      os.Opportunity__c = opp.Id;
      os.Seller__c = opp.OwnerId;
      os.Percentage__c = 100;
      osList.add(os);
    }
  }
  insert osList;
}