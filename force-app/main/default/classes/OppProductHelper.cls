public class OppProductHelper {
  @AuraEnabled
  public static Id cloneOppProduct(OpportunityLineItem oli) {
    OpportunityLineItem newOli = new OpportunityLineItem(
      OpportunityId = oli.OpportunityId,
      UnitPrice = oli.UnitPrice,
      Flight_Start_Date__c = oli.Flight_Start_Date__c,
      Flight_End_Date__c = oli.Flight_End_Date__c,
      MinImpressions__c = oli.MinImpressions__c,
      CPM__c = oli.CPM__c,
      Value__c = oli.Value__c,
      Product_Full_Name__c = oli.Product_Full_Name__c,
      Retail_CPM__c = oli.Retail_CPM__c,
      Type__c = oli.Type__c,
      Country__c = oli.Country__c,
      Reason__c = oli.Reason__c,
      Product_Booking_Date__c = oli.Product_Booking_Date__c,
      Product2Id = oli.Product2Id
    );
    insert newOli;
    return newOli.id;
  }
}