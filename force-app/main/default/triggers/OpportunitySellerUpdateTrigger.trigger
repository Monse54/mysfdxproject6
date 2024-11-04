trigger OpportunitySellerUpdateTrigger on Opportunity_Seller__c(
  before insert,
  before update,
  after delete
) {
  if (Trigger.isInsert || Trigger.isUpdate) {
    // Fetch the custom settings for verifying various fields
    Trigger_Settings__c ts = Trigger_Settings__c.getOrgDefaults();
    Boolean isActive = ts.Opp_Seller_Trigger_Active__c;

    for (Opportunity_Seller__c os : Trigger.New) {
      System.debug('Opportunity Seller trigger ' + os + ' ' + isActive);

      List<Opportunity_Seller__c> oppSellers = [
        SELECT id, Seller__r.id, Opportunity__r.id, Percentage__c
        FROM Opportunity_Seller__c
        WHERE Opportunity__r.id = :os.Opportunity__c
      ];
      Decimal percentageSum = 0.0;
      if (Trigger.isInsert) {
        percentageSum = os.Percentage__c;
      }
      Set<Id> sellers = new Set<Id>();
      for (Opportunity_Seller__c oppSeller : oppSellers) {
        if (oppSeller.id == os.id) {
          percentageSum += os.Percentage__c;
          continue;
        }
        percentageSum += oppSeller.Percentage__c;
        sellers.add(oppSeller.Seller__r.id);
      }
      if (isActive && sellers.contains(os.Seller__c)) {
        os.Seller__c.addError('Cannot add the same seller twice');
      }
      if (isActive && percentageSum > 100) {
        os.Percentage__c.addError(
          'Total Percentage from all sellers cannot be more than 100%'
        );
      }

      if (Trigger.isInsert) {
        List<OpportunityLineItem> olis = [
          SELECT id
          FROM OpportunityLineItem
          WHERE Opportunity.Id = :os.Opportunity__c
        ];
        List<Opportunity_Product_Seller__c> opss = new List<Opportunity_Product_Seller__c>();
        for (OpportunityLineItem oli : olis) {
          Opportunity_Product_Seller__c ops = new Opportunity_Product_Seller__c(
            Opportunity_Product__c = oli.Id,
            Seller__c = os.Seller__c,
            Seller_Percentage__c = os.Percentage__c
          );
          opss.add(ops);
        }
        // System.debug('Opportunity Seller trigger ' + opss);
        insert opss;
      }
      if (Trigger.isUpdate) {
        List<OpportunityLineItem> olis = [
          SELECT id
          FROM OpportunityLineItem
          WHERE Opportunity.Id = :os.Opportunity__c
        ];

        List<Opportunity_Product_Seller__c> opss = [
          SELECT id, Seller__r.Name, Opportunity_Product__c
          FROM Opportunity_Product_Seller__c
          WHERE
            Opportunity_Product__c IN :olis
            AND Seller__c = :Trigger.oldMap.get(os.Id).Seller__c
        ];
        List<Opportunity_Product_Seller__c> updatedOPS = new List<Opportunity_Product_Seller__c>();
        List<Opportunity_Product_Seller__c> insertOPS = new List<Opportunity_Product_Seller__c>();
        Map<Id, Opportunity_Product_Seller__c> oliMap = new Map<Id, Opportunity_Product_Seller__c>();
        // System.debug('Opportunity Seller trigger ' + opss);
        for (Opportunity_Product_Seller__c ops : opss) {
          oliMap.put(ops.Opportunity_Product__c, ops);
        }
        // System.debug('Opportunity Seller trigger ' + oliMap);
        for (OpportunityLineItem oli : olis) {
          Opportunity_Product_Seller__c ops = new Opportunity_Product_Seller__c();
          ops.Opportunity_Product__c = oli.Id;
          ops.Seller__c = os.Seller__c;
          ops.Seller_Percentage__c = os.Percentage__c;
          if (oliMap.containsKey(oli.Id)) {
            ops.id = oliMap.get(oli.Id).Id;
            updatedOps.add(ops);
          } else {
            insertOps.add(ops);
          }
        }
        // System.debug('Opportunity Seller trigger updates ' + updatedOPS);
        // System.debug('Opportunity Seller trigger inserts ' + insertOps);
        if (insertOps.size() > 0) {
          insert insertOPS;
        }
        if (updatedOps.size() > 0) {
          update updatedOPS;
        }
      }
    }
  }
  if (Trigger.isDelete && Trigger.isAfter) {
    for (Opportunity_Seller__c os : Trigger.old) {
      List<Opportunity_Product_Seller__c> opss = [
        SELECT id
        FROM Opportunity_Product_Seller__c
        WHERE
          Opportunity_Product__r.OpportunityId = :os.Opportunity__c
          AND Seller__c = :os.Seller__c
      ];

      delete opss;
    }
  }

}