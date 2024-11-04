public class UpdateProductSchedulesBatch implements Database.Batchable<sObject>, Database.Stateful {
  public Integer numSuccess = 0;
  public Integer numFailure = 0;
  public Map<Id, String> failedRecords = new Map<Id, String>();

  public Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(
      'SELECT Id, Flight_Start_Date__c, Flight_End_Date__c, UnitPrice' +
      ' FROM OpportunityLineItem'
    );
  }

  public void execute(
    Database.BatchableContext bc,
    List<OpportunityLineItem> scope
  ) {
    for (OpportunityLineItem product : scope) {
      try {
        string message = '';
        if (product.Flight_Start_Date__c == null) {
          message += 'Flight_Start_Date__c is null\n';
        }
        if (product.Flight_End_Date__c == null) {
          message += 'Flight_End_Date__c is null\n';
        }
        if (message != '') {
          CalloutException ex = new CalloutException();
          ex.setMessage(message.trim());
          throw ex;
        }

        CustomProductSchedulingController.createRevenueSchedules(
          product.Id,
          product.Flight_Start_Date__c,
          product.Flight_End_Date__c,
          product.UnitPrice,
          'Daily',
          'Divide'
        );
        numSuccess += 1;
      } catch (Exception ex) {
        failedRecords.put(product.Id, ex.getMessage());
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