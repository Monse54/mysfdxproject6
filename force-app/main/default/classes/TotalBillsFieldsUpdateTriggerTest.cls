@isTest
public class TotalBillsFieldsUpdateTriggerTest {
    @isTest
  public static void TotalBillsFieldsUpdateTriggertestmethod() {
    Test.startTest();
    Date startDate = Date.today().addDays(-1);
    Date endDate = Date.today().addDays(6);

    Product2 productSocial = new Product2(
      Name = 'Social',
      ProductCode = 'Code',
      isActive = true,
      CanUseRevenueSchedule = true
    );
    insert productSocial;

    PMPEstimationController.createEntries(startDate, endDate);
    List<Common_Bill__c> bills = new List<Common_Bill__c>();

    // Create actual bills upto start date
    for (Date d = startDate.addDays(-8); d <= startDate; d = d.addDays(1)) {
      Common_Bill__c bill = new Common_Bill__c(
        Date__c = d,
        Partner_PMP__c = 200,
        Platform_PMP__c = 200,
        LG_Sales_PMP__c = 200,
        Programmatic_Others__c = 200
      );
      bills.add(bill);
    }
    insert bills;
    PMPEstimationController.updateEntries(startDate, endDate);
    List<PMP_Estimation__c> ests = [
      SELECT
        id,
        date__c,
        Partner_pmp__c,
        Platform_pmp__c,
        sales_pmp__c,
        Programmatic_Others__c
      FROM PMP_Estimation__c
      WHERE Date__c >= :startDate AND Date__c <= :endDate
      ORDER BY Date__c ASC
    ];

    for (Integer i = 0; i < ests.size(); i++) {
      System.assert(
        ests[i].Partner_PMP__c == 200,
        'Partner PMP value is incorrect for ' + ests[i].Date__c
      );
      System.assert(
        ests[i].Platform_PMP__c == 200,
        'Platform PMP value is incorrect for ' + ests[i].Date__c
      );
      System.assert(
        ests[i].Sales_PMP__c == 200,
        'Sales PMP value is incorrect for ' + ests[i].Date__c
      );
      System.assert(
        ests[i].Programmatic_Others__c == 200,
        'Sales PMP value is incorrect for ' + ests[i].Date__c
      );
    }

    Test.stopTest();
  }
   
}