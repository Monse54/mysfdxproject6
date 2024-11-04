public with sharing class CasesController {
  @AuraEnabled(cacheable=true)
  public static List<Case> getCase(string recordId) {
    return [SELECT Id, Asana_URL__c, CaseNumber FROM Case WHERE Id = :recordId];
  }
}