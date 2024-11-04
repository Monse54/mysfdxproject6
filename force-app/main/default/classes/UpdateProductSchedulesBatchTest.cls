@isTest
private class UpdateProductSchedulesBatchTest {
  @testSetup
  static void setup() {
    List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
    Date flightStartDate = Date.newInstance(2021, 5, 12);
    Date flightEndDate = Date.newInstance(2021, 8, 20);

    for (Integer i = 0; i < 1; i++) {
      olis.add(
        CustomProductSchedulingControllerTest.createOpportunityLineItem(
          flightStartDate,
          flightEndDate
        )
      );
    }
           }

  @isTest
  static void test() {
    Test.startTest();
    UpdateProductSchedulesBatch batch = new UpdateProductSchedulesBatch();
    Id batchId = Database.executeBatch(batch);
    Test.stopTest();
  }
}