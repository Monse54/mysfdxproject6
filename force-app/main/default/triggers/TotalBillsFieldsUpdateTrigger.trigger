trigger TotalBillsFieldsUpdateTrigger on Common_Bill__c(
  before insert,
  before update
) {
  Product2 product = [SELECT Id FROM Product2 WHERE Name = 'Social'][0];
  for (Common_Bill__c bill : Trigger.new) {
    Decimal agg = (Decimal) [
        SELECT sum(Revenue) sum
        FROM OpportunityLineItemSchedule
        WHERE
          ScheduleDate = :bill.Date__c
          AND OpportunityLineItem.Product2Id = :product.Id
          AND OpportunityLineItem.Opportunity.StageName = 'Closed Won'
      ][0]
      .get('sum');
    bill.Social__c = agg;
  }
}