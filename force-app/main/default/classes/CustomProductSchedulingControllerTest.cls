@isTest
public with sharing class CustomProductSchedulingControllerTest {
    
  @isTest
  static void getNumberOfInstallmentsTestweekly() {
    Date startDate;
    Date endDate;
    string installationPeriod;
    Integer numOfInstallments;

    startDate = Date.newInstance(2021, 5, 8);
    endDate = Date.newInstance(2023, 9, 23);
      
    installationPeriod = 'Weekly';
    numOfInstallments = CustomProductSchedulingController.getNumberOfInstallments(
      startDate,
      endDate,
      installationPeriod
    );
    System.assertEquals(125, numOfInstallments);
    
  }
  @isTest
  static void getNumberOfInstallmentsTestMonthly() {
    Date startDate;
    Date endDate;
    string installationPeriod;
    Integer numOfInstallments;

    startDate = Date.newInstance(2021, 5, 8);
    endDate = Date.newInstance(2023, 9, 23);
      
    installationPeriod = 'Monthly';
    numOfInstallments = CustomProductSchedulingController.getNumberOfInstallments(
      startDate,
      endDate,
      installationPeriod
    );
    System.assertEquals(29, numOfInstallments);
  }
  @isTest
  static void getNumberOfInstallmentsTestQuarterly() {
    Date startDate;
    Date endDate;
    string installationPeriod;
    Integer numOfInstallments;

    startDate = Date.newInstance(2021, 5, 8);
    endDate = Date.newInstance(2023, 9, 23);
      
    installationPeriod = 'Quarterly';
    numOfInstallments = CustomProductSchedulingController.getNumberOfInstallments(
      startDate,
      endDate,
      installationPeriod
    );
    System.assertEquals(10, numOfInstallments);
    
  }
  @isTest
  static void getNumberOfInstallmentsTestYearly() {
    Date startDate;
    Date endDate;
    string installationPeriod;
    Integer numOfInstallments;

    startDate = Date.newInstance(2021, 5, 8);
    endDate = Date.newInstance(2023, 9, 23);
      
    installationPeriod = 'Yearly';
    numOfInstallments = CustomProductSchedulingController.getNumberOfInstallments(
      startDate,
      endDate,
      installationPeriod
    );
    System.assertEquals(3, numOfInstallments);
  }
  @isTest
  static void getNumberOfInstallmentsTest() {
    Date startDate;
    Date endDate;
    string installationPeriod;
    Integer numOfInstallments;

    startDate = Date.newInstance(2021, 5, 8);
    endDate = Date.newInstance(2023, 9, 23);
    installationPeriod = 'Daily';

    numOfInstallments = CustomProductSchedulingController.getNumberOfInstallments(
      startDate,
      endDate,
      installationPeriod
    );
    System.assertEquals(869, numOfInstallments);
  }
    
  
    public static OpportunityLineItem createOpportunityLineItem(Date flightStartDate, Date flightEndDate ){
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
                CloseDate = flightEndDate,
                StageName = 'RFP received',
                Dropbox_URL__c = 'http://nnnn',
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
            Rate__c = 0,
            Audience_Segment_Details__c = 'Test Audience_Segment_Details__c',
			Original_Booking_Amount__c = 1000,
		    Total_Booking_Amount__c = 1000,
            IO_Impression_Goal__c = 2,
            Audience_Targeting__c = '1P ACR',
            Device_Type__c = 'CTV',
            Placement_Billing_Name__c = 'test Placement',
            Placement_Category__c = 'Added Value',
            Placement_Type__c = 'ROS',
      		Product_Full_Name__c = 'test Placement',
            End_Date__c = system.now(),
            Product_Family__c = 'Managed Service Impressions',
            OpportunityId = opp.Id,
            BETA_Program__c = 'Collections Beta',
            IO_Product_Display_Name__c = 'test',
            Flight_Start_Date__c = flightStartDate,
            Flight_End_Date__c = flightEndDate,
            MinImpressions__c = MinImpressions,
            CPM__c = CPM,
            Country__c = 'India'
        );
        return oliCTVNative1;
    }

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
                CloseDate = flightEndDate,
                StageName = 'RFP received',
                Dropbox_URL__c = 'http://nnnn',
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
            Audience_Segment_Details__c = 'Test Audience_Segment_Details__c',
			Original_Booking_Amount__c = 1000,
		    Total_Booking_Amount__c = 1000,
            IO_Impression_Goal__c = 2,
            Audience_Targeting__c = '1P ACR',
            Rate__c = 0,
            Device_Type__c = 'CTV',
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
            Country__c = 'India'
        );
        insert oliCTVNative1;
        Decimal revenue = 3456;
        string oppid = opp.Id;
        Test.Starttest();
        try{
            CustomProductSchedulingController.updateSchedules(opp.Id, system.today() + 7, system.today() + 8,revenue,'test1','test2' );
        }catch(Exception e){
            
        }
        Test.Stoptest();
        
    }
}