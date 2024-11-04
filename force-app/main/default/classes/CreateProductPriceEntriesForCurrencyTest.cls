@isTest
public class CreateProductPriceEntriesForCurrencyTest {
  @isTest
  static void createPriceEntriesTest() {
    Test.startTest();

    Id pricebookId = Test.getStandardPricebookId();

    //Instantiate the Pricebook2 record with StandardPricebookId
    Pricebook2 standardPricebook = new Pricebook2(
      Id = Test.getStandardPricebookId(),
      IsActive = true
    );
    update standardPricebook;

    Pricebook2 customPB = new Pricebook2(
      Name = 'Custom Pricebook',
      isActive = true
    );
    insert customPB;

    Product2 product = new Product2(
      Name = 'Test Product',
      ProductCode = 'Code',
      isActive = true,
      CanUseRevenueSchedule = true
    );
    insert product;

    PricebookEntry pbEntry1 = new PricebookEntry(
      Pricebook2Id = pricebookId,
      Product2Id = product.Id,
      UnitPrice = 1200.00,
      IsActive = true
    );
    insert pbEntry1;

    PricebookEntry pbEntry2 = new PricebookEntry(
      Pricebook2Id = customPB.Id,
      Product2Id = product.Id,
      UnitPrice = 600.00,
      IsActive = true
    );
    insert pbEntry2;

    // List of PricebookEntry to be inserted
    List<PricebookEntry> pbeInsert = new List<PricebookEntry>();

    CurrencyType[] allCurrencies = [
      SELECT IsoCode
      FROM CurrencyType
      WHERE IsActive = TRUE
    ];

    for (CurrencyType c : allCurrencies) {
      String isoCode = c.IsoCode;
      System.debug('ISOCode: ' + isoCode);
      pbeInsert.addAll(
        CreateProductPriceEntriesForCurrency.createPriceEntriesForCurrency(
          isoCode
        )
      );
    }

    if (pbeInsert != null && !pbeInsert.isEmpty()) {
      insert pbeInsert;
    }

    Test.StopTest();
  }
}