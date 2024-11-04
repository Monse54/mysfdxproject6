public class UpdateProgrammaticOppsBatch implements Database.Batchable<sObject>, Database.Stateful {
  public Integer numSuccess = 0;
  public Integer numFailure = 0;
  public Map<Id, String> failedRecords = new Map<Id, String>();

  public Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(
      'Select id, StageName, CurrencyIsoCode from Opportunity where Pricebook2.Name = \'Self Service\'' +
      ' and id in (Select Opportunity__c from Opportunity_Bill__c)'
    );
  }

  public void execute(Database.BatchableContext bc, List<Opportunity> scope) {
    for (Opportunity opp : scope) {
      try {
        ProgrammaticOpportunityController.updateProgrammaticOpportunity(opp);
        numSuccess += 1;
      } catch (Exception ex) {
        failedRecords.put(opp.Id, ex.getMessage());
        numFailure += 1;
      }
    }
  }

  public void finish(Database.BatchableContext bc) {
    System.debug(numSuccess + ' records updated.');
    System.debug(numFailure + ' records failed!');
    System.debug(failedRecords);
  }
}