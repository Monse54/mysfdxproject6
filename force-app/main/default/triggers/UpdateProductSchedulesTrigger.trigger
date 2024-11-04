trigger UpdateProductSchedulesTrigger on OpportunityLineItem(
  after insert,
  after update
) {
  Set<Id> oppIds = new Set<Id>();
  for (OpportunityLineItem oli : Trigger.New) {
    if (oli.opportunityId != null) {
      oppIds.add(oli.opportunityId);
    }
  }

  // Map used to update opportunity Flight Start/End date/Country
  Map<Id, Opportunity> mapOpp = new Map<Id, Opportunity>(
    [
      SELECT
        id,
        Name,
        StageName,
        Flight_Start_Date__c,
        Flight_End_Date__c,
        Country__c,
        (SELECT Country__c FROM OpportunityLineItems)
      FROM Opportunity
      WHERE Id IN :oppIds
    ]
  );

  for (OpportunityLineItem oli : Trigger.New) {
    // System.debug('Update product schedules trigger ' + oli);
    if (
      Trigger.isInsert ||
      (Trigger.isUpdate &&
      (Trigger.oldMap.get(oli.Id).Flight_Start_Date__c !=
      oli.Flight_Start_Date__c ||
      Trigger.oldMap.get(oli.Id).Flight_End_Date__c != oli.Flight_End_Date__c ||
      Trigger.oldMap.get(oli.Id).End_Date__c != oli.End_Date__c ||
      Trigger.oldMap.get(oli.Id).Start_Date__c != oli.Start_Date__c ||
      Trigger.oldMap.get(oli.Id).Total_Booking_Amount__c != oli.Total_Booking_Amount__c || 
      oli.UnitPrice != oli.Total_Booking_Amount__c
      ))
    ) {
      if (Trigger.isUpdate) {
        System.debug('Updating Opportunity Line Item');
        System.debug(
          'OLD Flight_Start_Date__c: ' +
          Trigger.oldMap.get(oli.Id).Flight_Start_Date__c
        );
        System.debug('NEW Flight_Start_Date__c: ' + oli.Flight_Start_Date__c);
        System.debug(
          'OLD Flight_End_Date__c: ' +
          Trigger.oldMap.get(oli.Id).Flight_End_Date__c
        );
        System.debug('NEW Flight_End_Date__c: ' + oli.Flight_End_Date__c);
        System.debug('Old Unit Price' + Trigger.oldMap.get(oli.Id).UnitPrice);
        System.debug('New Unit Price' + oli.UnitPrice);
      }

      try {
        // Create custom revenues
        Date StartDate, EndDate;
        System.debug('Record Type Name : ' + oli.Opportunity_Record_Type__c);
        if (oli.Opportunity_Record_Type__c == Constants.RECORD_TYPE_MANAGED) {
          StartDate = oli.Start_Date__c.date();
          EndDate = oli.End_Date__c.date();
        } else {
          StartDate = oli.Flight_Start_Date__c;
          EndDate = oli.Flight_End_Date__c;
        }

        System.debug('Start Date : ' + StartDate);
        System.debug('End Date : ' + EndDate);

        CustomProductSchedulingController.createRevenueSchedulesFuture(
          oli.Id,
          StartDate,
          EndDate,
          oli.Total_Booking_Amount__c,
          'Daily',
          'Divide'
        );

        // Update Oppt flight start end date based on this flight start end date.
        Opportunity opp = null;
        // if (mapOpp.containsKey(oli.OpportunityId)) {
        opp = mapOpp.get(oli.OpportunityId);
        // } else {
        //   opp = [
        //     SELECT
        //       id,
        //       Name,
        //       StageName,
        //       Flight_Start_Date__c,
        //       Flight_End_Date__c,
        //       Country__c,
        //       (SELECT country__c FROM OpportunityLineItems)
        //     FROM Opportunity
        //     WHERE id = :oli.OpportunityId
        //   ];
        // }
        opp.Flight_Start_Date__c = DateUtility.minDate(
          opp.Flight_Start_Date__c,
          oli.Flight_Start_Date__c
        );
        opp.Flight_End_Date__c = DateUtility.maxDate(
          opp.Flight_End_Date__c,
          oli.Flight_End_Date__c
        );
        mapOpp.put(opp.Id, opp);
      } catch (Exception ex) {
        System.debug('update Product schedule trigger ' + ex.getMessage());
      }
    }

    if (Trigger.isInsert) {
      // Insert opportunity product seller for each seller for this product
      List<Opportunity_Seller__c> oss = [
        SELECT id, Seller__c, Percentage__c
        FROM Opportunity_Seller__c
        WHERE Opportunity__c = :oli.OpportunityId
      ];
      List<Opportunity_Product_Seller__c> insertOPS = new List<Opportunity_Product_Seller__c>();
      for (Opportunity_Seller__c os : oss) {
        Opportunity_Product_Seller__c ops = new Opportunity_Product_Seller__c();
        ops.Opportunity_Product__c = oli.Id;
        ops.Seller__c = os.Seller__c;
        ops.Seller_Percentage__c = os.Percentage__c;
        insertOPS.add(ops);
      }

      insert insertOPS;
    }

    Opportunity opp = null;
    opp = mapOpp.get(oli.OpportunityId);
    List<String> countries = new List<String>();
    for (OpportunityLineItem country_oli : opp.OpportunityLineItems) {
      if (country_oli.Country__c != null) {
        countries.add(country_oli.Country__c);
      }
    }
    Set<String> uniqueCountries = new Set<String>(countries);
    List<String> updatedList = new List<String>(uniqueCountries);
    updatedList.sort();
    opp.Country__c = String.join(updatedList, ';');
    mapOpp.put(oli.OpportunityId, opp);
    // if (
    //   Trigger.isInsert ||
    //   (Trigger.isUpdate &&
    //   (oli.Type__c == Constants.PRODUCT_TYPE_MAKE_GOOD ||
    //   oli.Type__c == Constants.PRODUCT_TYPE_ADDED_VALUE) &&
    //   (Trigger.oldMap.get(oli.Id).Type__c == Constants.PRODUCT_TYPE_DEFAULT ||
    //   Trigger.oldMap.get(oli.Id).Type__c == Constants.PRODUCT_TYPE_INCREMENTAL))
    // ) {
    //   // If a Make Good/ Added Value product was inserted send a notification mail
    //   // Only send mail if value > 10K or value > 5%(opp booking amount)
    //   if (
    //     (oli.Type__c == Constants.PRODUCT_TYPE_ADDED_VALUE ||
    //     oli.Type__c == Constants.PRODUCT_TYPE_MAKE_GOOD)
    //   ) {
    //     Boolean condition = oli.Value__c >= 10000;
    //     if (!condition) {
    //       Opportunity opp = [
    //         SELECT id, amount
    //         FROM Opportunity
    //         WHERE id = :oli.OpportunityId
    //       ];
    //       condition = oli.Value__c > (0.05 * opp.amount);
    //     }
    //     if (condition) {
    //       String subject =
    //         'A ' +
    //         oli.Type__c +
    //         ' product was add to opportunity ' +
    //         oli.OpportunityId;

    //       String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
    //       String body =
    //         '<h3> ' +
    //         oli.Type__c +
    //         ' product added to opportunity </h3>' +
    //         '<br/> ' +
    //         'User: ' +
    //         UserInfo.getUserEmail() +
    //         '<br/>Reason: ' +
    //         oli.Reason__c +
    //         '<br/>View it here: ' +
    //         baseUrl +
    //         '/' +
    //         oli.id;

    //       String result = EmailUtility.sendSingleEmailWithoutTemplate(
    //         'fahad@lgads.tv',
    //         '',
    //         '',
    //         subject,
    //         body,
    //         true
    //       );
    //       System.debug(result);
    //     }
    //   }
    // }
  }
  if (!mapOpp.values().isEmpty()) {
    System.debug('Updating opps ' + mapOpp.values().size());
    update mapOpp.values();
  }
}