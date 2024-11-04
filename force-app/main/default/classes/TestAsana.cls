@isTest
public class TestAsana {
  private class RestMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      String fullJson = '{"data":{"permalink_url":"https://app.asana.com/0/1200134875094939/1200334050604084"}}';

      HTTPResponse res = new HTTPResponse();
      res.setHeader('Content-Type', 'text/json');
      res.setBody(fullJson);
      res.setStatusCode(200);
      return res;
    }
  }

  @isTest
  static void TestFeasibilityTaskCreationTrigger() {
    
    Test.setMock(HttpCalloutMock.class, new RestMock());
    Test.startTest();
    Account acc1 = new Account();
    acc1.Name = 'test acc';
    insert acc1;
    account acc = new account(id = acc1.Id, Account_Review_Status__c = 'Approved');
	update acc;

    Pricebook2 pb = new Pricebook2(
      Name = Constants.PRICEBOOK_MANAGED,
      isActive = true
    );
    insert pb;

    Opportunity opp = new Opportunity();
    opp.Name = 'test';
    opp.AccountId = acc.id;
    opp.CloseDate = Date.newInstance(2021, 6, 1);
    opp.StageName = 'RFP received';
    opp.Flight_End_Date__c = Date.newInstance(2021, 5, 30);
    opp.Flight_Start_Date__c = Date.newInstance(2021, 5, 1);
    opp.Seller_Region__c = 'National Media & Entertainment';
    opp.Brand_Name__c = 'Test';
    opp.Brand_Id__c = '1111';
    opp.Dropbox_URL__c = 'http://nnnn';
    opp.IO_Number_Available__c = 'Not Available';
    opp.Market_Type__c = 'M&E';
    opp.Campaign_Name__c = 'test';
    opp.Client_Direct__c = true;
    opp.CSM__c = UserInfo.getUserId();
    opp.X3P_Verification_Partner__c = 'IAS : Fraud';
    insert opp;

    Feasibilty__c f = new Feasibilty__c();
    f.Priority__c = 'Low';
    f.Due_Date__c = Date.newInstance(1960, 2, 17);
    f.Advertiser__c = 'Advertiser ABC';
    f.Opportunity__c = opp.id;
    f.Rate_Type__c = 'CPM';
    f.CPM_CPVC_Sale_Price__c = '1';
    f.Max_Budget_Requested__c = '1';
    f.Max_Quantity_Requested__c = '1';
    f.Product_Type__c = 'Cross Screen Display';

    insert f;

    Test.StopTest();
      
  }

  @isTest
  static void TestCaseTaskCreationTrigger() {
    Test.setMock(HttpCalloutMock.class, new RestMock());
    
    Test.startTest();
    Account acc1 = new Account();
    acc1.Name = 'test acc';
    insert acc1;
    account acc = new account(id = acc1.Id, Account_Review_Status__c = 'Approved');
	update acc;
    Pricebook2 pb = new Pricebook2(
      Name = Constants.PRICEBOOK_MANAGED,
      isActive = true
    );
    insert pb;

    Opportunity opp = new Opportunity();
    opp.Name = 'test';
    opp.AccountId = acc.id;
    opp.Dropbox_URL__c = 'http://nnnn';
    opp.CloseDate = Date.newInstance(2021, 6, 1);
    opp.StageName = 'RFP received';
    opp.Flight_End_Date__c = Date.newInstance(2021, 5, 30);
    opp.Flight_Start_Date__c = Date.newInstance(2021, 5, 1);
    opp.Seller_Region__c = 'National Media & Entertainment';
    opp.Brand_Name__c = 'Test';
    opp.Campaign_Name__c = 'test';
    opp.Brand_Id__c = '1111';
    opp.IO_Number_Available__c = 'Not Available';
    opp.Market_Type__c = 'M&E';
    opp.Client_Direct__c = true;
    opp.CSM__c = UserInfo.getUserId();
    opp.X3P_Verification_Partner__c = 'IAS : Fraud';
    insert opp;

      
    Schema.RecordTypeInfo rfpRecordTypeInfo = Case.SObjectType.getDescribe().getRecordTypeInfosByName().get('RFI');
    Id rfpRecordTypeId = rfpRecordTypeInfo.getRecordTypeId();

    Case c = new Case();
    c.RecordTypeId = rfpRecordTypeId;
    c.Opportunity__c = opp.id;
    c.Status = 'New';
    c.Origin = 'Web';
    c.Subject = 'Test Subject';
    c.Media_Plan_AM__c = true;

    insert c;

    Test.StopTest();
  
  }
	@isTest
  static void TestProgrammaticDealTaskTrigger() {
    TestHelper.setupTests();
    Test.setMock(HttpCalloutMock.class, new RestMock());
    Test.startTest();

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
                Dropbox_URL__c = 'http://nnnn',
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
            Rate__c = 0,
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
            Audience_Segment_Details__c = 'Test segment',
            Flight_Start_Date__c = flightStartDate,
            Flight_End_Date__c = flightEndDate,
            MinImpressions__c = MinImpressions,
            CPM__c = CPM,
            BETA_Program__c = 'Collections Beta',
            IO_Product_Display_Name__c = 'test',
            Country__c = 'India'
        );
        insert oliCTVNative1;

    Programmatic_Deal_Request__c p = new Programmatic_Deal_Request__c();
    p.Opportunity_Product__c = oliCTVNative1.Id;
    p.Flight_Start_Date__c = flightStartDate;
    p.Flight_End_Date__c = flightEndDate;
    p.Inventory_Type__c = 'Display';
    p.Creative_Lengths__c = '15;30';
    p.CPM__c = 22.50;
    p.CPM_Type__c = 'Fixed';
    p.DSP__c = 'Test DSP';
    p.Seat_Id_DSP__c = 'Seat Id';
    p.Targeting__c = 'Targeting';
    p.Block_List__c = 'Block List';
    insert p;

    Test.StopTest();
  }
  
}