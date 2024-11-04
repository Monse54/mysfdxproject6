@isTest(isParallel=false)
public with sharing class ProgrammaticOpportunityControllerTest {
    @istest
    public static void insertclonetest(){
        Boolean exceptionThrown = false;
        Id pricebookId = Test.getStandardPricebookId();
        
        User u = new user();
        u.LastName = 'Test Code';
        u.Email = 'test@test.com';
        u.Alias = 'Tcode';
        u.Username = 'test-lgads@test.com';
        u.CommunityNickname = 'test12';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'GMT';
        u.ProfileID = '00e5Y000001yOPUQA2';
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        insert u;
        Date flightStartDate = Date.newInstance(2021, 5, 12);
        Date flightEndDate = Date.newInstance(2021, 8, 20);
        
        Double CPM = 15.0;
        Integer MinImpressions = 10000;
        
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        acc.Account_Review_Status__c='Approved';
    	update acc;
        Contact contact1 = new Contact(
            LastName = 'Account Contact',
            AccountId = acc.Id,
            Email = 'test@lgads.tv'
        );
        insert contact1;
        
        Pricebook2 pb = new Pricebook2(Name = 'Managed Service');
        insert pb;
        
        Product2 productNative = new Product2(
            Name = 'CTV native',
            ProductCode = 'Code',
            isActive = true,
            Family = 'Managed Service Impressions',
            CanUseRevenueSchedule = true
        );
        
        insert productNative;
        
        PricebookEntry pbEntryNative = new PricebookEntry(
            Pricebook2Id = pb.Id,
            Product2Id = productNative.Id,
            UnitPrice = 1200.00,
            IsActive = true
        );
        
        PricebookEntry pbEntryNativeStandard = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = productNative.Id,
            UnitPrice = 1200.00,
            IsActive = true
        );
        
        insert new List<PricebookEntry>{ pbEntryNativeStandard, pbEntryNative };
            
            Opportunity opp = new Opportunity(
                Name = 'Test Opportunity',
                Dropbox_URL__c = 'http://nnnn',
                CloseDate = flightEndDate,
                StageName = 'RFP received',
                Flight_Start_Date__c = flightStartDate,
                Flight_End_Date__c = flightEndDate,
                AccountId = acc.Id,
                Seller_Region__c = 'National Media & Entertainment',
                Brand_Name__c = 'Test',
                Brand_Id__c = '1111',
                IO_Number_Available__c = 'Not Available',
                CSM__c = UserInfo.getUserId(),
                Market_Type__c = 'M&E',
                Client_Direct__c = true,
                Campaign_Name__c = 'test'
            );
        insert opp;
        
        List<Opportunity_Seller__c> osList = [
            SELECT id, Opportunity__c, Seller__c, Percentage__c
            FROM Opportunity_Seller__c
            WHERE Opportunity__c = :opp.Id AND Seller__c = :UserInfo.getUserId()
        ];
        
        Opportunity_Seller__c os1 = osList[0];
        os1.Percentage__c = 50;
        update os1;
        
        Opportunity_Seller__c os2 = new Opportunity_Seller__c(
            Opportunity__c = opp.Id,
            Seller__c = u.Id,
            Percentage__c = 50
        );
        insert os2;
        
        OpportunityLineItem oliCTVNative1 = new OpportunityLineItem(
            PricebookEntryId = pbEntryNative.id,
            UnitPrice = 1000,
			Original_Booking_Amount__c = 1000,
		    Total_Booking_Amount__c = 1000,
            IO_Impression_Goal__c = 2,
            Audience_Targeting__c = '1P ACR',
            Device_Type__c = 'CTV',
            Rate__c = 0,
            Placement_Billing_Name__c = 'test Placement',
            Placement_Category__c = 'Added Value',
            Placement_Type__c = 'ROS',
      		Product_Full_Name__c = 'test Placement',
            End_Date__c = system.now(),
            Product_Family__c = 'Managed Service Impressions',
            OpportunityId = opp.Id,
            Flight_Start_Date__c = flightStartDate,
            Flight_End_Date__c = flightEndDate,
            MinImpressions__c = MinImpressions,
            CPM__c = CPM,
            BETA_Program__c = 'Collections Beta',
            IO_Product_Display_Name__c = 'test',
            Audience_Segment_Details__c = 'Test segment',
            Country__c = 'India'
        );
        insert oliCTVNative1;
        list<OpportunityLineItem> oli = new list<OpportunityLineItem>();
        oli.add(oliCTVNative1);
        string oppid = opp.Id;
        Test.Starttest();
        try{
            double totalAmount = 200;
            ProgrammaticOpportunityController.updateProgrammaticOpportunity(opp);
            ProgrammaticOpportunityController.updateProgProducts(oli, totalAmount, system.today()+4, system.today()+8, true);
        }catch(Exception e){
            
        }
        Test.Stoptest();
        
    }
}