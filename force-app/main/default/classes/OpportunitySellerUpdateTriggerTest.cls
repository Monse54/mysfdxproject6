@isTest(isParallel=false)
public class OpportunitySellerUpdateTriggerTest {
  @isTest
  static void opportnitySellerUpdateTest() {
    TestHelper.setupTests();
    Test.startTest();
    Boolean exceptionThrown = false;
    Date flightStartDate = Date.newInstance(2021, 5, 12);
    Date flightEndDate = Date.newInstance(2021, 8, 20);

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

     Account acc1 = new Account(
      Name = 'Test Account',
      Type = Constants.ACCOUNT_TYPE_BRAND
    );

    insert acc1;
	account acc = new account(id = acc1.Id,
      Account_Review_Status__c = 'Approved');
    update acc;

    Contact contact1 = new Contact(
      LastName = 'Account Contact',
      AccountId = acc.Id,
      Email = 'test@gmail.com'
    );
    insert contact1;

    Pricebook2 pb = new Pricebook2(
      Name = Constants.PRICEBOOK_MANAGED,
      isActive = true
    );
    insert pb;

    Opportunity opp = new Opportunity(
      Name = 'Test Opportunity',
      CloseDate = system.today(),
      StageName = 'RFP received',
      Flight_Start_Date__c = system.today(),
      Flight_End_Date__c = system.today(),
      AccountId = acc.Id,
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

    try {
      exceptionThrown = false;
      os2.Percentage__c = 60;
      update os2;
    } catch (Exception e) {
      exceptionThrown = true;
      System.assert(
        e.getMessage()
          .contains('Total Percentage from all sellers cannot be more than 100')
      );
    } finally {
      os2.Percentage__c = 50;
      System.assertEquals(true, exceptionThrown, 'No exception was thrown');
    }

    try {
      exceptionThrown = false;
      os2.Seller__c = UserInfo.getUserId();
      System.debug(UserInfo.getUserId() + ' -> ' + u.Id);
      update os2;
    } catch (Exception e) {
      exceptionThrown = true;
      System.assert(
        e.getMessage().contains('Cannot add the same seller twice')
      );
    } finally {
      os2.Percentage__c = 50;
      System.assertEquals(true, exceptionThrown, 'No exception was thrown');
    }
    Test.StopTest();
  }

  @isTest
  static void opportnityProductSellerSyncTest() {
    Test.startTest();
    Boolean exceptionThrown = false;
    Id pricebookId = Test.getStandardPricebookId();

    Date flightStartDate = Date.newInstance(2021, 5, 12);
    Date flightEndDate = Date.newInstance(2021, 8, 20);

    Double CPM = 15.0;
    Integer MinImpressions = 10000;

     Account acc1 = new Account(
      Name = 'Test Account',
      Type = Constants.ACCOUNT_TYPE_BRAND
    );

    insert acc1;
	account acc = new account(id = acc1.Id,
      Account_Review_Status__c = 'Approved');
    update acc;

    Contact contact1 = new Contact(
      LastName = 'Account Contact',
      AccountId = acc.Id,
       Email = 'test@gmail.com'
    );
    insert contact1;

    Pricebook2 pb = new Pricebook2(
      Name = Constants.PRICEBOOK_MANAGED,
      isActive = true
    );
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
      CloseDate = system.today(),
      StageName = 'RFP received',
      Dropbox_URL__c = 'http://nnnn',
      Flight_Start_Date__c = system.today(),
      Flight_End_Date__c = system.today(),
      AccountId = acc.Id,
      Seller_Region__c = 'National Media & Entertainment',
      Brand_Name__c = 'Test',
      Brand_Id__c = '1111',
      IO_Number_Available__c = 'Not Available',
      CSM__c = UserInfo.getUserId(),
      Market_Type__c = 'M&E',
	  Client_Direct__c=TRUE,
      Campaign_Name__c = 'test'
    );
    insert opp;

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
            Flight_Start_Date__c = flightStartDate,
            Flight_End_Date__c = flightEndDate,
            MinImpressions__c = MinImpressions,
            CPM__c = CPM,
        BETA_Program__c = 'Collections Beta',
            IO_Product_Display_Name__c = 'test',
        	Audience_Segment_Details__c = 'Test Audience_Segment_Details__c',
            Country__c = 'India'
        );
        insert oliCTVNative1;

    List<Opportunity_Seller__c> osList = [
      SELECT id, Seller__c, Opportunity__c, Percentage__c
      FROM Opportunity_Seller__c
      WHERE Opportunity__c = :opp.Id
    ];

    List<Opportunity_Product_Seller__c> opsList = [
      SELECT id, Seller__c, Opportunity_Product__c
      FROM Opportunity_Product_Seller__c
      WHERE Opportunity_Product__c = :oliCTVNative1.Id
    ];

    System.assert(
      opsList.size() == 1,
      'One Opportunity Product Seller should be added'
    );
    System.assert(osList.size() == 1, 'One Opportunity Seller should be added');

    Opportunity_Seller__c os = osList[0];
    os.Percentage__c = 80;
    update os;

    opsList = [
      SELECT id, Seller__c, Opportunity_Product__c, Seller_Percentage__c
      FROM Opportunity_Product_Seller__c
      WHERE Opportunity_Product__c = :oliCTVNative1.Id
    ];

    System.assert(
      opsList[0].Seller_Percentage__c == 80,
      'Seller Percentage should be updated'
    );

    //delete os;
    opsList = [
      SELECT id, Seller__c, Opportunity_Product__c, Seller_Percentage__c
      FROM Opportunity_Product_Seller__c
      WHERE Opportunity_Product__c = :oliCTVNative1.Id
    ];

  /*  System.assert(
      opsList.size() == 0,
      'Opportunity Product Seller should be deleted'
    );*/

    Test.StopTest();
  }
}