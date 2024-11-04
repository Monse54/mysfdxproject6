public class ProgrammaticOpportunityController {
  public static void updateProgProducts(
    List<OpportunityLineItem> olis,
    Double totalAmount,
    Date startDate,
    Date endDate,
    Boolean hasSchedules
  ) {
    if (olis.size() > 0) {
      Integer i = 0;
      for (OpportunityLineItem oli : olis) {
        Boolean hasChanged = false;

        if (oli.CPM__c == null) {
          oli.CPM__c = 0;
          hasChanged = true;
        }
        if (oli.CPM__c == 0 && (oli.Reason__c == null || oli.Reason__c == '')) {
          oli.Reason__c = 'Programmatic Opp';
          hasChanged = true;
        }
        if (oli.MinImpressions__c == null) {
          oli.MinImpressions__c = 0;
          hasChanged = true;
        }
        if (hasChanged) {
          update oli;
        }
        if (i == 0) {
          // Put the revenue amount in first pmp product
          oli.Original_booking_amount__c = totalAmount;
          oli.Flight_Start_Date__c = startDate;
          oli.Flight_End_Date__c = endDate;
          update oli;
        } else {
          if (oli.UnitPrice != 0) {
            // make revenue amount for other pmp product 0
            oli.Original_booking_amount__c = 0;
            update oli;
          }
        }
        i += 1;
      }
    }
  }

  public static void updateProgrammaticOpportunity(Opportunity opp) {
    Double progTotalAmount = 0.0;
    Date progStartDate;
    Date progEndDate;
    Double pgTotalAmount = 0.0;
    Date pgStartDate;
    Date pgEndDate;

    // Get all opportunity Bills for the opp
    List<Opportunity_Bill__c> bills = [
      SELECT id, Type__c, Revenue__c, Opportunity__c, Date__c
      FROM Opportunity_Bill__c
      WHERE Opportunity__c = :opp.Id
    ];
    if (bills.size() == 0) {
      return;
    }

    // Get All products for the opp
    List<OpportunityLineItem> olisPMP = [
      SELECT
        id,
        Product2.Name,
        Flight_Start_Date__c,
        Flight_End_Date__c,
        CPM__c,
        Reason__c,
        MinImpressions__c,
        UnitPrice,
        Original_booking_amount__c
      FROM OpportunityLineItem
      WHERE
        OpportunityId = :opp.Id
        AND Product2.Name = :Constants.PRODUCT_PROG_PMP
      ORDER BY CreatedDate
    ];
    List<OpportunityLineItem> olisPG = [
      SELECT
        id,
        Product2.Name,
        Flight_Start_Date__c,
        Flight_End_Date__c,
        CPM__c,
        Reason__c,
        MinImpressions__c,
        UnitPrice,
        Original_booking_amount__c
      FROM OpportunityLineItem
      WHERE
        OpportunityId = :opp.Id
        AND Product2.Name = :Constants.PRODUCT_PROG_GUARANTEED
      ORDER BY CreatedDate
    ];
    for (OpportunityLineItem oli : olisPMP) {
      progStartDate = DateUtility.minDate(progStartDate, oli.Flight_Start_Date__c);
      progEndDate = DateUtility.maxDate(progEndDate, oli.Flight_End_Date__c);
    }
    for (OpportunityLineItem oli : olisPG) {
      pgStartDate = DateUtility.minDate(pgStartDate, oli.Flight_Start_Date__c);
      pgEndDate = DateUtility.maxDate(pgEndDate, oli.Flight_End_Date__c);
    }
    // Sum the Revenue of this bills and calc flight dates
    for (Opportunity_Bill__c bill : bills) {
      if (bill.Type__c == Constants.PRODUCT_PROG_GUARANTEED) {
        pgTotalAmount += bill.Revenue__c;
        pgStartDate = DateUtility.minDate(pgStartDate, bill.Date__c);
        pgEndDate = DateUtility.maxDate(pgEndDate, bill.Date__c);
      } else {
        progTotalAmount += bill.Revenue__c;
        progStartDate = DateUtility.minDate(progStartDate, bill.Date__c);
        progEndDate = DateUtility.maxDate(progEndDate, bill.Date__c);
      }
    }
    System.debug(
      'Prog Opp controller ' +
      progTotalAmount +
      ' ' +
      progStartDate +
      ' ' +
      progEndDate +
      ' ' +
      pgTotalAmount +
      ' ' +
      pgStartDate +
      ' ' +
      pgEndDate
    );
    // System.debug('Prog Opp controller ' + olis.size() + ' ' + olis[0].id);
    // Check if the opp has Programmatic PMP product
    updateProgProducts(
      olisPMP,
      progTotalAmount,
      progStartDate,
      progEndDate,
      true
    );
    updateProgProducts(olisPG, pgTotalAmount, pgStartDate, pgEndDate, true);
  }
}