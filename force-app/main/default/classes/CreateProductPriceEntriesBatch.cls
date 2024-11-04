public class CreateProductPriceEntriesBatch implements Database.Batchable<sObject>, Database.Stateful {
  // List of PricebookEntry to be inserted
  List<PricebookEntry> pbeInsert = new List<PricebookEntry>();

  public Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(
      'SELECT IsoCode FROM CurrencyType WHERE IsActive = TRUE'
    );
  }

  public void execute(
    Database.BatchableContext bc,
    List<CurrencyType> allCurrencies
  ) {
    for (CurrencyType c : allCurrencies) {
      String isoCode = c.IsoCode;
      System.debug('ISOCode: ' + isoCode);
      pbeInsert.addAll(
        CreateProductPriceEntriesForCurrency.createPriceEntriesForCurrency(
          isoCode
        )
      );
    }
  }

  public void finish(Database.BatchableContext bc) {
    if (pbeInsert != null && !pbeInsert.isEmpty()) {
      insert pbeInsert;
    }
    System.debug('Done');
  }
}