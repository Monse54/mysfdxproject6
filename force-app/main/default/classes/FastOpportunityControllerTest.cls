/**
* Created by cxu on 10/02/2017.
*/
@IsTest
public with sharing class FastOpportunityControllerTest {
    @testSetup
    static void setup() {
        Pricebook2 pricebook = new Pricebook2();
        pricebook.Name = Constants.PRICEBOOK_MANAGED;
        pricebook.IsActive = true;
        
        insert pricebook;
        
        System.assert(pricebook.Id != null);
        
        Product2 product = new Product2(
            Name = 'CTV native',
            ProductCode = 'Code',
            isActive = true,
            Family = 'Managed Service Impressions',
            CanUseRevenueSchedule = true
        );
        
        insert product;
        System.assert(product.Id != null);
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = product.Id,
            UnitPrice = 20,
            IsActive = true
        );
        insert standardPrice;
        
        System.assert(standardPrice.Id != null);
        
        PricebookEntry entry = new PricebookEntry(
            IsActive = true,
            Pricebook2Id = pricebook.Id,
            Product2Id = product.Id,
            UnitPrice = 20
        );
        
        insert entry;
        System.assert(entry.Id != null);
    }
    
    @IsTest
    static void getOpportunityTest() {
        Account account = new Account(
            Name = 'Test Account',
            Type = Constants.ACCOUNT_TYPE_BRAND,
            Duplicate_Note__c = 'Reason'
        );
        insert account;
        
        account.Account_Review_Status__c = 'Approved';
        update account;
        
        Pricebook2 pb = new Pricebook2(Name = Constants.PRICEBOOK_MANAGED);
        insert pb;
        
        Opportunity opportunity = new Opportunity(
            Name = 'Test Opportunity',
            CloseDate = system.today(),
            StageName = 'RFP received',
            Flight_Start_Date__c = system.today(),
            Flight_End_Date__c = system.today(),
            AccountId = account.Id,
            Dropbox_URL__c = 'http://nnnn',
            Seller_Region__c = 'National Media & Entertainment',
            Brand_Name__c = 'Test',
            Brand_Id__c = '1111',
            IO_Number_Available__c = 'Not Available',
            CSM__c = UserInfo.getUserId(),
            Market_Type__c = 'M&E',
            Client_Direct__c=TRUE,
            Campaign_Name__c = 'test'
        );
        insert opportunity;
        
        Opportunity actual = FastOpportunityController.getOpportunity(
            opportunity.Id
        );
        System.assertEquals(opportunity.Id, actual.Id);
        
        string error = FastOpportunityController.updateOpportunity(
            opportunity,
            pb.id
        );
        System.assertEquals('', error);
    }
    
    @isTest
    static void getPricebooksTest() {
        List<Pricebook2> pricebooks = FastOpportunityController.getPricebooks();
        System.assert(pricebooks != null);
        System.assertEquals(1, pricebooks.size());
        
        List<PricebookEntry> entries = FastOpportunityController.getPricebookEntries(
            pricebooks[0].Id
        );
        Date flightStartDate = Date.newInstance(2021, 5, 12);
        Date flightEndDate = Date.newInstance(2021, 8, 20);
        
        Double CPM = 15.0;
        Integer MinImpressions = 10000;
        Account account = new Account(
            Name = 'Test Account',
            Type = Constants.ACCOUNT_TYPE_BRAND,
            Duplicate_Note__c = 'Reason'
        );
        insert account;
        
        account.Account_Review_Status__c = 'Approved';
        update account;
        Opportunity opportunity = new Opportunity(
            Name = 'Test Opportunity',
            CloseDate = system.today(),
            StageName = 'RFP received',
            Flight_Start_Date__c = system.today(),
            Flight_End_Date__c = system.today(),
            AccountId = account.Id,
            Seller_Region__c = 'National Media & Entertainment',
            Brand_Name__c = 'Test',
            Brand_Id__c = '1111',
            IO_Number_Available__c = 'Not Available',
            CSM__c = UserInfo.getUserId(),
            Market_Type__c = 'M&E',
            Client_Direct__c=TRUE,
            Campaign_Name__c = 'test',
            Dropbox_URL__c = 'http://nnnn'
        );
        insert opportunity;
        OpportunityLineItem oliCTVNative1 = new OpportunityLineItem(
            PricebookEntryId = entries[0].id,
            UnitPrice = 1000,
			Original_Booking_Amount__c = 1000,
		    Total_Booking_Amount__c = 1000,
            IO_Impression_Goal__c = 2,
            Rate__c = 0,
            Audience_Targeting__c = '1P ACR',
            Device_Type__c = 'CTV',
            Audience_Segment_Details__c = 'Test Audience_Segment_Details__c',
            Placement_Billing_Name__c = 'test Placement',
            Placement_Category__c = 'Added Value',
            Placement_Type__c = 'ROS',
      		Product_Full_Name__c = 'test Placement',
            End_Date__c = system.now(),
            Product_Family__c = 'Managed Service Impressions',
            OpportunityId = opportunity.Id,
            Flight_Start_Date__c = flightStartDate,
            Flight_End_Date__c = flightEndDate,
            MinImpressions__c = MinImpressions,
            CPM__c = CPM,
            BETA_Program__c = 'Collections Beta',
            IO_Product_Display_Name__c = 'test',
            Country__c = 'India'
        );
        insert oliCTVNative1;
        List<OpportunityLineItem> lineItems = new List<OpportunityLineItem> ();
        lineItems.add(oliCTVNative1);
    	string opportunityId = opportunity.Id;
        FastOpportunityController.updateLineItems(lineItems,opportunityId);
        System.assert(entries != null);
        System.assertEquals(1, entries.size());
    }
    
    
}