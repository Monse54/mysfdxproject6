trigger OpportunityProductUpdateTrigger on OpportunityLineItem(
    before insert,
    after insert,
    after update,
    before update,
    after delete,
    before delete
) {
    // Constants
    String STAGE_VERBAL_CONFIRM = 'Verbal Confirm';
    String STAGE_CLOSED_WON = 'Closed Won';
    String SELF_SERVICE = 'Self Service';
    String PROGRAMMATIC_PMP = 'Programmatic PMP';
    public static Boolean isFirstTime = true;
    
    // Get Opportunity stage position
    // This would help us know whether certain stage
    // is before or after some other stage
    Set<Id> oppIds = new Set<Id>();
    
    
    if (Trigger.isInsert || Trigger.isUpdate) {
        for (OpportunityLineItem oli : Trigger.new) {
            oppIds.add(oli.OpportunityId);
        }
    }
    
    /*   Map<Id, Decimal> oppImpressionGoals = new Map<Id, Decimal>();

List<OpportunityLineItem> relatedLineItems = [
SELECT OpportunityId, IO_Impression_Goal__c 
FROM OpportunityLineItem 
WHERE OpportunityId IN :oppIds
];

for (OpportunityLineItem oli : relatedLineItems) {
if (oli.IO_Impression_Goal__c != null) {
if (oppImpressionGoals.containsKey(oli.OpportunityId)) {
oppImpressionGoals.put(oli.OpportunityId, oppImpressionGoals.get(oli.OpportunityId) + oli.IO_Impression_Goal__c);
} else {
oppImpressionGoals.put(oli.OpportunityId, oli.IO_Impression_Goal__c);
}
}
}

List<Opportunity> oppsToUpdate = new List<Opportunity>();
for (Id oppId : oppIds) {
String existingImpressionGoal = [SELECT IO_Impression_Goal__c FROM Opportunity WHERE Id = :oppId].IO_Impression_Goal__c;
Opportunity opp = new Opportunity(
Id = oppId,
IO_Impression_Goal__c = oppImpressionGoals.get(oppId) + (existingImpressionGoal != null ? existingImpressionGoal : '0')
);
oppsToUpdate.add(opp);
}

if (!oppsToUpdate.isEmpty()) {
//  update oppsToUpdate;
} */ 
    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        
        for(OpportunityLineItem oli: trigger.new){
            
            if(oli.Rolling_Time_Zone__c == 'Yes'){
                integer timezonesCount = OpportunityProductHelper.getNumberOfTimezonesByCountry(oli);
                if(timezonesCount == 1){
                   oli.addError('You cannot select \'Yes\' for rolling timezone as ' + oli.Country__c + ' has just one timezone'); 
                }
            }
            
            
        }
        
        OpportunityProductHelper.copyProduct(Trigger.new);
        
        //OpportunityProductHelper.updateDiscountBasedOnAcc(trigger.new);
        OpportunityProductHelper.populateTimeZone(Trigger.new); // Assuming this is a valid helper method
        // Sep 18 2024 : Removing the validation from trigger and moving to a VR "For_Rate_Waiting_on_Assets_Closed_Won"
        /*Id profileId=userinfo.getProfileId();
        
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        
        for(OpportunityLineItem oli : trigger.new){
            
            if(Trigger.oldMap!= null && profileName != 'System Administrator' && oli.Rate__c != Trigger.oldMap.get(oli.Id).Rate__c && oli.Opportunity_Record_Type__c == '1-Managed Service' && oli.has_been_closed__c ){
                
                oli.addError('You do not have permission to edit the Rate field for Managed Service Opportunities. If changes are necessary, please contact an administrator.');
                
            }
            
        }*/
    }    
    
    if(trigger.isAfter && (trigger.isinsert || trigger.isupdate)){
        Set<Id> ids = new Set<Id>();
        for (OpportunityLineItem oli : Trigger.new) {
            ids.add(oli.OpportunityId);
        }
        
        if(!System.isFuture()){
            OperationalPlacementHandlerUpsert.OperationalPlacementUpsert(ids);
            isFirstTime = false;        
        }
        OpportunityProductHelper.updateFlightDates(ids,false,null); 
        OpportunityProductHelper.updateImpressionGoalAmount(trigger.new);
    }
    Map<String, Integer> stages = new Map<String, Integer>();
    Integer index = 0;
    for (
        PicklistEntry value : Opportunity.StageName.getDescribe()
        .getPicklistValues()
    ) {
        stages.put(value.getValue(), index++);
    }
    
    // Map used to update opportunity Flight Start/End date
    Map<Id, Opportunity> mapOpp = new Map<Id, Opportunity>();
    
    // Fetch the custom settings for verifying various fields
    Trigger_Settings__c ts = Trigger_Settings__c.getOrgDefaults();
    Boolean isActive = ts.Opp_Product_Trigger_Active__c;
    
    if (Trigger.isInsert || Trigger.isUpdate) {
        // PreFetch opps, products to reduce soql queries
        Set<Id> oppIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();
        for (OpportunityLineItem oli : Trigger.new) {
            if (oli.OpportunityId != null) {
                oppIds.add(oli.OpportunityId);
            }
            if (oli.Product2Id != null) {
                productIds.add(oli.Product2Id);
            }
        }
        
        Map<Id, Opportunity> oppById = new Map<Id, Opportunity>(
            [
                SELECT id, Name, StageName, Pricebook2.Name, Country__c
                FROM Opportunity
                WHERE Id IN :oppIds
            ]
        );
        
        Map<Id, Product2> productById = new Map<Id, Product2>(
            [SELECT id, Name FROM Product2 WHERE id IN :productIds]
        );
        
        for (OpportunityLineItem oli : Trigger.New) {
            System.debug(
                ' Opportunity product update trigger ' +
                oli.UnitPrice +
                ' ' +
                oli.Flight_Start_Date__c +
                ' ' +
                oli.Flight_End_Date__c
            );
            // System.debug(' Opportunity product update trigger ' + Trigger.oldMap.get(oli.Id).UnitPrice + ' ' + Trigger.oldMap.get(oli.Id).Flight_Start_Date__c + ' ' + Trigger.oldMap.get(oli.Id).Flight_End_Date__c);
            Opportunity opp = oppById.get(oli.OpportunityId);
            Product2 product = productById.get(oli.Product2Id);
            
            // A programmatic opp can have only one Programmatic PMP product
            // if (
            //   Trigger.isInsert &&
            //   opp.Pricebook2.Name == SELF_SERVICE &&
            //   product.Name == PROGRAMMATIC_PMP
            // ) {
            //   List<OpportunityLineItem> olis = [
            //     SELECT id
            //     FROM OpportunityLineItem
            //     WHERE OpportunityId = :opp.Id AND Product2.Name = :PROGRAMMATIC_PMP
            //   ];
            //   if (olis.size() > 0) {
            //     oli.UnitPrice.addError(
            //       'Cannot add more than 1 Programmatic PMP product'
            //     );
            //   }
            // }
            
            // Don't allow insert a product if opportunity is closed won.
            if (isActive && !PGRevenueLandingProcessorBatch.skipValidations && Trigger.isInsert && opp.StageName == STAGE_CLOSED_WON) {
                // oli.UnitPrice.addError('Adding products to CLOSED WON Opportunities is not allowed');
                throw new IllegalArgumentException(
                    'Adding products to CLOSED WON Opportunities is not allowed. Please move the Opportunity to previous stage.'
                );
            }
            
            // Check if min impressions is entered
            if (product != null && 
                product.Name != Constants.PRODUCT_ROADBLOCK &&
                product.Name != Constants.PRODUCT_SPONSORED_SEARCH &&
                product.Name != Constants.PRODUCT_INSIGHTS
               ) {
                   if (oli.CPM__c != null && oli.MinImpressions__c == null) {
                       // If Min Impressions is empty calc it else leave it as it is
                       if (oli.CPM__c == 0) {
                           oli.MinImpressions__c = 0;
                       } else {
                           oli.MinImpressions__c = Math.abs(
                               (oli.UnitPrice / oli.CPM__c) * 1000
                           );
                       }
                   }
               } else if (  product != null && product.Name == Constants.PRODUCT_ROADBLOCK) {
                   // CPM cannot be null for Roadblock
                   if (isActive && oli.CPM__c != null) {
                       /*   oli.CPM__C.addError(
'Roadblock products should not have CPM - ' + product.Id
); */
                   }
               }
            
            // Validity checks
            if (isActive) {
                // Products must not have type null
                /* if (oli.Type__c == null) {
oli.Type__c.addError('Please select a type for the product');
}*/
                // Reason is necessary for all non default Products
                /*if (
oli.Type__c != Constants.PRODUCT_TYPE_DEFAULT &&
oli.Reason__c == null
) {
oli.Reason__c.addError(
'Reason is mandatory for Incremental/Make Good/Added Value Products.'
);
}*/
                
                /*Product Booking date is mandatory for incremental products
if (
oli.Type__c == Constants.PRODUCT_TYPE_INCREMENTAL &&
oli.Product_Booking_Date__c == null
) {
oli.Product_Booking_Date__c.addError(
'Product Booking Date is mandatory for Revision Products.'
);
}*/
                
                // If CPM = 0 and product is not roadblock then its a Make good case So reason is mandatory
                /*if ( product != null &&
product.Name != Constants.PRODUCT_ROADBLOCK &&
oli.CPM__c == 0 &&
oli.Reason__c == null
) {
oli.Reason__c.addError('Reason is mandatory if CPM = 0');
}*/
                
                // If product type is Make good / added value then Value field is required and booking amount should be 0
                /*if (
oli.Type__c == Constants.PRODUCT_TYPE_MAKE_GOOD ||
oli.Type__c == Constants.PRODUCT_TYPE_ADDED_VALUE
) {
if (oli.Value__c == null) {
oli.Value__c.addError(
'Make Good/ Added Value products must have a value amount'
);
}
if (oli.UnitPrice != 0) {
oli.UnitPrice.addError(
'Make Good/ Added Value products should have booking amount = 0'
);
}
}*/
                
                // Check flight end date must be greater than or equal to flight start date
                /*   if (
oli.Flight_Start_Date__c != null &&
oli.Flight_End_Date__c != null &&
oli.Flight_Start_Date__c > oli.Flight_End_Date__c
) {
oli.Flight_Start_Date__c.addError(
'Flight Start date must not be greater than Flight End Date'
); 
} */
                
                // Country is required for all products
                if ((oli.Country__c == null || oli.Country__c == '')) {
                    oli.Country__c.addError('Country is required');
                }
            }
            
            if (!stages.containsKey(opp.StageName)) {
                System.debug('Unrecognised stage name. Ignoring.');
                continue;
            }
            
            if (stages.get(opp.StageName) < stages.get(STAGE_VERBAL_CONFIRM)) {
                continue;
            }
            
            // Opportunity stage is greater than or equal to verbal confirm
            
            /* if (isActive) {
// Check if products have flight start/end dates, min impressions and cpm selected
if (oli.Flight_Start_Date__c == null) {
oli.Flight_Start_Date__c.addError(
'Flight Start Date is missing on Product ' +
product.Name +
' - ' +
product.Id
);
}
if (oli.Flight_End_Date__c == null) {
oli.Flight_End_Date__c.addError(
'Flight End Date is missing on Product ' +
product.Name +
' - ' +
product.Id
);
}
if (
oli.MinImpressions__c == null &&
product.Name != Constants.PRODUCT_SPONSORED_SEARCH &&
product.Name != Constants.PRODUCT_INSIGHTS
) {
oli.MinImpressions__c.addError(
'Min Impressions is required on Product ' +
product.Name +
' - ' +
product.Id
);
}
if (
product.Name != Constants.PRODUCT_ROADBLOCK &&
product.Name != Constants.PRODUCT_SPONSORED_SEARCH &&
product.Name != Constants.PRODUCT_INSIGHTS
) {
if (oli.CPM__c == null) {
oli.CPM__C.addError(
'CPM is missing on Product ' +
product.Name +
' - ' +
product.Id
);
}
}
}*/
        }
    }
    if (Trigger.isDelete && Trigger.isAfter) {
        Set<Id> oppIds = new Set<Id>();
        for (OpportunityLineItem oli : Trigger.old) {
            oppIds.add(oli.OpportunityId);
            // Update Opportunity Flight Start and end date
            /*Opportunity opp = [
SELECT id, Name, StageName, Flight_Start_Date__c, Flight_End_Date__c
FROM Opportunity
WHERE id = :oli.OpportunityId
];
List<OpportunityLineItem> opportunityProducts = [
SELECT id, Start_Date__c, End_Date__c
FROM OpportunityLineItem
WHERE OpportunityId = :opp.Id
];
Date minStartDate = null;
Date maxEndDate = null;
for (OpportunityLineItem opportunityProduct : opportunityProducts) {
Date startdate = date.valueof(opportunityProduct.Start_Date__c);
Date enddate = date.valueof(opportunityProduct.End_Date__c);
minStartDate = DateUtility.minDate(
minStartDate,
startdate
);
maxEndDate = DateUtility.maxDate(
maxEndDate,
enddate
);
}
opp.Flight_Start_Date__c = minStartDate;
opp.Flight_End_Date__c = maxEndDate; 
mapOpp.put(opp.Id, opp);*/
        }
        if(!oppIds.IsEmpty()){
            OpportunityProductHelper.updateFlightDates(oppIds, false,null);
        }
        
        /*if (!mapOpp.values().isEmpty()) {
update mapOpp.values();
}*/
    }
    if (Trigger.isDelete && Trigger.isBefore) {
        Set<Id> oppIds = new Set<Id>();
        for (OpportunityLineItem oli : Trigger.old) {
            oppIds.add(oli.OpportunityId);
            List<Opportunity_Product_Seller__c> opss = [
                SELECT id
                FROM Opportunity_Product_Seller__c
                WHERE Opportunity_Product__c = :oli.Id
            ];
            System.debug('Opportunity Product Update trigger delete ' + opss);
            delete opss;
            
        }
        Map<Id, String> oppStageMap = new Map<Id, String>();
        Map<Id, boolean> opptohasbeenclosed = new Map<Id, boolean>();
        // Query to get the StageNames of the related Opportunities
        
        for (Opportunity opp : [SELECT Id, StageName,has_been_closed__c FROM Opportunity WHERE Id IN :oppIds]) {
            oppStageMap.put(opp.Id, opp.StageName);
            opptohasbeenclosed.put(opp.Id, opp.has_been_closed__c);
            
        }
        
        Id userId = UserInfo.getUserId();
        String userProfile = [SELECT Name FROM Profile WHERE Id IN (SELECT ProfileId FROM User WHERE Id = :userId)].Name;
        Set<String> restrictedStages = new Set<String>{'Waiting on Assets - Closed Won', 'Closed Won'};
            
            if (userProfile != 'System Administrator') {
                for (OpportunityLineItem oli : Trigger.old) {
                    // restrictedStages.contains(oppStageMap.get(oli.OpportunityId)
                    
                    
                    if (opptohasbeenclosed.get(oli.OpportunityId) && oli.Opportunity_Record_Type__c == '1-Managed Service') {
                        oli.addError('Opportunity Products cannot be deleted if Opportunity has been in "Waiting on Assets - Closed Won" or later stages atleast once.');
                    }
                    
                }
            }
    }
    System.debug('Opportunity product update trigger done');
    
}