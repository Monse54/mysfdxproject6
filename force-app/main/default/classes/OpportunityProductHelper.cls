public class OpportunityProductHelper {

    
    
    public static Integer getNumberOfTimezonesByCountry(OpportunityLineItem oppProduct) {
        Integer timezonesCount = 0;
    
        if (oppProduct.Country__c != null) {
            Country_region_mapping__mdt mapping = [
                SELECT All_TimeZone__c
                FROM Country_region_mapping__mdt 
                WHERE MasterLabel = :oppProduct.Country__c
                LIMIT 1
            ];
    
            if (mapping != null && mapping.All_TimeZone__c != null) {
                timezonesCount = mapping.All_TimeZone__c.split('/').size() - 1;
            }
        }
    
        return timezonesCount;
    }

    public static void populateTimeZone(List<OpportunityLineItem> oppProducts) {
        Set<String> countryNames = new Set<String>();
        for (OpportunityLineItem oppProduct : oppProducts) {
            if (oppProduct.Country__c != null) {
                countryNames.add(oppProduct.Country__c);
            }
        }
        
        Map<String, Country_region_mapping__mdt> countryToTimeZoneMap = new Map<String, Country_region_mapping__mdt>();
        if (!countryNames.isEmpty()) {
            for (Country_region_mapping__mdt mapping : [
                SELECT DeveloperName, MasterLabel, All_TimeZone__c, country_code_2__c, country_code_3__c, primary_tz__c
                FROM Country_region_mapping__mdt 
                WHERE MasterLabel IN :countryNames
            ]) {
                countryToTimeZoneMap.put(mapping.MasterLabel, mapping);
            }
        }
        User currentUser = [SELECT TimeZoneSidKey FROM User WHERE Id = :UserInfo.getUserId()];
        for (OpportunityLineItem oppProduct : oppProducts) {
            if (oppProduct.Country__c != null) {
                Country_region_mapping__mdt mapping = countryToTimeZoneMap.get(oppProduct.Country__c);
                if (mapping != null) {
                    oppProduct.Time_Zone__c = mapping.primary_tz__c;
                    
                }
            }
            
            DateTime maxTimeUTC ;
            maxTimeUTC  = oppProduct.Max_Extension_Time__c;
            
            DateTime maxDateTimeUserTimeZone ;
            if(maxTimeUTC != null){
                oppProduct.Max_End_Time_Extension_IO_Timezone__c = timeZoneConvert(oppProduct.Max_Extension_Time__c);
            }
            oppProduct.End_Time_IO_Timezone__c = timeZoneConvert(oppProduct.End_Date__c);
            oppProduct.Start_Time_IO_Timezone__c = timeZoneConvert(oppProduct.Start_Date__c);
        }
    }
    
    public static String timeZoneConvert(DateTime input){
        if(input != null){
            String myDate = input.format('yyyy-MM-dd HH:mm:ss');
            return myDate;
        }else{
            return null;
        }
    }
    
    public static void updateFlightDates(Set<Id> oppIds, Boolean isOppOverride , Map<Id,Opportunity> oppMap) {
        
        // Query opportunities with their line items and record types
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        
        
        List<Opportunity> oppList = [SELECT Id, Flight_Start_Date__c, Flight_End_Date__c, RecordType.DeveloperName,
                                     (SELECT Start_Date__c, End_Date__c, Flight_Start_Date__c, Flight_End_Date__c FROM OpportunityLineItems)
                                     FROM Opportunity 
                                     WHERE Id IN :oppIds];
        
        
        for (Opportunity opp : oppList) {
            Date minStartDate =  null;
            Date maxEndDate = null;
            if(isOppOverride == true){
                minStartDate = oppMap.get(opp.id).Flight_Start_Date__c;
                maxEndDate = oppMap.get(opp.id).Flight_End_Date__c;
            }
            
            
            if (opp.RecordType.DeveloperName == 'One_Managed_Service') {
                
                // Use StartDate and EndDate from OpportunityLineItems
                for (OpportunityLineItem oli : opp.OpportunityLineItems) {
                    
                    if (oli.Start_Date__c != null && (minStartDate == null || convertToUserTimeZone(oli.Start_Date__c) < minStartDate)) {
                        minStartDate = oli.Start_Date__c.date();
                    }
                    if (oli.End_Date__c != null && (maxEndDate == null || convertToUserTimeZone(oli.End_Date__c) > maxEndDate)) {
                        maxEndDate = oli.End_Date__c.date();
                    }
                    
                }
            } else {
                for (OpportunityLineItem oli : opp.OpportunityLineItems) {
                    if (oli.Flight_Start_Date__c != null && (minStartDate == null || convertToUserTimeZone(oli.Flight_Start_Date__c) < minStartDate)) {
                        minStartDate = convertToUserTimeZone(oli.Flight_Start_Date__c);
                    }
                    if (oli.Flight_End_Date__c != null && (maxEndDate == null || convertToUserTimeZone(oli.Flight_End_Date__c) > maxEndDate)) {
                        maxEndDate = convertToUserTimeZone(oli.Flight_End_Date__c);
                    }
                }
            }
            
            if (isOppOverride ||opp.Flight_Start_Date__c != minStartDate || opp.Flight_End_Date__c != maxEndDate) {
                opp.Flight_Start_Date__c = minStartDate;
                opp.Flight_End_Date__c = maxEndDate;
                
                if(isOppOverride && oppMap.get(opp.Id)!= null ){
                    oppMap.get(opp.Id).Flight_Start_Date__c = minStartDate;
                    oppMap.get(opp.Id).Flight_End_Date__c = maxEndDate;
                }else{
                    oppsToUpdate.add(opp);
                }
            }
        }
        
        if (!oppsToUpdate.isEmpty()) {
            update oppsToUpdate;
        }
    }
    
    public static date convertToUserTimeZone(DateTime dt){
        
        Integer timeZoneOffsetMs = UserInfo.getTimeZone().getOffset(dt);
        DateTime userTimeZoneDateTime = dt.addMinutes(timeZoneOffsetMs/60000);
        return  userTimeZoneDateTime.date();
        
    }
    
    /*public static void updateDiscountBasedOnAcc(List<OpportunityLineItem> oli) {
        if (oli.isEmpty()) {
            return; 
        }
        
        Set<Id> oppIds = new Set<Id>();
        for (OpportunityLineItem ol : oli) {
            oppIds.add(ol.OpportunityId);
        }
        
        List<Opportunity> opplist = [SELECT Id, Billing_Level__c, Country__c, Agency__c, AccountId 
                                     FROM Opportunity 
                                     WHERE Id IN :oppIds];
        
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>(opplist);
        Set<Id> agencyIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        Set<String> countrySet = new Set<String>();
        
        for (Opportunity opp : opplist) {
            if (opp.Billing_Level__c == 'Account') {
                accountIds.add(opp.AccountId);
            } else if (opp.Billing_Level__c == 'Agency') {
                agencyIds.add(opp.Agency__c);
            }
            if (opp.Country__c != null) {
                countrySet.add(opp.Country__c);
            }
        }
        
        List<Discount__c> discountRecords = [SELECT Id, Account__c, Discount_Percentage__c, Country__c 
                                             FROM Discount__c 
                                             WHERE (Account__c IN :accountIds OR Account__c IN :agencyIds) 
                                             AND Country__c IN :countrySet];
        
        Map<String, Decimal> discountMap = new Map<String, Decimal>();
        for (Discount__c discount : discountRecords) {
            String key = discount.Account__c + ':' + discount.Country__c;
            discountMap.put(key, discount.Discount_Percentage__c);
        }
        
        for (OpportunityLineItem ol : oli) {
            Opportunity opp = oppMap.get(ol.OpportunityId);
            if (opp != null) {
                String key;
                if (opp.Billing_Level__c == 'Account') {
                    key = opp.AccountId + ':' + opp.Country__c;
                } else if (opp.Billing_Level__c == 'Agency') {
                    key = opp.Agency__c + ':' + opp.Country__c;
                }
                
                if (key != null && discountMap.containsKey(key)) {
                    Decimal discountValue = discountMap.get(key);
                    if (discountValue != null ) { 
                        ol.Discount = discountValue; 
                    }
                }
            }
        }
    }*/
    
    
   public static void updateImpressionGoalAmount(List<OpportunityLineItem> lineItemList1) {
       Set<Id> opportunityIds = new Set<Id>();
       for (OpportunityLineItem oli : lineItemList1) {
           opportunityIds.add(oli.OpportunityId);
       }

       List<Opportunity> oppListToUpdate = new List<Opportunity>();
       
       List<Opportunity> oppList = [
           SELECT Id, IO_Impression_Goal__c,(SELECT Id, IO_Impression_Goal__c, OpportunityId FROM OpportunityLineItems)
           FROM Opportunity 
           WHERE Id IN :opportunityIds
       ];
       
       for (Opportunity opp : oppList) {
           Decimal sum = 0; 
           for(OpportunityLineItem oli : opp.OpportunityLineItems){
               if(oli!= null && oli.IO_Impression_Goal__c != null){
               		sum = sum + oli.IO_Impression_Goal__c;
               }
           }
           
           Opportunity oppToUpdate = new Opportunity();	
           oppToUpdate.Id = opp.Id;
           oppToUpdate.IO_Impression_Goal__c = String.valueOf(sum);
           
           oppListToUpdate.add(oppToUpdate);
       }
       
       
       if (!oppListToUpdate.isEmpty()) {
           Database.update(oppListToUpdate, false);
       }
	}
    
    public static void copyProduct(List<OpportunityLineItem> oliNewList) {
        
        // Step 1: Collect Opportunity IDs/ productids where Product2Id is different from Product__c
        Set<Id> productIds = new Set<Id>();
        Set<Id> oppIds = new Set<Id>();
        for (OpportunityLineItem oli : oliNewList) {
            if (oli.Product2Id != oli.Product__c) {
                oppIds.add(oli.OpportunityId);
                productIds.add(oli.Product__c);
            }
        }
        
        // Step 2: Query Opportunities with Pricebook2Id, CurrencyIsoCode
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>(
            [SELECT Id, Pricebook2Id, CurrencyIsoCode 
             FROM Opportunity 
             WHERE Id IN :oppIds]
        );
    
        // Step 3: Gather unique Product2 Ids and Pricebook2/Currency combinations
    	Set<Id> pricebookIds = new Set<Id>();
        for (Opportunity opp : oppMap.values()) {
            pricebookIds.add(opp.Pricebook2Id);
        }
    
        // Step 4: Query all relevant PricebookEntry records
        List<PricebookEntry> pricebookEntries = [
            SELECT Id, Product2Id, Pricebook2Id, CurrencyIsoCode 
            FROM PricebookEntry 
            WHERE Product2Id IN :productIds 
              AND Pricebook2Id IN :pricebookIds
              AND IsActive = true
        ];
    
        // Step 5: Create a composite key map (Product2Id + Pricebook2Id + CurrencyIsoCode)
        Map<String, PricebookEntry> pricebookEntryMap = new Map<String, PricebookEntry>();
        for (PricebookEntry pbe : pricebookEntries) {
            String compositeKey = pbe.Product2Id + '_' + pbe.Pricebook2Id + '_' + pbe.CurrencyIsoCode;
            pricebookEntryMap.put(compositeKey, pbe);
        }
    
        // Step 6: Update each OpportunityLineItem with the new Product2Id and PricebookEntryId
        for (OpportunityLineItem oli : oliNewList) {
            Opportunity opp = oppMap.get(oli.OpportunityId);
            if (oli.Product2Id != oli.Product__c && opp != null) {

                // Retrieve the PricebookEntry using the composite key of Product2Id, Pricebook2Id, and CurrencyIsoCode
                String compositeKey = oli.Product__c + '_' + opp.Pricebook2Id + '_' + opp.CurrencyIsoCode;
                PricebookEntry pbe = pricebookEntryMap.get(compositeKey);
    
                if (pbe != null) {
                    oli.PricebookEntryId = pbe.Id;
                    // Set the new Product2Id
                	oli.Product2Id = oli.Product__c;
                } else {
                    System.debug('No active PricebookEntry found for Product2Id: ' + oli.Product__c + 
                                 ', Pricebook2Id: ' + opp.Pricebook2Id + 
                                 ', CurrencyIsoCode: ' + opp.CurrencyIsoCode);
                }
            }
        }
    }


}