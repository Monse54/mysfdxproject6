@isTest
public class PGRevenueLandingProcessorBatchTest {
    
    @isTest
    static void testBatch() {
        
        // Set up test data
        Date flightStartDate = Date.newInstance(2021, 5, 12);
        Date flightEndDate = Date.newInstance(2021, 8, 20);
        Date bookingDate = Date.newInstance(2021, 3, 12);
    
        Double CPM = 15.0;
        Integer MinImpressions = 10000;
        List<Opportunity> opps = new List<Opportunity>();
        List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
        List<Programmatic_Revenue_Landing__c> programmaticRevenueLandings = new List<Programmatic_Revenue_Landing__c>();
        List<Deal__c> deals = new List<Deal__c>();
        
       Account acc = new Account(name='test acc123@qwe');
        insert acc;
        acc.Account_Review_Status__c='Approved';
        update acc;
        Account acc2 = new Account(name='agency acc12322');
        acc2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        insert acc2;
        acc2.Account_Review_Status__c='Approved';
        update acc2;
        Contact contact1 = new Contact(FirstName='Ricky111', LastName='Pointing');
        contact1.AccountId = acc.Id;
        contact1.Is_Billing_Contact__c = TRUE;
        contact1.Email = '12test.user1@example.com';
        insert contact1;
        Contact contact2 = new Contact(FirstName='12Bark', LastName='Putin');
        contact2.Email = '12test.user2@example.com';
        contact2.AccountId = acc.Id;
        insert contact2;
        Contact contact3 = new Contact(FirstName='22Test', LastName='Data');
        contact3.Email = '221test.user3@example.com';
        contact3.AccountId = acc.Id;
        insert contact3;
        Opportunity opp = new Opportunity(Name='test opp',Primary_Billing_Contact__c=contact1.Id,Secondary_Billing_Contact__c=contact2.Id, Amount=100, TotalOpportunityQuantity=10, CloseDate=System.today(), AccountId=acc.Id);
        opp.Seller_Region__c = 'National Media & Entertainment';
        opp.Brand_Name__c = 'Test';
        opp.StageName = 'RFP received';
        opp.Dropbox_URL__c = 'http://nnnn';
        opp.Flight_End_Date__c = Date.newInstance(2021, 5, 30);
        opp.Flight_Start_Date__c = Date.newInstance(2021, 5, 1);
        opp.Seller_Region__c = 'National Media & Entertainment';
        opp.Brand_Id__c = '1111';
        opp.IO_Number_Available__c = 'Not Available';
        opp.CSM__c = UserInfo.getUserId();
        opp.Market_Type__c = 'M&E';
        opp.Main_Point_Of_Contact_Primary__c = contact3.Id;
        opp.Agency__c = acc2.Id;
        opp.Campaign_Name__c = 'test camp';
        insert opp;
        
        Product2 productNative = new Product2(
      Name = 'Programmatic PMP',
      ProductCode = 'Code',
      isActive = true,
      Family = 'Managed Service Impressions',
      CanUseRevenueSchedule = true
    );

    insert productNative;
        
    Pricebook2 pb = new Pricebook2(
      Name = Constants.PRICEBOOK_MANAGED,
      isActive = true
    );
    insert pb;
    Id pricebookId = Test.getStandardPricebookId();

    PricebookEntry pbEntryNativeStandard = new PricebookEntry(
      Pricebook2Id = pricebookId,
      Product2Id = productNative.Id,
      UnitPrice = 1200.00,
      IsActive = true
    );

    PricebookEntry pbEntryNative = new PricebookEntry(
      Pricebook2Id = pb.id,
      Product2Id = productNative.Id,
      UnitPrice = 1200.00,
      IsActive = true
    );

    insert new List<PricebookEntry>{ pbEntryNativeStandard, pbEntryNative };

    OpportunityLineItem oliCTVNative = new OpportunityLineItem(
            PricebookEntryId = pbEntryNative.id,
            UnitPrice = 1000,
        	Rate__c = 0,
			Original_Booking_Amount__c = 1000,
		    Total_Booking_Amount__c = 1000,
            IO_Impression_Goal__c = 2,
            Audience_Targeting__c = '1P ACR',
            Device_Type__c = 'CTV',
            Placement_Billing_Name__c = 'test Placement',
            Placement_Category__c = 'Added Value',
            Placement_Type__c = 'ROS',
        	Audience_Segment_Details__c = 'Test segment',
      		Product_Full_Name__c = 'test Placement',
            End_Date__c = system.now(),
            Product_Family__c = 'Managed Service Impressions',
            OpportunityId = opp.Id,
            Flight_Start_Date__c = flightStartDate,
            Flight_End_Date__c = flightEndDate,
            MinImpressions__c = MinImpressions,
            CPM__c = CPM,
            Country__c = 'India',
        	BETA_Program__c = 'Content Store RB Beta Program',
        	IO_Product_Display_Name__c = 'Programmatic Guaranteed'
        );
        insert oliCTVNative;
        
        // Create Programmatic_Revenue_Landing__c records
        Programmatic_Revenue_Landing__c prlWithOpp = new Programmatic_Revenue_Landing__c(
            Status__c = 'To be processed',
            Time_Bucket__c = Date.today(),
            Opportunity__c = opp.Id,
            Campaign_Id__c = 'Campaign_1',
            Campaign_Name__c = 'Campaign Name 1',
            Demand_Partner__c = 'Partner 1',
            Pmp_Type__c = 'test acc123@qwe_agency acc12322_ _test camp_5/1/21 - 8/20/21 CTV Native',
            Revenue_Cost__c = 1000,
            Deal_Type__c = 'Deal Type 1',
            Impressions__c = 1000
        );
        programmaticRevenueLandings.add(prlWithOpp);
        
        Programmatic_Revenue_Landing__c prlWithoutOpp = new Programmatic_Revenue_Landing__c(
            Status__c = 'To be processed',
            //Time_Bucket__c = Date.today(),
            Opportunity__c = null,
            Campaign_Id__c = 'Campaign_2',
            Campaign_Name__c = 'Campaign Name 2',
            Demand_Partner__c = 'Partner 2',
            Pmp_Type__c = 'Type 2',
            Revenue_Cost__c = 2000,
            Deal_Type__c = 'Deal Type 2',
            Impressions__c = 2000
        );
        programmaticRevenueLandings.add(prlWithoutOpp);
        
        insert programmaticRevenueLandings;
        
        // Run the batch class
        Test.startTest();
        Database.executeBatch(new PGRevenueLandingProcessorBatch(), 200);
        Test.stopTest();
        
       }
    
    @isTest
    static void testBatchWithNoOpportunityLineItems() {
        Account acc = new Account(name='test acc');
        insert acc;
        acc.Account_Review_Status__c='Approved';
        update acc;
        Account acc2 = new Account(name='agency acc');
        acc2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        insert acc2;
        acc2.Account_Review_Status__c='Approved';
        update acc2;
        Contact contact1 = new Contact(FirstName='Ricky', LastName='Pointing');
        contact1.AccountId = acc.Id;
        contact1.Is_Billing_Contact__c = TRUE;
        contact1.Email = 'test.user1@example.com';
        insert contact1;
        Contact contact2 = new Contact(FirstName='Bark', LastName='Putin');
        contact2.Email = 'test.user2@example.com';
        contact2.AccountId = acc.Id;
        insert contact2;
        Contact contact3 = new Contact(FirstName='Test', LastName='Data');
        contact3.Email = 'test.user3@example.com';
        contact3.AccountId = acc.Id;
        insert contact3;
        Opportunity opp = new Opportunity(Name='test opp',Primary_Billing_Contact__c=contact1.Id,Secondary_Billing_Contact__c=contact2.Id, Amount=100, TotalOpportunityQuantity=10, CloseDate=System.today(), AccountId=acc.Id);
        opp.Seller_Region__c = 'National Media & Entertainment';
        opp.Brand_Name__c = 'Test';
        opp.Dropbox_URL__c = 'http://nnnn';
        opp.StageName = 'RFP received';
        opp.Flight_End_Date__c = Date.newInstance(2021, 5, 30);
        opp.Flight_Start_Date__c = Date.newInstance(2021, 5, 1);
        opp.Seller_Region__c = 'National Media & Entertainment';
        opp.Brand_Id__c = '1111';
        opp.IO_Number_Available__c = 'Not Available';
        opp.CSM__c = UserInfo.getUserId();
        opp.Market_Type__c = 'M&E';
        opp.Main_Point_Of_Contact_Primary__c = contact3.Id;
        opp.Agency__c = acc2.Id;
        opp.Campaign_Name__c = 'test camp';
        insert opp;
        
        
         Product2 productNative = new Product2(
      Name = 'Programmatic Guaranteed',
      ProductCode = 'Code',
      isActive = true,
      Family = 'Managed Service Impressions',
      CanUseRevenueSchedule = true
    );

    insert productNative;
        
    Pricebook2 pb = new Pricebook2(
      Name = Constants.PRICEBOOK_MANAGED,
      isActive = true
    );
    insert pb;
    Id pricebookId = Test.getStandardPricebookId();

    PricebookEntry pbEntryNativeStandard = new PricebookEntry(
      Pricebook2Id = pricebookId,
      Product2Id = productNative.Id,
      UnitPrice = 1200.00,
      IsActive = true
    );

    PricebookEntry pbEntryNative = new PricebookEntry(
      Pricebook2Id = pb.id,
      Product2Id = productNative.Id,
      UnitPrice = 1200.00,
      IsActive = true
    );

    insert new List<PricebookEntry>{ pbEntryNativeStandard, pbEntryNative };
        
        Programmatic_Revenue_Landing__c prlWithNoLineItems = new Programmatic_Revenue_Landing__c(
            Status__c = 'To be processed',
            //Time_Bucket__c = Date.today(),
            Opportunity__c = opp.Id,
            Campaign_Id__c = 'Campaign_No_Line_Items',
            Campaign_Name__c = 'Campaign No Line Items',
            Demand_Partner__c = 'Partner No Line Items',
            Pmp_Type__c = 'Type No Line Items',
            Deal_Type__c = 'programmatic_guarantee',
            Revenue_Cost__c = 3000,
            Impressions__c = 3000
        );
        insert prlWithNoLineItems;
        
        Test.startTest();
        //Database.executeBatch(new PGRevenueLandingProcessorBatch(), 200);
        String cronExp = '0 0 0 ? * MON-FRI'; // Every weekday at midnight
        System.schedule('Test PGRevenueLandingProcessorBatchScheduler', cronExp, new PGRevenueLandingProcessorBatchScheduler());
        Test.stopTest();
        
        /*Programmatic_Revenue_Landing__c prlResult = [SELECT Id, Status__c, Status_Message__c FROM Programmatic_Revenue_Landing__c WHERE Id = :prlWithNoLineItems.Id];
        System.assertEquals('Error', prlResult.Status__c, 'Expected the record without matching OpportunityLineItems to have an error status.');
        System.assertEquals('Products not present on the opportunity.', prlResult.Status_Message__c, 'Expected error message for missing OpportunityLineItems.');*/
    }
}