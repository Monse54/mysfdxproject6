public with sharing class ProgrammaticDealRequestController {
  @AuraEnabled(cacheable=true)
  public static List<Programmatic_Deal_Request__c> getProgrammaticDealRequest(
    string recordId
  ) {
    return [
      SELECT Id, Asana_URL__c
      FROM Programmatic_Deal_Request__c
      WHERE Id = :recordId
    ];
  }
}