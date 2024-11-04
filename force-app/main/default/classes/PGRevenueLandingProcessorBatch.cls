global class PGRevenueLandingProcessorBatch implements Database.Batchable<sObject> {
	
    public static Boolean skipValidations = false;
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String strstatus = 'To be processed';
        return Database.getQueryLocator([
            SELECT Id, Status__c, Time_Bucket__c, Opportunity__c, Status_Message__c, 
                   Campaign_Id__c, Campaign_Name__c, Demand_Partner__c, 
                   Pmp_Type__c, Revenue_Cost__c, Deal_Type__c, 
                   Impressions__c, Deal_Type_Formula__c
            FROM Programmatic_Revenue_Landing__c 
            WHERE Status__c = :strstatus
        ]);
    }

    global void execute(Database.BatchableContext BC, List<Programmatic_Revenue_Landing__c> scope) {
        skipValidations = true;
        Map<String, Programmatic_Revenue_Landing__c> hasopp = new Map<String, Programmatic_Revenue_Landing__c>();
        Map<String, Programmatic_Revenue_Landing__c> noopp = new Map<String, Programmatic_Revenue_Landing__c>();
        List<Programmatic_Revenue_Landing__c> lstpgrevfinal = new List<Programmatic_Revenue_Landing__c>();
        Map<String, Deal__c> insdeal = new Map<String, Deal__c>();
        Set<Id> lstopp = new Set<Id>();
        Set<String> pmptype = new Set<String>();
        List<OpportunityLineItem> newOppLineItems = new List<OpportunityLineItem>();
        
        Set<String> productNameSet = new Set<String>();
        
        for (Programmatic_Revenue_Landing__c temp : scope) {
            if (temp.Opportunity__c != null) {
                hasopp.put(temp.Campaign_Id__c, temp);
                lstopp.add(temp.Opportunity__c);
                productNameSet.add(temp.Deal_Type_Formula__c);
            } else {
                noopp.put(temp.Campaign_Id__c, temp);
                pmptype.add(temp.Pmp_Type__c);
            }
        }
        
        // Include both open and closed opportunities
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>(
            [SELECT Id, Country__c, Pricebook2Id, recordType.DeveloperName, 
                    Flight_Start_Date__c, Flight_End_Date__c, CurrencyIsoCode 
             FROM Opportunity 
             WHERE Id IN :lstopp]
        );

        List<OpportunityLineItem> oppli = [SELECT Id, Product2.Name, OpportunityId, 
                                             Opportunity.recordType.Name, PricebookEntryId 
                                             FROM OpportunityLineItem 
                                             WHERE OpportunityId IN :lstopp];

        // Create a map to hold PricebookEntries
        Map<String, Id> oppPricebookEntryMap = new Map<String, Id>();

        // Query PricebookEntries
        List<PricebookEntry> pricebookEntries = [SELECT Id, Product2Id, Pricebook2Id, CurrencyIsoCode 
                                                  FROM PricebookEntry 
                                                  WHERE Product2.Name IN :productNameSet 
                                                  AND Pricebook2.IsActive = TRUE];
        
        // Populate map with PricebookEntryId by Product2Id
        for (PricebookEntry pbe : pricebookEntries) {
            oppPricebookEntryMap.put(pbe.Pricebook2Id + '-' + pbe.CurrencyIsoCode, pbe.Id);
        }

        for (Programmatic_Revenue_Landing__c temp : hasopp.values()) {
            Boolean found = false;
            
            for (OpportunityLineItem li : oppli) {
                if (li.OpportunityId == temp.Opportunity__c && li.Product2.Name == temp.Deal_Type_Formula__c && !insdeal.containsKey(temp.Campaign_Id__c)) {
                    found = true;
                    
                    // Create the deal
                    Deal__c d = new Deal__c();
                    d.External_Id__c = temp.Campaign_Id__c + '_' + temp.Time_Bucket__c.formatGMT('yyyy-MM-dd HH:mm:ss');
                    d.Deal_Id__c = temp.Campaign_Id__c;
                    d.Date__c = Date.newInstance(temp.Time_Bucket__c.yearGMT(), temp.Time_Bucket__c.monthGMT(), temp.Time_Bucket__c.dayGMT());
                    d.Deal_Name__c = temp.Campaign_Name__c;
                    d.Deal_Type__c = temp.Deal_Type__c;
                    d.PMP_Type__c = temp.Pmp_Type__c;
                    d.Revenue__c = temp.Revenue_Cost__c;
                    d.Impressions__c = temp.Impressions__c;
                    d.Opportunity_Product__c = li.Id;
                    d.Programmatic_Revenue_Landing__c = temp.Id;
                    insdeal.put(temp.Campaign_Id__c, d);
                    break; // exit the loop when found
                }
            }
            
            // If no matching OpportunityLineItem was found, create a new one
            if (!found) {
                
                System.debug(' ## temp.Deal_Type_Formula__c'+ temp.Deal_Type_Formula__c);
                system.debug('## SELECT Id, Name, Family FROM Product2 '+ [SELECT Id, Name, Family FROM Product2] );
                
                Product2 product = [SELECT Id, Name, Family FROM Product2 WHERE Name = :temp.Deal_Type_Formula__c LIMIT 1];
                if (product != null && oppMap.get(temp.Opportunity__c) != null) {
                    OpportunityLineItem newOppLineItem = new OpportunityLineItem();
                    newOppLineItem.OpportunityId = temp.Opportunity__c;
                    newOppLineItem.Product2Id = product.Id;

                    // Fetch the PricebookEntryId for the product
                    Id pricebookEntryId = oppPricebookEntryMap.get(oppMap.get(temp.Opportunity__c).Pricebook2Id + '-' + oppMap.get(temp.Opportunity__c).CurrencyIsoCode);
                    if (pricebookEntryId != null) {
                        newOppLineItem.PricebookEntryId = pricebookEntryId;
                    } else {
                        // Handle case where no matching PricebookEntry was found
                        System.debug('No PricebookEntry found for product: ' + product.Name);
                        continue;
                    }
                    
                    newOppLineItem.Quantity = 1; // Adjust as per your requirements
                    newOppLineItem.UnitPrice = temp.Revenue_Cost__c;
                    newOppLineItem.Audience_Targeting__c = 'None';
                    newOppLineItem.Product_Full_Name__c = 'System Generated Placeholder Product';
                    
                    newOppLineItem.Flight_Start_Date__c = oppMap.get(temp.Opportunity__c).Flight_Start_Date__c;
                    newOppLineItem.Flight_End_Date__c = oppMap.get(temp.Opportunity__c).Flight_End_Date__c;
                    newOppLineItem.Original_Booking_Amount__c = 0;
                    newOppLineItem.Rate__c = 1;

                    List<String> selectedValues = oppMap.get(temp.Opportunity__c).Country__c.split(';');
                    newOppLineItem.Country__c = selectedValues[0];
                    
                    newOppLineItems.add(newOppLineItem);
                    
                    // Create the deal for the newly created OpportunityLineItem
                    Deal__c d = new Deal__c();
                    d.External_Id__c = temp.Campaign_Id__c + '_' + temp.Time_Bucket__c.formatGMT('yyyy-MM-dd HH:mm:ss');
                    d.Deal_Id__c = temp.Campaign_Id__c;
                    d.Date__c = Date.newInstance(temp.Time_Bucket__c.yearGMT(), temp.Time_Bucket__c.monthGMT(), temp.Time_Bucket__c.dayGMT());
                    d.Deal_Name__c = temp.Campaign_Name__c;
                    d.Deal_Type__c = temp.Deal_Type__c;
                    d.PMP_Type__c = temp.Pmp_Type__c;
                    d.Revenue__c = temp.Revenue_Cost__c;
                    d.Impressions__c = temp.Impressions__c;
                    d.Opportunity_Product__c = null; // Will be updated later after insert
                    d.Programmatic_Revenue_Landing__c = temp.Id;
                    insdeal.put(temp.Campaign_Id__c, d);
                }
            }
        }
        
        // Insert the new OpportunityLineItems and update the deals with the new OpportunityLineItem Ids
        if (!newOppLineItems.isEmpty()) {
            Database.insert(newOppLineItems, false);
            
            for (OpportunityLineItem oli : newOppLineItems) {
                for (Deal__c d : insdeal.values()) {
                    if (d.Opportunity_Product__c == null && d.External_Id__c.startsWith(oli.OpportunityId)) {
                        d.Opportunity_Product__c = oli.Id;
                    }
                }
            }
        }
        
        // Upsert the deals
        List<Deal__c> insd = insdeal.values();
        Database.UpsertResult[] urList = Database.upsert(insd, Deal__c.External_Id__c, false);
        for (Integer i = 0; i < urList.size(); i++) {
            if (urList[i].isSuccess()) {
                Programmatic_Revenue_Landing__c temp = new Programmatic_Revenue_Landing__c();
                temp.Id = insd[i].Programmatic_Revenue_Landing__c;
                temp.Status__c = 'Success';
                temp.Status_Message__c = '';
                lstpgrevfinal.add(temp);
            } else {
                Programmatic_Revenue_Landing__c temp = new Programmatic_Revenue_Landing__c();
                temp.Id = insd[i].Programmatic_Revenue_Landing__c;
                temp.Status__c = 'Error';
                temp.Status_Message__c = String.valueOf(urList[i].getErrors());
                lstpgrevfinal.add(temp);
            }
        }
        
        update lstpgrevfinal;
    }

    global void finish(Database.BatchableContext BC) {}
}