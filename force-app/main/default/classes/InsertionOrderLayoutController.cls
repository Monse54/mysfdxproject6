public with sharing class InsertionOrderLayoutController {
  @AuraEnabled(cacheable=true)
  public static Insertion_Order__c getInsertionOrder(string opportunityId) {
    Insertion_Order__c io;
    Insertion_Order__c[] ios = [
      SELECT Id
      FROM Insertion_Order__c
      WHERE Opportunity__c = :opportunityId
      LIMIT 1
    ];

    if (ios.size() > 0) {
      io = ios[0];
    }
    return io;
  }

  @AuraEnabled(cacheable=true)
  public static List<Line_Item__c> getLineItems(string insertionOrderID) {
    return [
      SELECT Id, Name
      FROM Line_Item__c
      WHERE Insertion_Order__c = :insertionOrderID
    ];
  }
}