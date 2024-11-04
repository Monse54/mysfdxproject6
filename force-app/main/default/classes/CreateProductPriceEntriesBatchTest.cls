@isTest
private class CreateProductPriceEntriesBatchTest {
  @isTest
  static void test() {
    Test.startTest();
    CreateProductPriceEntriesBatch schedulesBatch = new CreateProductPriceEntriesBatch();
    Id batchId = Database.executeBatch(schedulesBatch);
    Test.stopTest();
  }
}