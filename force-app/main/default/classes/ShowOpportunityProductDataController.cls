public class ShowOpportunityProductDataController {
    
    @auraEnabled(cacheable=true)
    public static list<opportunitylineitem> fetchcloningdates(String oliid){
         return [select id, name, start_date__C,end_date__c,max_Extension_Time__c
                                         from opportunitylineitem where id=: oliid];
    }
    
    @AuraEnabled
    public static DateTime getExactDateTime(Datetime dt) {

		TimeZone userTimezone = UserInfo.getTimeZone();
        Long offsetMinutes = userTimezone.getOffset(dt) / 60000;
		Datetime gmtDatetime = dt.addMinutes(-offsetMinutes.intValue());
        return gmtDatetime;
    }
    
    @AuraEnabled(cacheable=true)
    public static Boolean hasNotEditButtonPermission() {
        system.debug('FeatureManagement.checkPermission'+ FeatureManagement.checkPermission('IO_Placement_Not_Editable'));
        return FeatureManagement.checkPermission('IO_Placement_Not_Editable');
    }
    
    @AuraEnabled
    public static Boolean getOpptyClosed(String oppId){
        Boolean oppclosed = false;
        String oppclosed1 = [select StageName from opportunity where id =: oppId].StageName;
        if(oppclosed1 == 'Closed Won' || oppclosed1 == 'Waiting on Assets - Closed Won'){
            oppclosed = true;
        }
        return oppclosed;
    }
    
    @AuraEnabled(cacheable=true)
    public static String getOpportunityProductData(Id oppId) {
        List<OpportunityLineItem> listopp = [
            SELECT
            Id,
            Product_Family__c,
            TotalPrice,
            IO_Product_Display_Name__c,
            Product2.Name,
            Name,
            IO_Product_ID__c,
            Total_Booking_Amount__c,
            Product_Full_Name__c,
            Placement_Billing_Name__c,
            Audience_Segment_Details__c,
            BETA_Program__c,
            Device_Type__c,
            Media_Type_formula__c,
            Placement_Type__c,
            Placement_Category__c,
            Original_Booking_Amount__c,
            Frequency_Cap__c,
            Day_Part__c,
            Rolling_Time_Zone__c,
            IO_Impression_Goal__c,
            Rate__c,
            Buy_Type__c,
            Country__c,
            Start_Date__c,
            End_Date__c,
            Audience_Targeting__c,
            Package__c,
            (
                SELECT
                Id,
                Name,
                Placement_Display_Name__c,
                Original_Booking_Amount__c,
                Total_Booking_Amount__c,
                IO_Impression_Goal__c,
                Rate__c,
                Start_Date__c,
                End_Date__c
                FROM Operational_Placement_Levels1__r
                ORDER BY Name DESC
            )
            FROM OpportunityLineItem
            WHERE OpportunityId = :oppId
            ORDER BY Product_Family__c, IO_Product_ID_Formula__c ,createdDate DESC
        ];
        List<OpportunityLineItemWrapper> lstWrapperTOreturn = new List<OpportunityLineItemWrapper>();
        for (OpportunityLineItem oppLineItem : listopp) {
            OpportunityLineItemWrapper wrapper = new OpportunityLineItemWrapper();
            wrapper.Id = oppLineItem.Id;
            wrapper.name = oppLineItem.IO_Product_ID__c;
            wrapper.placementBillingName = oppLineItem.Product_Full_Name__c;
            wrapper.product = oppLineItem.Product2.Name;
            wrapper.placementType = oppLineItem.Placement_Type__c;
            wrapper.placementCategory = oppLineItem.Placement_Category__c;
            wrapper.ioImpressionGoal = oppLineItem.IO_Impression_Goal__c;
            wrapper.rate = oppLineItem.Rate__c;
            wrapper.IO_Product_Display_Name = oppLineItem.IO_Product_Display_Name__c;
            wrapper.buyType = oppLineItem.Buy_Type__c != null
                ? oppLineItem.Buy_Type__c
                : 'CPM';
            wrapper.country = oppLineItem.Country__c;
            wrapper.startDate = oppLineItem.Start_Date__c;
            wrapper.endDate = oppLineItem.End_Date__c;
            wrapper.FrequencyCap = oppLineItem.Frequency_Cap__c;
            wrapper.daypart = oppLineItem.Day_Part__c;
            wrapper.audienceTargeting = oppLineItem.Audience_Targeting__c;
            wrapper.audienceSegmentDetails = oppLineItem.Audience_Segment_Details__c;
            wrapper.deviceTy = oppLineItem.Device_Type__c;
            wrapper.productFamily = oppLineItem.Product_Family__c;
            wrapper.rolingTimezone = oppLineItem.Rolling_Time_Zone__c;
            wrapper.isExpandable = true;
            wrapper.isVisible = true;
            wrapper.MediaType = oppLineItem.Media_Type_formula__c;
            wrapper.totalPrice = oppLineItem.Total_Booking_Amount__c;
            wrapper.OriginalBookingAmount = oppLineItem.Original_Booking_Amount__c;
            
            wrapper.rowStyle = 'slds-hide';
            wrapper.nameStyle = 'chevronright';
            if (oppLineItem.Product_Family__c == 'Managed Service Impressions') {
                wrapper.isProductFamily = true;
            } else {
                wrapper.isProductFamily = false;
            }
            List<OperationalPlacementWrapper> lstOpW = new List<OperationalPlacementWrapper>();
            for (
                Operational_Placement__c opPlacement : oppLineItem.Operational_Placement_Levels1__r
            ) {
                OperationalPlacementWrapper opWrapper = new OperationalPlacementWrapper();
                opWrapper.Id = opPlacement.Id;
                opWrapper.name = opPlacement.Name;
                opWrapper.placementDisplayName = opPlacement.Placement_Display_Name__c;
                opWrapper.originalBookingAmount = Integer.valueof(
                    opPlacement.Original_Booking_Amount__c
                );
                opWrapper.totalBookingAmount = Integer.valueof(
                    opPlacement.Total_Booking_Amount__c
                );
                opWrapper.ioImpressionGoal = opPlacement.IO_Impression_Goal__c;
                opWrapper.rate = opPlacement.Rate__c;
                opWrapper.startDate = opPlacement.Start_Date__c;
                opWrapper.endDate = opPlacement.End_Date__c;
                opWrapper.audienceTargeting = oppLineItem.Audience_Targeting__c;
                opWrapper.audienceSegmentDetails = oppLineItem.Audience_Segment_Details__c;
                
                lstOpW.add(opWrapper);
            }
            wrapper.operationalPlacements = lstOpW;
            lstWrapperTOreturn.add(wrapper);
        }
        
        String jsonstring = Json.serialize(lstWrapperTOreturn);
        System.debug('jsonstring' + jsonstring);
        return jsonstring;
    }
    
    /*   @AuraEnabled
public static string insertOrderItem(Id oppId){
try {

Opportunity opp = [SELECT Id, CurrencyIsoCode,Pricebook2Id FROM Opportunity WHERE Id =: oppId ];

PricebookEntry pbe = [SELECT Id, Name From PricebookEntry WHERE (Pricebook2Id =: opp.Pricebook2Id AND CurrencyIsoCode =: opp.CurrencyIsoCode)  AND IsActive =: true LIMIT 1];
System.debug('pbe'+pbe);
OpportunityLineItem oli = new OpportunityLineItem(
OpportunityId = oppId,
Quantity = 1,
PricebookEntryId = pbe.Id,
Country__c = 'United States '

);
insert oli;

return oli.Id;
} catch (Exception e) {
throw new AuraHandledException(getFriendlyMessage(e));
}
} */
    
    @AuraEnabled
    public static Boolean deleteRecord(Id recordId, String objectType) {
        try {
            SObject recordToDelete = (SObject) Type.forName('Schema', objectType)
                .newInstance();
            recordToDelete.Id = recordId;
            delete recordToDelete;
            return true;
        } catch (Exception e) {
            System.debug(
                'An error occurred while deleting the record: ' + e.getMessage()
            );
            throw new AuraHandledException(getFriendlyMessage(e));
            //return false;
        }
    }
    
    /*   @AuraEnabled
public static string insertOperationalPlacement(Id oppId){
try {
Operational_Placement__c objop = new Operational_Placement__c();
objop.Opportunity_Product__c = oppId;
insert objop;
System.debug('objop'+objop.Id);
return objop.Id;
} catch (Exception e) {
throw new AuraHandledException(getFriendlyMessage(e));
}
} */
    
    /*    @AuraEnabled(cacheable=false)
public static void updateField(String fieldName, String fieldValue, String recordId) {
try{
// Get the SObject type for the record
System.debug('fieldValue'+fieldValue);
Id recId = recordId;
SObjectType objectType = recId.getSObjectType();
// Get the field describe result for the target field
SObjectField field = objectType.getDescribe().fields.getMap().get(fieldName);
Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
// Convert the field value to the appropriate type based on the target field type
Object convertedValue;
if (fieldDescribe.getType() == Schema.DisplayType.BOOLEAN) {
convertedValue = Boolean.valueOf(fieldValue);
} else if (fieldDescribe.getType() == Schema.DisplayType.CURRENCY) {
convertedValue = Double.valueOf(fieldValue);
} else if (fieldDescribe.getType() == Schema.DisplayType.DATE) {
convertedValue = Date.valueOf(fieldValue);
} else if (fieldDescribe.getType() == Schema.DisplayType.DATETIME) {
System.debug('fieldValue 233'+fieldValue);
String formattedDateTime = fieldValue.replace('T', ' ').replace('Z', 'Z');
DateTime dt = DateTime.valueOf(formattedDateTime);
convertedValue = dt;
} else if (fieldDescribe.getType() == Schema.DisplayType.PERCENT) {
convertedValue = Double.valueOf(fieldValue);
}else if (fieldDescribe.getType() == Schema.DisplayType.Double) {
convertedValue = Double.valueOf(fieldValue);
}
else if (fieldDescribe.getType() == Schema.DisplayType.INTEGER) {
convertedValue = Integer.valueOf(fieldValue);
} else {
convertedValue = fieldValue;
}
// Create a new instance of the SObject and populate the Id and target field
SObject record = objectType.newSObject(recordId);
record.put(fieldName, convertedValue);
// Update the record
update record;
}catch(Exception ex){
throw new AuraHandledException(getFriendlyMessage(ex));
}
} */
    
    public class Option {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String value { get; set; }
        @AuraEnabled
        public Boolean selected { get; set; }
    }
    
    public class OpportunityLineItemWrapper {
        @AuraEnabled
        public String Id { get; set; }
        @AuraEnabled
        public String IO_Product_Display_Name { get; set; }
        @AuraEnabled
        public String placementBillingName { get; set; }
        @AuraEnabled
        public String product { get; set; }
        @AuraEnabled
        public String placementType { get; set; }
        @AuraEnabled
        public String placementCategory { get; set; }
        @AuraEnabled
        public String billingAdServer { get; set; }
        @AuraEnabled
        public Decimal ioImpressionGoal { get; set; }
        @AuraEnabled
        public Decimal rate { get; set; }
        @AuraEnabled
        public String buyType { get; set; }
        @AuraEnabled
        public String country { get; set; }
        @AuraEnabled
        public Datetime startDate { get; set; }
        @AuraEnabled
        public Datetime endDate { get; set; }
        @AuraEnabled
        public String audienceTargeting { get; set; }
        @AuraEnabled
        public String betaProgram { get; set; }
        @AuraEnabled
        public String audienceSegmentDetails { get; set; }
        @AuraEnabled
        public String deviceTy { get; set; }
        @AuraEnabled
        public String MediaType { get; set; }
        @AuraEnabled
        public String packagevalue { get; set; }
        @AuraEnabled
        public Boolean isExpandable { get; set; }
        @AuraEnabled
        public Boolean isVisible { get; set; }
        @AuraEnabled
        public String rowStyle { get; set; }
        @AuraEnabled
        public String nameStyle { get; set; }
        @AuraEnabled
        public String FrequencyCap { get; set; }
        @AuraEnabled
        public String daypart { get; set; }
        @AuraEnabled
        public boolean isProductFamily { get; set; }
        @AuraEnabled
        public String productFamily { get; set; }
        @AuraEnabled
        public String rolingTimezone { get; set; }
        @AuraEnabled
        public String name { get; set; }
        @AuraEnabled
        public Decimal totalPrice { get; set; }
        @AuraEnabled
        public List<Option> optionlst { get; set; }
        @AuraEnabled
        public List<Option> audienceTargetingLst { get; set; }
        
        @AuraEnabled
        public Decimal OriginalBookingAmount { get; set; }
        @AuraEnabled
        public List<OperationalPlacementWrapper> operationalPlacements { get; set; }
    }
    
    public class OperationalPlacementWrapper {
        @AuraEnabled
        public String Id { get; set; }
        @AuraEnabled
        public String name { get; set; }
        @AuraEnabled
        public String placementDisplayName { get; set; }
        @AuraEnabled
        public Decimal originalBookingAmount { get; set; }
        @AuraEnabled
        public Decimal totalBookingAmount { get; set; }
        @AuraEnabled
        public String ioImpressionGoal { get; set; }
        @AuraEnabled
        public Decimal rate { get; set; }
        @AuraEnabled
        public Date startDate { get; set; }
        @AuraEnabled
        public Date endDate { get; set; }
        @AuraEnabled
        public String audienceTargeting { get; set; }
        @AuraEnabled
        public String audienceSegmentDetails { get; set; }
        @AuraEnabled
        public boolean isProductFamily { get; set; }
    }
    
    /*  @AuraEnabled
public static void insertClonedOrderItem(String lineitemId) {

try{

list<OpportunityLineItem> oli =  [select id, Account_Name__c, Audience_Segment_Details__c, Audience_Targeting__c,BETA_Program__c,UnitPrice,Budget_Amount__c,End_Date__c,
Budgeted_Forecast__c, Buy_Type__c, CPM__c, ServiceDate,Device_Type__c,Flight_End_Date__c, Flight_Start_Date__c, Incremental_Booking_Amount__c,
IO_Impression_Goal__c, Is_Revision__c, Description, ListPrice, MinImpressions__c, OpportunityId, Name, Original_Booking_Amount__c, Package__c, Placement_Billing_Name__c,
Placement_Category__c, Placement_Type__c, Product2Id, PricebookEntryId, ProductCode, Product_Family__c, Product_Full_Name__c,Quantity, Rate__c, Retail_CPM__c, Country__c, Start_Date__c,
Subtotal, TotalPrice,  Value__c, (select id,Audience_Segment_Details__c,Audience_Targeting__c,CurrencyIsoCode,Daypart__c,End_Date__c,Frequency_Cap__c,
IO_Impression_Goal__c,Native_WebOS_Units_App_Based_Exclusions__c, Opportunity_Product__c,Original_Booking_Amount__c,Placement_Display_Name__c,Rate__c,
Start_Date__c,Total_Booking_Amount__c  from Operational_Placement_Levels1__r) from OpportunityLineItem where id =:lineitemId ];
if (!oli.isEmpty()) {
OpportunityLineItem originalItem = oli[0];

Opportunity opp = [SELECT Id, CurrencyIsoCode, Pricebook2Id FROM Opportunity WHERE Id = :originalItem.OpportunityId];

PricebookEntry pbe = [SELECT Id, Name FROM PricebookEntry WHERE (Pricebook2Id = :opp.Pricebook2Id AND CurrencyIsoCode = :opp.CurrencyIsoCode) AND IsActive = true AND Product2Id =:originalItem.Product2Id LIMIT 1]; 

OpportunityLineItem cloneRec = new OpportunityLineItem();

cloneRec.Account_Name__c = originalItem.Account_Name__c;
cloneRec.Audience_Segment_Details__c = originalItem.Audience_Segment_Details__c;
cloneRec.Audience_Targeting__c = originalItem.Audience_Targeting__c;
cloneRec.BETA_Program__c = originalItem.BETA_Program__c;
cloneRec.UnitPrice = originalItem.UnitPrice;
cloneRec.Budget_Amount__c = originalItem.Budget_Amount__c;
cloneRec.Budgeted_Forecast__c = originalItem.Budgeted_Forecast__c;
cloneRec.Buy_Type__c = originalItem.Buy_Type__c;
cloneRec.CPM__c = originalItem.CPM__c;
cloneRec.ServiceDate = originalItem.ServiceDate;
cloneRec.Device_Type__c = originalItem.Device_Type__c;
cloneRec.Incremental_Booking_Amount__c = originalItem.Incremental_Booking_Amount__c;
cloneRec.IO_Impression_Goal__c = originalItem.IO_Impression_Goal__c;
cloneRec.Is_Revision__c = originalItem.Is_Revision__c;
cloneRec.Description = originalItem.Description;
cloneRec.MinImpressions__c = originalItem.MinImpressions__c;
cloneRec.OpportunityId = originalItem.OpportunityId;
cloneRec.Original_Booking_Amount__c = originalItem.Original_Booking_Amount__c;
cloneRec.Package__c = originalItem.Package__c;
cloneRec.Placement_Billing_Name__c = originalItem.Placement_Billing_Name__c;
cloneRec.Placement_Category__c = originalItem.Placement_Category__c;
cloneRec.Placement_Type__c = originalItem.Placement_Type__c;
cloneRec.Product2Id = originalItem.Product2Id;
cloneRec.PricebookEntryId =  originalItem.PricebookEntryId;
//cloneRec.Product_Booking_Date__c = originalItem.Product_Booking_Date__c;
cloneRec.Product_Family__c = originalItem.Product_Family__c;
cloneRec.Product_Full_Name__c = originalItem.Product_Full_Name__c;

cloneRec.Quantity = originalItem.Quantity;
cloneRec.Rate__c = originalItem.Rate__c;
//cloneRec.Reason__c = originalItem.Reason__c;
cloneRec.Retail_CPM__c = originalItem.Retail_CPM__c;
cloneRec.Country__c = originalItem.Country__c;
cloneRec.Start_Date__c = System.Today().addDays(1); 
cloneRec.End_Date__c = System.Today().addDays(1);
//cloneRec.TotalPrice = originalItem.TotalPrice;
// cloneRec.Type__c = originalItem.Type__c;
cloneRec.Value__c = originalItem.Value__c;
system.debug(cloneRec.Id + 'cloneRec id');
insert cloneRec;

List<Operational_Placement__c> originalPlacements = originalItem.Operational_Placement_Levels1__r;

if (!originalPlacements.isEmpty()) {
List<Operational_Placement__c> clonedPlacements = new List<Operational_Placement__c>();

for (Operational_Placement__c originalPlacement : originalPlacements) {
Operational_Placement__c clonedPlacement = originalPlacement.clone(false, false, false, false);

clonedPlacement.Opportunity_Product__c = cloneRec.Id; 

clonedPlacements.add(clonedPlacement);
}

insert clonedPlacements;
}
}
}catch (Exception e) {
throw new AuraHandledException(getFriendlyMessage(e));
}
} */
    @AuraEnabled
    public static String getOpportunityProductDataNonCacheable(Id oppId) {
        Map<String, String> stringMap = new Map<String, String>{
            'CTV' => 'CTV',
                'CTV Native' => 'CTV Native',
                'Tablet' => 'Tablet',
                'Mobile' => 'Mobile',
                'Desktop' => 'Desktop'
                };
                    
                    Map<String, String> stringMap2 = new Map<String, String>{
                        '1P ACR' => '1P ACR',
                            'Suppress App Install' => 'Suppress App Install',
                            'Include Lapsed/Active Only' => 'Tablet',
                            'Include Lapsed/Active Only' => 'Include Lapsed/Active Only',
                            'Crossix' => 'Crossix',
                            'Swoop' => 'Swoop',
                            'IQVIA' => 'IQVIA',
                            'DataTrust' => 'DataTrust',
                            'i360' => 'i360',
                            'Tunnl' => 'Tunnl',
                            'L2' => 'L2',
                            'TargetSmart' => 'TargetSmart',
                            'Annalect' => 'Annalect',
                            'Merkury' => 'Merkury',
                            'Polk (S&P Global)' => 'Polk (S&P Global)',
                            'Other 3p data' => 'Other 3p data'
                            };
                                
                                List<OpportunityLineItem> listopp = [
                                    SELECT
                                    Id,
                                    Product_Family__c,
                                    TotalPrice,
                                    Product2.Name,
                                    Name,
                                    IO_Product_ID__c,
                                    Total_Booking_Amount__c,
                                    Product_Full_Name__c,
                                    Placement_Billing_Name__c,
                                    Audience_Segment_Details__c,
                                    BETA_Program__c,
                                    Device_Type__c,
                                    Media_Type_formula__c,
                                    Placement_Type__c,
                                    Placement_Category__c,
                                    Original_Booking_Amount__c,
                                    Frequency_Cap__c,
                                    Day_Part__c,
                                    Rolling_Time_Zone__c,
                                    IO_Impression_Goal__c,
                                    Rate__c,
                                    Buy_Type__c,
                                    Country__c,
                                    Start_Date__c,
                                    End_Date__c,
                                    Audience_Targeting__c,
                                    Package__c,
                                    (
                                        SELECT
                                        Id,
                                        Name,
                                        Placement_Display_Name__c,
                                        Original_Booking_Amount__c,
                                        Total_Booking_Amount__c,
                                        IO_Impression_Goal__c,
                                        Rate__c,
                                        Start_Date__c,
                                        End_Date__c
                                        FROM Operational_Placement_Levels1__r
                                        ORDER BY Name DESC
                                    )
                                    FROM OpportunityLineItem
                                    WHERE OpportunityId = :oppId
                                    ORDER BY Product_Family__c, IO_Product_ID__c DESC
                                ];
        List<OpportunityLineItemWrapper> lstWrapperTOreturn = new List<OpportunityLineItemWrapper>();
        for (OpportunityLineItem oppLineItem : listopp) {
            OpportunityLineItemWrapper wrapper = new OpportunityLineItemWrapper();
            wrapper.Id = oppLineItem.Id;
            wrapper.name = oppLineItem.IO_Product_ID__c;
            wrapper.placementBillingName = oppLineItem.Product_Full_Name__c;
            wrapper.product = oppLineItem.Product2.Name;
            wrapper.placementType = oppLineItem.Placement_Type__c;
            wrapper.placementCategory = oppLineItem.Placement_Category__c;
            wrapper.ioImpressionGoal = oppLineItem.IO_Impression_Goal__c;
            wrapper.rate = oppLineItem.Rate__c;
            wrapper.buyType = oppLineItem.Buy_Type__c != null
                ? oppLineItem.Buy_Type__c
                : 'CPM';
            wrapper.country = oppLineItem.Country__c;
            wrapper.startDate = oppLineItem.Start_Date__c;
            wrapper.endDate = oppLineItem.End_Date__c;
            wrapper.FrequencyCap = oppLineItem.Frequency_Cap__c;
            wrapper.daypart = oppLineItem.Day_Part__c;
            wrapper.audienceTargeting = oppLineItem.Audience_Targeting__c;
            wrapper.audienceSegmentDetails = oppLineItem.Audience_Segment_Details__c;
            wrapper.deviceTy = oppLineItem.Device_Type__c;
            wrapper.productFamily = oppLineItem.Product_Family__c;
            wrapper.rolingTimezone = oppLineItem.Rolling_Time_Zone__c;
            wrapper.isExpandable = true;
            wrapper.isVisible = true;
            wrapper.MediaType = oppLineItem.Media_Type_formula__c;
            wrapper.totalPrice = oppLineItem.Total_Booking_Amount__c;
            wrapper.OriginalBookingAmount = oppLineItem.Original_Booking_Amount__c;
            List<option> lstop = new List<option>();
            if (oppLineItem.Device_Type__c != null) {
                List<String> lstdev = oppLineItem.Device_Type__c.split(';');
                for (String key : stringMap.keySet()) {
                    Option objo = new Option();
                    objo.label = key;
                    objo.value = key;
                    if (lstdev.contains(key)) {
                        objo.selected = true;
                    } else {
                        objo.selected = false;
                    }
                    lstop.add(objo);
                }
                wrapper.optionlst = lstop;
            } else {
                for (String key : stringMap.keySet()) {
                    Option objo = new Option();
                    objo.label = key;
                    objo.value = key;
                    objo.selected = false;
                    
                    lstop.add(objo);
                }
                wrapper.optionlst = lstop;
            }
            //audienceTargetingLst
            
            List<option> lstop2 = new List<option>();
            if (oppLineItem.Audience_Targeting__c != null) {
                List<String> lstdev = oppLineItem.Audience_Targeting__c.split(';');
                for (String key : stringMap2.keySet()) {
                    Option objo = new Option();
                    objo.label = key;
                    objo.value = key;
                    if (lstdev.contains(key)) {
                        objo.selected = true;
                    } else {
                        objo.selected = false;
                    }
                    lstop2.add(objo);
                }
                wrapper.audienceTargetingLst = lstop2;
            } else {
                for (String key : stringMap2.keySet()) {
                    Option objo = new Option();
                    objo.label = key;
                    objo.value = key;
                    objo.selected = false;
                    
                    lstop2.add(objo);
                }
                wrapper.audienceTargetingLst = lstop2;
            }
            
            wrapper.rowStyle = 'slds-hide';
            wrapper.nameStyle = 'chevronright';
            if (oppLineItem.Product_Family__c == 'Managed Service Impressions') {
                wrapper.isProductFamily = true;
            } else {
                wrapper.isProductFamily = false;
            }
            List<OperationalPlacementWrapper> lstOpW = new List<OperationalPlacementWrapper>();
            for (
                Operational_Placement__c opPlacement : oppLineItem.Operational_Placement_Levels1__r
            ) {
                OperationalPlacementWrapper opWrapper = new OperationalPlacementWrapper();
                opWrapper.Id = opPlacement.Id;
                opWrapper.name = opPlacement.Name;
                opWrapper.placementDisplayName = opPlacement.Placement_Display_Name__c;
                opWrapper.originalBookingAmount = Integer.valueof(
                    opPlacement.Original_Booking_Amount__c
                );
                opWrapper.totalBookingAmount = Integer.valueof(
                    opPlacement.Total_Booking_Amount__c
                );
                opWrapper.ioImpressionGoal = opPlacement.IO_Impression_Goal__c;
                opWrapper.rate = opPlacement.Rate__c;
                opWrapper.startDate = opPlacement.Start_Date__c;
                opWrapper.endDate = opPlacement.End_Date__c;
                opWrapper.audienceTargeting = oppLineItem.Audience_Targeting__c;
                opWrapper.audienceSegmentDetails = oppLineItem.Audience_Segment_Details__c;
                
                lstOpW.add(opWrapper);
            }
            wrapper.operationalPlacements = lstOpW;
            lstWrapperTOreturn.add(wrapper);
        }
        
        String jsonstring = Json.serialize(lstWrapperTOreturn);
        System.debug('jsonstring' + jsonstring);
        return jsonstring;
    }
    
    @AuraEnabled
    public static string getPricebook(Id oppId, Id proId) {
        try {
            if (proId != null) {
                Opportunity opp = [
                    SELECT Id, CurrencyIsoCode, Pricebook2Id
                    FROM Opportunity
                    WHERE Id = :oppId
                ];
                
                PricebookEntry pbe = [
                    SELECT Id, Name
                    FROM PricebookEntry
                    WHERE
                    Pricebook2Id = :opp.Pricebook2Id
                    AND CurrencyIsoCode = :opp.CurrencyIsoCode
                    AND IsActive = :true
                    AND Product2Id = :proId
                    LIMIT 1
                ];
                return pbe.Id;
            } else {
                //throw new AuraHandledException('Please select Product');
                return null;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + e.getStackTraceString());
        }
    }
    
    @AuraEnabled
    public static String insertCloneRecord(
        String fieldSet,
        String oppId,
        String lineItemId,
        Date bookingDate
    ) {
        system.debug('fieldSet***' + fieldSet);
        system.debug('bookingDate***' + bookingDate);
        String cloneRecReturn;
        try {
            OpportunityLineItem objlineItem = [
                SELECT
                Id,
                Product2Id,
                Opportunity.Pricebook2Id,
                Opportunity.CurrencyIsoCode
                FROM OpportunityLineItem
                WHERE Id = :lineItemId
                LIMIT 1
            ];
            if (objlineItem != null) {
                PricebookEntry pbe = [
                    SELECT Id, Name
                    FROM PricebookEntry
                    WHERE
                    Pricebook2Id = :objlineItem.Opportunity.Pricebook2Id
                    AND CurrencyIsoCode = :objlineItem.Opportunity.CurrencyIsoCode
                    AND IsActive = :true
                    AND Product2Id = :objlineItem.Product2Id
                    LIMIT 1
                ];
                if (pbe != null) {
                    Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(
                        fieldSet
                    );
                    OpportunityLineItem cloneRec = new OpportunityLineItem();
                    system.debug('PBD' + resultMap.get('Product_Booking_Date__c'));
                    cloneRec.OpportunityId = oppId;
                    cloneRec.PricebookEntryId = pbe.Id; //'01tVC000004SopBYAS';
                    if (resultMap.containsKey('Rate__c')) {
                        cloneRec.Rate__c = dynamicTypeConversion(resultMap.get('Rate__c'));
                    }
                    if (resultMap.containsKey('Product_Family__c')) {
                        system.debug('PF' + (String) resultMap.get('Product_Family__c'));
                        cloneRec.Product_Family__c = String.valueOf(
                            resultMap.get('Product_Family__c')
                        );
                    }
                    if (resultMap.containsKey('Buy_Type__c')) {
                        cloneRec.Buy_Type__c = (String) resultMap.get('Buy_Type__c');
                    }
                    if (resultMap.containsKey('Country__c')) {
                        cloneRec.Country__c = (String) resultMap.get('Country__c');
                    }
                    if (resultMap.containsKey('Type__c')) {
                        cloneRec.Type__c = (String) resultMap.get('Type__c');
                    }
                    if (resultMap.containsKey('Placement_Type__c')) {
                        cloneRec.Placement_Type__c = (String) resultMap.get(
                            'Placement_Type__c'
                        );
                    }
                    if (resultMap.containsKey('IO_Product_Display_Name__c')) {
                      cloneRec.IO_Product_Display_Name__c = (String) resultMap.get(
                        'IO_Product_Display_Name__c'
                      );
                    }
                    if (resultMap.containsKey('Product_Full_Name__c')) {
                        cloneRec.Product_Full_Name__c = (String) resultMap.get(
                            'Product_Full_Name__c'
                        );
                    }
                    if (resultMap.containsKey('Placement_Category__c')) {
                        cloneRec.Placement_Category__c = (String) resultMap.get(
                            'Placement_Category__c'
                        );
                    }
                    if (resultMap.containsKey('Audience_Targeting__c')) {
                        cloneRec.Audience_Targeting__c = (String) resultMap.get(
                            'Audience_Targeting__c'
                        );
                    }
                    if (resultMap.containsKey('Account_Name__c')) {
                        cloneRec.Account_Name__c = (String) resultMap.get(
                            'Account_Name__c'
                        );
                    }
                    if (resultMap.containsKey('Audience_Segment_Details__c')) {
                        cloneRec.Audience_Segment_Details__c = (String) resultMap.get(
                            'Audience_Segment_Details__c'
                        );
                    }
                    
                    if (resultMap.containsKey('BETA_Program__c')) {
                        cloneRec.BETA_Program__c = (String) resultMap.get(
                            'BETA_Program__c'
                        );
                    }
                    
                    if (resultMap.containsKey('Budget_Amount__c')) {
                        cloneRec.Budget_Amount__c = dynamicTypeConversion(
                            resultMap.get('Budget_Amount__c')
                        );
                    }
                    if (resultMap.containsKey('Budgeted_Forecast__c')) {
                        cloneRec.Budgeted_Forecast__c = (String) resultMap.get(
                            'Budgeted_Forecast__c'
                        );
                    }
                    if (resultMap.containsKey('CPM__c')) {
                        cloneRec.CPM__c = dynamicTypeConversion(resultMap.get('CPM__c'));
                    }
                    
                    if (resultMap.containsKey('Device_Type__c')) {
                        cloneRec.Device_Type__c = (String) resultMap.get('Device_Type__c');
                    }
                    if (resultMap.containsKey('Incremental_Booking_Amount__c')) {
                        cloneRec.Incremental_Booking_Amount__c = dynamicTypeConversion(
                            resultMap.get('Incremental_Booking_Amount__c')
                        );
                    }
                    if (resultMap.containsKey('IO_Impression_Goal__c')) {
                        cloneRec.IO_Impression_Goal__c = dynamicTypeConversion(
                            resultMap.get('IO_Impression_Goal__c')
                        );
                    }
                    
                    if (resultMap.containsKey('RB_Extension_info__c')) {
                        cloneRec.RB_Extension_info__c = (String) resultMap.get(
                            'RB_Extension_info__c'
                        );
                    }
                    if (
                        resultMap.containsKey('Max_Extension_Time__c') &&
                        String.valueOf(resultMap.get('Max_Extension_Time__c')) != null
                    ) {
                        String inpputString = String.valueOf(
                            resultMap.get('Max_Extension_Time__c')
                        );
                        DateTime resultDateTime = DateTime.ValueofGmt(
                            inpputString.replace('T', ' ')
                        );
                        cloneRec.Max_Extension_Time__c = resultDateTime;
                    }
                    if (resultMap.containsKey('Audience_Targeting__c')) {
                        cloneRec.Audience_Targeting__c = (String) resultMap.get(
                            'Audience_Targeting__c'
                        );
                    }
                    if (resultMap.containsKey('Frequency_Cap__c')) {
                        cloneRec.Frequency_Cap__c = (String) resultMap.get(
                            'Frequency_Cap__c'
                        );
                    }
                    if (resultMap.containsKey('Day_Part__c')) {
                        cloneRec.Day_Part__c = (String) resultMap.get('Day_Part__c');
                    }
                    
                    if (resultMap.containsKey('Start_Date__c')) {
                        String inpputString = String.valueOf(
                            resultMap.get('Start_Date__c')
                        );
                        DateTime resultDateTime = DateTime.ValueofGmt(
                            inpputString.replace('T', ' ')
                        );
                        cloneRec.Start_Date__c = resultDateTime;
                    }
                    if (resultMap.containsKey('End_Date__c')) {
                        String inpputString = String.valueOf(resultMap.get('End_Date__c'));
                        DateTime resultDateTime = DateTime.ValueofGmt(
                            inpputString.replace('T', ' ')
                        );
                        cloneRec.End_Date__c = resultDateTime;
                    }
                    if (resultMap.containsKey('Original_Booking_Amount__c')) {
                        cloneRec.Original_Booking_Amount__c = dynamicTypeConversion(
                            resultMap.get('Original_Booking_Amount__c')
                        );
                    }
                    if (resultMap.containsKey('Rolling_Time_Zone__c')) {
                        cloneRec.Rolling_Time_Zone__c = (String) resultMap.get(
                            'Rolling_Time_Zone__c'
                        );
                    }
                    
                    if (resultMap.containsKey('BETA_Program__c')) {
                        cloneRec.BETA_Program__c = (String) resultMap.get(
                            'BETA_Program__c'
                        );
                    }
                    if (resultMap.containsKey('Day_Part__c')) {
                        cloneRec.Day_Part__c = (String) resultMap.get('Day_Part__c');
                    }
                    
                    if (resultMap.containsKey('Frequency_Cap__c')) {
                        cloneRec.Frequency_Cap__c = (String) resultMap.get(
                            'Frequency_Cap__c'
                        );
                    }
                    
                    if (resultMap.containsKey('Product_Booking_Date__c')) {
                        cloneRec.Product_Booking_Date__c = bookingDate;
                    }
                    if (resultMap.containsKey('Reason__c')) {
                        cloneRec.Reason__c = (String) resultMap.get('Reason__c');
                    }
                    
                    insert cloneRec;
                    cloneRecReturn = cloneRec.Id;
                }
            }
            return cloneRecReturn;
        } catch (exception ex) {
            system.debug(ex);
            throw new AuraHandledException(getFriendlyMessage(ex));
        }
    }
    
    public static String getFriendlyMessage(Exception ex) {
        String errorMsg = ex.getMessage();
        if (errorMsg.contains('_EXCEPTION,')) {
            String pureErrorMsg = errorMsg.substringAfter('_EXCEPTION,');
            pureErrorMsg = pureErrorMsg.Substring(0, pureErrorMsg.length() - 4);
            return pureErrorMsg;
        }
        
        return ex.getMessage();
    }
    
    public static Decimal dynamicTypeConversion(Object rateValue) {
        try {
            if (rateValue instanceof String) {
                return Decimal.valueOf((String) rateValue);
            } else if (rateValue instanceof Integer) {
                return Decimal.valueOf((Integer) rateValue);
            } else if (rateValue instanceof Decimal) {
                return (Decimal) rateValue;
            } else {
                // Handle other data types or throw an exception if unexpected
                System.debug('Unexpected data type Error from dynamicTypeConversion');
                throw new AuraHandledException(
                    'Unexpected data type Error from dynamicTypeConversion'
                );
            }
        } catch (exception ex) {
            system.debug(ex.getMessage() + ex.getStackTraceString());
            return null;
        }
    }
}