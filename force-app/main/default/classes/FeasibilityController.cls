public with sharing class FeasibilityController {
  @AuraEnabled(cacheable=true)
  public static List<Feasibilty__c> getFeasibility(string recordId) {
    return [SELECT Id, Asana_URL__c FROM Feasibilty__c WHERE Id = :recordId];
  }
}