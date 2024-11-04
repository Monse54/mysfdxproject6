public class OperationalPlacementHandlerUpsert {
  @future
  public static void OperationalPlacementUpsert(
    Set<Id> opportunityLineItemsId
  ) {
    list<OpportunityLineItem> opportunityLineItems = [
      SELECT
        id,
        Rate__c,
        Original_Booking_Amount__c,
        IO_Impression_Goal__c,
        Frequency_Cap__c,
        Day_Part__c,
        CurrencyIsoCode,
        TotalPrice,
        Audience_Targeting__c,
        Product_Full_Name__c,
        Total_Booking_Amount__c,
        Start_Date__c,
        UnitPrice,
        End_Date__c
      FROM OpportunityLineItem
      WHERE id IN :opportunityLineItemsId
    ];
    if (opportunityLineItems.size() > 0) {
      system.debug('come in OperationalPlacementUpsert');
      Map<Id, Operational_Placement__c> operationalPlacementsToUpsert = new Map<Id, Operational_Placement__c>();

      Set<Id> oliIds = new Set<Id>();
      for (OpportunityLineItem oli : opportunityLineItems) {
        // This will work for Managed services only : These fields are mandatory for those type of records.
        if(oli.Start_Date__c != null && oli.End_Date__c != null && oli.Total_Booking_Amount__c != null){
          //Date StartDate = oli.Start_Date__c.date();
          //Date EndDate = oli.End_Date__c.date();
          oliIds.add(oli.Id);
          /*try{
          CustomProductSchedulingController.createRevenueSchedules(
            oli.Id,
            StartDate ,
            EndDate,
            oli.Total_Booking_Amount__c,
            'Daily',
            'Divide'
          );
          } catch (DmlException e) {
            System.debug('Error during upsert: ' + e.getMessage());
          }*/
        }
      }
      system.debug('oliIds' + oliIds);
      if (!oliIds.isEmpty()) {
        List<Operational_Placement__c> existingOpsPlacements = [
          SELECT
            Id,
            Opportunity_Product__c,
            Audience_Targeting__c,
            CreatedById,
            CurrencyIsoCode,
            Daypart__c,
            End_Date__c,
            Frequency_Cap__c,
            IO_Impression_Goal__c,
            Native_WebOS_Units_App_Based_Exclusions__c,
            Name,
            Original_Booking_Amount__c,
            OwnerId,
            Placement_Display_Name__c,
            Rate__c,
            Start_Date__c,
            Total_Booking_Amount__c
          FROM Operational_Placement__c
          WHERE Opportunity_Product__c IN :oliIds
        ];
        system.debug('existingOpsPlacements' + existingOpsPlacements);
        for (Operational_Placement__c op : existingOpsPlacements) {
          operationalPlacementsToUpsert.put(op.Opportunity_Product__c, op);
        }
        //DeleteAndCreateSchedules(oliIds, opportunityLineItems);
      }
      List<Operational_Placement__c> opsPlacementsToUpsert = new List<Operational_Placement__c>();

      for (OpportunityLineItem oli : opportunityLineItems) {
        Operational_Placement__c op = operationalPlacementsToUpsert.get(oli.Id);

        if (op == null) {
          system.debug('op' + op);
          op = new Operational_Placement__c();
          op.Opportunity_Product__c = oli.Id;
        }

        op.Placement_Display_Name__c = oli.Product_Full_Name__c;
        // op.Audience_Segment_Details__c = oli.Audience_Segment_Details__c;
        op.Audience_Targeting__c = oli.Audience_Targeting__c;
        op.CurrencyIsoCode = oli.CurrencyIsoCode;
        op.Daypart__c = oli.Day_Part__c;
        op.End_Date__c = Date.valueof(oli.End_Date__c);
        op.Frequency_Cap__c = oli.Frequency_Cap__c;
        op.IO_Impression_Goal__c = String.valueof(oli.IO_Impression_Goal__c);
        op.Original_Booking_Amount__c = oli.Original_Booking_Amount__c;
        op.Rate__c = oli.Rate__c;
        op.Start_Date__c = Date.valueof(oli.Start_Date__c);
        op.Total_Booking_Amount__c = oli.Total_Booking_Amount__c;

        opsPlacementsToUpsert.add(op);
      }
      system.debug('opsPlacementsToUpsert' + opsPlacementsToUpsert);
      if (!opsPlacementsToUpsert.isEmpty()) {
        try {
          upsert opsPlacementsToUpsert;
        } catch (DmlException e) {
          System.debug('Error during upsert: ' + e.getMessage());
        }
      }
    }
  }
}