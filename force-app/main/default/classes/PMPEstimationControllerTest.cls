@isTest
public class PMPEstimationControllerTest {
  @isTest
  public static void createEntriesTest() {
    Test.startTest();
    Date startDate = Date.newInstance(2022, 1, 1);
    Date endDate = Date.newInstance(2022, 1, 30);
    PMPEstimationController.createEntries(startDate, endDate);
    List<PMP_Estimation__c> estimates = [
      SELECT id
      FROM PMP_Estimation__c
      WHERE Date__c >= :startDate AND Date__c <= :endDate
    ];
    System.assert(
      estimates.size() == 30,
      '30 estimate entries should be created'
    );
    Test.stopTest();
  }

  @isTest
  public static void getEstimateMapTest() {
    Test.startTest();
    Date startDate = Date.newInstance(2022, 1, 1);
    Date endDate = Date.newInstance(2022, 1, 3);
    PMPEstimationController.createEntries(startDate, endDate);
    Map<Date, PMP_Estimation__c> estMap = PMPEstimationController.getEstimateMap(
      startDate,
      endDate
    );

    System.assert(estMap.size() == 3, 'Estimate Map should have 3 entries');
    for (Date d : estMap.keySet()) {
      System.assert(estMap.get(d) != null, 'No entry in map should be null');
    }
    Test.stopTest();
  }

  @isTest
  public static void getLastSevenDayAverageTest() {
    Test.startTest();
    Date estDate = Date.newInstance(2022, 1, 4);
    Date actDate = Date.newInstance(2022, 1, 1);
    Map<Date, PMP_Estimation__c> estMap = new Map<Date, PMP_Estimation__c>();
    Map<Date, Common_Bill__c> actMap = new Map<Date, Common_Bill__c>();
    Integer revenue = 100;
    // We need to enter revenue values for last 7 days, so adding estimates for last 4 days and actuals for 3 days before that
    for (Date d = estDate; d < estDate.addDays(4); d = d.addDays(1)) {
      PMP_Estimation__c est = new PMP_Estimation__c(
        Date__c = d,
        Partner_PMP__c = revenue,
        Platform_PMP__c = revenue,
        Sales_PMP__c = revenue,
        Programmatic_Others__c = revenue
      );
      estMap.put(d, est);
      revenue += 100;
    }
    revenue += 100;
    for (Date d = actDate; d < estDate; d = d.addDays(1)) {
      Common_Bill__c act = new Common_Bill__c(
        Date__c = d,
        Partner_PMP__c = revenue,
        Platform_PMP__c = revenue,
        LG_Sales_PMP__c = revenue,
        Programmatic_Others__c = revenue
      );
      actMap.put(d, act);
      revenue += 100;
    }
    PMP_Estimation__c avgEst = PMPEstimationController.getLastSevenDayAverage(
      actMap,
      estMap,
      estDate.addDays(4)
    );

    // Revenue values:
    //   For actuals: 500 600 700
    //   For Estimates: 100 200 300 400
    //   Avg : 442.86
    System.assert(
      avgEst.Partner_PMP__c == 442.86,
      'Partner PMP on average estimate incorrect'
    );
    System.assert(
      avgEst.Platform_PMP__c == 442.86,
      'Platform PMP on average estimate incorrect'
    );
    System.assert(
      avgEst.Sales_PMP__c == 442.86,
      'Sales PMP on average estimate incorrect'
    );
    System.assert(
      avgEst.Programmatic_Others__c == 442.86,
      'Programmatic Others on average estimate incorrect'
    );
    System.assert(
      avgEst.Date__c == estDate.addDays(4),
      'Date on average estimate incorrect'
    );
    System.debug('PMP avg ' + avgEst);
    Test.stopTest();
  }

  @isTest
  public static void updateEntriesTest() {
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