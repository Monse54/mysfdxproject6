public class CreateProductPriceEntriesForCurrency {
  public static List<PricebookEntry> createPriceEntriesForCurrency(
    String currencyISOCode
  ) {
    // List of PricebookEntry objects for Currency
    List<PricebookEntry> pbeInsert = new List<PricebookEntry>();

    List<Product2> products = [
      SELECT Id, Name
      FROM Product2
      WHERE IsActive = TRUE AND DisableAutoCurrency__c = FALSE
    ];

    for (Product2 product : products) {
      System.debug('Product: ' + product.Name);
      pbeInsert.addAll(
        createPriceEntriesForProduct(product.Id, currencyISOCode)
      );
    }

    return pbeInsert;
  }

  public static List<PricebookEntry> createPriceEntriesForProduct(
    Id productId,
    String currencyISOCode
  ) {
    // Set of Pricebook2 Ids that product is associated with
    Set<Id> pricebookIds = new Set<Id>();
    // List of PricebookEntry objects for Product and Currency
    List<PricebookEntry> pbeInsert = new List<PricebookEntry>();

    // Get the Standard Price Book ID
    Pricebook2 standardPriceBook = [
      SELECT Id
      FROM Pricebook2
      WHERE isStandard = TRUE
      LIMIT 1
    ];

    // Get Ids for Pricebook that given product is associated with
    for (PricebookEntry pbe : [
      SELECT Pricebook2Id
      FROM PricebookEntry
      WHERE
        Product2Id = :productId
        AND IsActive = TRUE
        AND Pricebook2Id != :standardPriceBook.Id
    ]) {
      pricebookIds.add(pbe.Pricebook2Id);
    }

    // Add PricebookEntry for Standard Pricebook if doesn't exist
    // PricebookEntry for Standard Pricebook should be created
    // before creating PribookEntry for custom Pricebook
    Boolean existingPbe = checkPricebookEntry(
      standardPriceBook.Id,
      productId,
      currencyISOCode
    );
    if (!existingPbe) {
      PricebookEntry pbe = createPricebookEntry(
        standardPriceBook.Id,
        productId,
        currencyISOCode
      );
      pbeInsert.add(pbe);
    }

    // Add PricebookEntry for custom Pricebook if doesn't exist
    for (Id pricebookId : pricebookIds) {
      existingPbe = checkPricebookEntry(
        pricebookId,
        productId,
        currencyISOCode
      );
      if (existingPbe) {
        continue;
      }
      PricebookEntry pbe = createPricebookEntry(
        pricebookId,
        productId,
        currencyISOCode
      );
      pbeInsert.add(pbe);
    }

    System.debug(pbeInsert);
    return pbeInsert;
  }

  public static Boolean checkPricebookEntry(
    Id pricebookId,
    Id productId,
    String currencyISOCode
  ) {
    List<PricebookEntry> pbEntry = [
      SELECT Id
      FROM PricebookEntry
      WHERE
        Pricebook2Id = :pricebookId
        AND Product2Id = :productId
        AND CurrencyIsoCode = :currencyISOCode
      LIMIT 1
    ];

    return !pbEntry.isEmpty();
  }

  public static PricebookEntry createPricebookEntry(
    Id pricebookId,
    Id productId,
    String currencyISOCode
  ) {
    PricebookEntry pbEntry = new PricebookEntry(
      Pricebook2Id = pricebookId,
      Product2Id = productId,
      UnitPrice = 0,
      CurrencyIsoCode = currencyISOCode,
      IsActive = true
    );

    return pbEntry;
  }
}