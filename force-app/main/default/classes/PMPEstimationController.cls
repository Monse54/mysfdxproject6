public with sharing class PMPEstimationController {
  public static void createEntries(Date startDate, Date endDate) {
    List<PMP_Estimation__c> estInsert = new List<PMP_Estimation__c>();
    for (Date d = startDate; d <= endDate; d = d.addDays(1)) {
      PMP_Estimation__c est = new PMP_Estimation__c(
        Date__c = d,
        Partner_PMP__c = 0.0,
        Platform_PMP__c = 0.0,
        Sales_PMP__c = 0.0,
        Programmatic_Others__c = 0.0
      );
      estInsert.add(est);
    }
    insert estInsert;
    System.debug(estInsert.size());
  }

  public static Map<Date, PMP_Estimation__c> getEstimateMap(
    Date startDate,
    Date endDate
  ) {
    List<PMP_Estimation__c> estList = [
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
    List<PMP_Estimation__c> estUpdate = new List<PMP_Estimation__c>();
    Map<Date, PMP_Estimation__c> estMap = new Map<Date, PMP_Estimation__c>();
    Integer i = 0;
    for (Date d = startDate; d <= endDate; d = d.addDays(1)) {
      estMap.put(d, estList[i]);
      i++;
    }
    return estMap;
  }

  public static Map<Date, Common_Bill__c> getActualMap(
    Date startDate,
    Date endDate
  ) {
    List<Common_Bill__c> estList = [
      SELECT
        id,
        date__c,
        Partner_PMP__c,
        Platform_pmp__c,
        LG_Sales_pmp__c,
        Programmatic_Others__c
      FROM Common_Bill__c
      WHERE Date__c >= :startDate AND Date__c <= :endDate
      ORDER BY Date__c ASC
    ];
    List<Common_Bill__c> estUpdate = new List<Common_Bill__c>();
    Map<Date, Common_Bill__c> estMap = new Map<Date, Common_Bill__c>();
    Integer i = 0;
    for (Date d = startDate; d <= endDate; d = d.addDays(1)) {
      estMap.put(d, estList[i]);
      i++;
    }
    return estMap;
  }

  public static PMP_Estimation__c getLastSevenDayAverage(
    Map<Date, Common_Bill__c> actMap,
    Map<Date, PMP_Estimation__c> estMap,
    Date initDate
  ) {
    PMP_Estimation__c est = new PMP_Estimation__c(
      Date__c = initDate,
      Partner_PMP__c = 0.0,
      Platform_PMP__c = 0.0,
      Sales_PMP__c = 0.0,
      Programmatic_Others__c = 0.0
    );
    Decimal partner = 0.0;
    Decimal platform = 0.0;
    Decimal sales = 0.0;
    Decimal others = 0.0;
    for (Integer i = 1; i <= 7; i++) {
      Date d = initDate.addDays(-i);
      if (actMap.containsKey(d)) {
        partner += zeroIfNull(actMap.get(d).Partner_PMP__c);
        platform += zeroIfNull(actMap.get(d).Platform_PMP__c);
        sales += zeroIfNull(actMap.get(d).LG_Sales_PMP__c);
        others += zeroIfNull(actMap.get(d).Programmatic_Others__c);
      } else if (estMap.containsKey(d)) {
        partner += estMap.get(d).Partner_PMP__c;
        platform += estMap.get(d).Platform_PMP__c;
        sales += estMap.get(d).Sales_PMP__c;
        others += estMap.get(d).Programmatic_Others__c;
      }
    }
    partner = partner / 7;
    partner = partner.setScale(2);
    platform = platform / 7;
    platform = platform.setScale(2);
    sales = sales / 7;
    sales = sales.setScale(2);
    others = others / 7;
    others = others.setScale(2);

    est.Partner_PMP__c = partner;
    est.Platform_PMP__c = platform;
    est.Sales_PMP__c = sales;
    est.Programmatic_Others__c = others;
    return est;
  }

  public static Decimal zeroIfNull(Decimal value) {
    return value == null ? 0.0 : value;
  }

  public static void updateNovEntries() {
    Date startDate = Date.newInstance(2021, 11, 1);
    Date switchDate = Date.newInstance(2021, 11, 22);
    Date endDate = Date.newInstance(2021, 11, 30);
    List<PMP_Estimation__c> estUpdate = new List<PMP_Estimation__c>();

    Map<Date, Common_Bill__c> actMap = PMPEstimationController.getActualMap(
      startDate,
      switchDate
    );
    Map<Date, PMP_Estimation__c> estMap = PMPEstimationController.getEstimateMap(
      startDate,
      endDate
    );
    for (Date d = startDate; d <= endDate; d = d.addDays(1)) {
      if (d <= switchDate) {
        Common_Bill__c liCBC = actMap.get(d);
        PMP_Estimation__c est = new PMP_Estimation__c(
          id = estMap.get(d).id,
          Date__c = d,
          Partner_PMP__c = liCBC.Partner_PMP__c,
          Platform_PMP__c = liCBC.Platform_PMP__c,
          Sales_PMP__c = liCBC.LG_Sales_PMP__c,
          Programmatic_Others__c = liCBC.Programmatic_Others__c
        );
        estUpdate.add(est);
      } else {
        PMP_Estimation__c est = PMPEstimationController.getLastSevenDayAverage(
          actMap,
          estMap,
          d
        );
        est.id = estMap.get(d).id;
        //        System.debug(d + ' -> ' + est);
        estUpdate.add(est);
        estMap.put(d, est);
      }
    }
    System.debug(estUpdate.size());
    update estUpdate;
  }

  public static void updateEntries(Date startDate, Date endDate) {
    List<PMP_Estimation__c> estUpdate = new List<PMP_Estimation__c>();

    Date maxDate = Date.today().addDays(-1);
    System.debug('Max Date' + maxDate);
    Map<Date, Common_Bill__c> actMap = PMPEstimationController.getActualMap(
      startDate.addDays(-8),
      maxDate
    );
    Map<Date, PMP_Estimation__c> estMap = PMPEstimationController.getEstimateMap(
      startDate,
      endDate
    );
    for (Date d = startDate; d <= endDate; d = d.addDays(1)) {
      PMP_Estimation__c est;
      if (actMap.containsKey(d)) {
        est = new PMP_Estimation__c(
          id = estMap.get(d).id,
          Date__c = d,
          Partner_PMP__c = actMap.get(d).Partner_PMP__c,
          Platform_PMP__c = actMap.get(d).Platform_PMP__c,
          Sales_PMP__c = actMap.get(d).LG_Sales_PMP__c,
          Programmatic_Others__c = actMap.get(d).Programmatic_Others__c
        );
      } else {
        est = PMPEstimationController.getLastSevenDayAverage(actMap, estMap, d);
        est.id = estMap.get(d).id;
      }

      estUpdate.add(est);
      estMap.put(d, est);
    }
    System.debug(estUpdate.size());
    update estUpdate;
  }
}