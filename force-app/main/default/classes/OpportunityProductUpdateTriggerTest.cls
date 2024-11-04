@isTest(isParallel=false)
public class OpportunityProductUpdateTriggerTest {
  @isTest
  static void opportunityProductSellerSyncTest() {
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
    acc.Account_Review_Status__c = 'Approved';
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
      Original_Booking_Amount__c = 1000,
      Total_Booking_Amount__c = 1000,
      IO_Impression_Goal__c = 2,
      Audience_Targeting__c = '1P ACR',
      Device_Type__c = 'CTV',
      Audience_Segment_Details__c = 'Test segment',
      Product_Full_Name__c = 'test Placement',
      Placement_Category__c = 'Added Value',
      Placement_Type__c = 'ROS',
      End_Date__c = system.now(),
      Product_Family__c = 'Managed Service Impressions',
      OpportunityId = opp.Id,
      Rate__c = 0,
      Flight_Start_Date__c = flightStartDate,
      Flight_End_Date__c = flightEndDate,
      MinImpressions__c = MinImpressions,
      CPM__c = CPM,
      BETA_Program__c = 'Collections Beta',
      IO_Product_Display_Name__c = 'test',
      Country__c = 'India'
    );
    insert oliCTVNative1;

    osList = [
      SELECT id, Seller__c, Opportunity__c, Percentage__c
      FROM Opportunity_Seller__c
      WHERE Opportunity__c = :opp.Id
    ];

    List<Opportunity_Product_Seller__c> opsList = [
      SELECT id, Seller__c, Opportunity_Product__c, Seller_Percentage__c
      FROM Opportunity_Product_Seller__c
      WHERE Opportunity_Product__c = :oliCTVNative1.Id
    ];

    /*(System.assert(
      opsList.size() == 2,
      'One Opportunity Product Seller should be added'
    );*/
    System.assert(osList.size() == 2, 'One Opportunity Seller should be added');

    for (Opportunity_Product_Seller__c ops : opsList) {
      System.assert(ops.Opportunity_Product__c == oliCTVNative1.Id);
      System.assert(ops.Seller_Percentage__c == 50);
    }
    try {
      delete oliCTVNative1;
    } catch (exception e) {
    }

    /*delete oliCTVNative1;

    opsList = [
      SELECT id, Seller__c, Opportunity_Product__c, Seller_Percentage__c
      FROM Opportunity_Product_Seller__c
      WHERE Opportunity_Product__c = :oliCTVNative1.Id
    ];

    System.assert(
      opsList.size() == 0,
      'Opportunity Product Seller should be deleted'
    );*/

    Test.StopTest();
  }

  @istest
  public static void insertclonetest() {
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
    acc.Account_Review_Status__c = 'Approved';
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
      Audience_Segment_Details__c = 'Test segment',
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
      Rate__c = 0,
      BETA_Program__c = 'Collections Beta',
      IO_Product_Display_Name__c = 'test',
      Flight_Start_Date__c = flightStartDate,
      Flight_End_Date__c = flightEndDate,
      MinImpressions__c = MinImpressions,
      CPM__c = CPM,
      Country__c = 'India'
    );
    insert oliCTVNative1;
    String fieldSet = '{"Product_Booking_Date__c":"2024-08-01T00:00:00Z","Rate__c":150.00,"Product_Family__c":"Managed Service Impressions","Buy_Type__c":"CPM","Country__c":"United States","Type__c":"Default","Placement_Type__c":"ROS","Placement_Billing_Name__c":"Test Billing","Placement_Category__c":"Regular","Audience_Targeting__c":"1P ACR","Audience_Segment_Details__c":"1P ACR","BETA_Program__c":"Content Store RB Beta Program","Default_Billing_Ad_Server__c":"1st Party","Budget_Amount__c":5000.00,"CPM__c":25.00,"Device_Type__c":"Mobile","Incremental_Booking_Amount__c":3000.00,"IO_Impression_Goal__c":1000,"RB_Extension_info__c":"Not Allowed","Max_Extension_Time__c":"2024-08-01T12:00:00Z","Frequency_Cap__c":"Cap A","Day_Part__c":"Day Part A","Start_Date__c":"2024-08-01T00:00:00Z","End_Date__c":"2024-08-31T23:59:59Z","Original_Booking_Amount__c":10000.00,"Rolling_Time_Zone__c":"Yes","Reason__c":"Reason A"}';
    string oppid = opp.Id;
    Test.Starttest();
    delete oliCTVNative1;
    Test.Stoptest();
  }

  @istest
  public static void insertclonetest1() {
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
    acc.Account_Review_Status__c = 'Approved';
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
      Flight_Start_Date__c = flightStartDate,
      Flight_End_Date__c = flightEndDate,
      AccountId = acc.Id,
      Dropbox_URL__c = 'http://nnnn',
      Seller_Region__c = 'National Media & Entertainment',
      Brand_Name__c = 'Test',
      Brand_Id__c = '1111',
      IO_Number_Available__c = 'Not Available',
      CSM__c = UserInfo.getUserId(),
      Market_Type__c = 'M&E',
      Client_Direct__c = true,
      Campaign_Name__c = 'test',
      RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
        .get('3-Corporate')
        .getRecordTypeId()
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
      Placement_Billing_Name__c = 'test Placement',
      Placement_Category__c = 'Added Value',
      Placement_Type__c = 'ROS',
      Product_Full_Name__c = 'test Placement',
      End_Date__c = system.now(),
      Product_Family__c = 'Managed Service Impressions',
      OpportunityId = opp.Id,
      Flight_Start_Date__c = flightStartDate,
      Flight_End_Date__c = flightEndDate,
      MinImpressions__c = null,
      CPM__c = CPM,
      BETA_Program__c = 'Collections Beta',
      IO_Product_Display_Name__c = 'test',
      Country__c = 'India',
      Rate__c = 0
    );
    insert oliCTVNative1;
    String fieldSet = '{"Product_Booking_Date__c":"2024-08-01T00:00:00Z","Rate__c":150.00,"Product_Family__c":"Managed Service Impressions","Buy_Type__c":"CPM","Country__c":"United States","Type__c":"Default","Placement_Type__c":"ROS","Placement_Billing_Name__c":"Test Billing","Placement_Category__c":"Regular","Audience_Targeting__c":"1P ACR","Audience_Segment_Details__c":"1P ACR","BETA_Program__c":"Content Store RB Beta Program","Default_Billing_Ad_Server__c":"1st Party","Budget_Amount__c":5000.00,"CPM__c":25.00,"Device_Type__c":"Mobile","Incremental_Booking_Amount__c":3000.00,"IO_Impression_Goal__c":1000,"RB_Extension_info__c":"Not Allowed","Max_Extension_Time__c":"2024-08-01T12:00:00Z","Frequency_Cap__c":"Cap A","Day_Part__c":"Day Part A","Start_Date__c":"2024-08-01T00:00:00Z","End_Date__c":"2024-08-31T23:59:59Z","Original_Booking_Amount__c":10000.00,"Rolling_Time_Zone__c":"Yes","Reason__c":"Reason A"}';
    string oppid = opp.Id;
    Test.Starttest();
    try {
      delete oliCTVNative1;
    } catch (Exception e) {
    }
    Test.Stoptest();
  }

  /* @isTest
  static void programmaticOpportunityTest() {
    TestHelper.setupTests();

    String STAGE_VERBAL_CONFIRM = 'Verbal Confirm';
    String STAGE_RFP = 'RFP received';
    Id pricebookId = Test.getStandardPricebookId();
    Boolean exceptionThrown = false;

    Account acc = new Account(Name = 'Test Account');
    insert acc;
	acc.Account_Review_Status__c='Approved';
    update acc;
    Date flightStartDate = Date.newInstance(2021, 5, 12);
    Date flightEndDate = Date.newInstance(2021, 8, 20);

    Double CPM = 15.0;
    Integer MinImpressions = 10000;

    Contact contact1 = new Contact(
      LastName = 'Account Contact',
      AccountId = acc.Id,
      Email = 'test@lgads.tv'
    );
    insert contact1;

    Pricebook2 pbSS = new Pricebook2(
      Name = Constants.PRICEBOOK_SELF,
      isActive = true
    );
    insert pbSS;

    RecordType rt = [
      SELECT id, Name
      FROM RecordType
      WHERE name = 'Self Service'
    ];

    Opportunity opp = new Opportunity(
      RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Self Service').getRecordTypeId(),
      Name = 'Test Opportunity',
      CloseDate = flightEndDate,
      StageName = 'RFP received',
      Flight_Start_Date__c = flightStartDate,
      Flight_End_Date__c = flightEndDate,
      AccountId = acc.Id,
      Primary_Billing_Contact__c = contact1.Id,
      Seller_Region__c = 'National Media & Entertainment',
      Brand_Name__c = 'Test',
      Brand_Id__c = '1111',
      IO_Number_Available__c = 'Not Available',
      CSM__c = UserInfo.getUserId(),
      Market_Type__c = 'M&E',
      Client_Direct__c = true
    );
    insert opp;

    Product2 productPMP = new Product2(
      Name = 'Programmatic PMP',
      ProductCode = 'Code',
      isActive = true,
      Family = 'Managed Service Impressions',
      CanUseRevenueSchedule = true
    );
    insert productPMP;

    PricebookEntry pbEntrySSStandard = new PricebookEntry(
      Pricebook2Id = pricebookId,
      Product2Id = productPMP.Id,
      UnitPrice = 1200.00,
      IsActive = true
    );
    insert pbEntrySSStandard;

    PricebookEntry pbEntrySS = new PricebookEntry(
      Pricebook2Id = pbSS.Id,
      Product2Id = productPMP.Id,
      UnitPrice = 1200.00,
      IsActive = true
    );

    insert pbEntrySS;

    OpportunityLineItem oliCTVNative1 = new OpportunityLineItem(
      PricebookEntryId = pbEntrySS.id,
      UnitPrice = 1000,
      IO_Impression_Goal__c = 2,
      Audience_Targeting__c = '1P ACR',
      Device_Type__c = 'CTV',
      Product_Full_Name__c = 'test Placement',
      Placement_Category__c = 'Added Value',
      Placement_Type__c = 'ROS',
      End_Date__c = system.now(),
      Product_Family__c = 'Managed Service Impressions',
      OpportunityId = opp.Id,
      Flight_Start_Date__c = flightStartDate,
      Flight_End_Date__c = flightEndDate,
      MinImpressions__c = MinImpressions,
      CPM__c = CPM,
      Country__c = 'India'
    );
    insert oliCTVNative1;

    Test.startTest();
    List<Opportunity> opps = new List<Opportunity>();
   	Map<String, Integer> contactMap = new Map<String, Integer>();
    opps.add(opp);
    String conid = contact1.id;
    contactMap.put(conid, 2);
	opportunityTriggerhandler.createAgency(opps);
    opportunityTriggerhandler.deleteAgency(opps);
    opportunityTriggerhandler.updateContactsDelete(contactMap);

    try {
      exceptionThrown = false;
      oliCTVNative1.Country__c = null;
      update oliCTVNative1;
    } catch (Exception e) {
      exceptionThrown = true;
      System.assert(e.getMessage().contains('Country is required'));
    } finally {
      oliCTVNative1.Country__c = Constants.COUNTRY_US;
      System.assertEquals(true, exceptionThrown, 'No exception was thrown');
    }

    Test.stopTest();
  }*/

  /*static void productTypeTests() {
    Test.startTest();
    String STAGE_VERBAL_CONFIRM = 'Notification';
    Id pricebookId = Test.getStandardPricebookId();
    Boolean exceptionThrown = false;

    Account acc = new Account(Name = 'Test Account');

    insert acc;

    Date flightStartDate = Date.newInstance(2021, 5, 12);
    Date flightEndDate = Date.newInstance(2021, 8, 20);
    Date bookingDate = Date.newInstance(2021, 3, 12);

    Double CPM = 15.0;
    Integer MinImpressions = 10000;

    Contact contact1 = new Contact(
      LastName = 'Account Contact',
      AccountId = acc.Id,
      Email = 'test@lgads.tv'
    );
    insert contact1;

    Pricebook2 pb = new Pricebook2(
      Name = Constants.PRICEBOOK_MANAGED,
      isActive = true
    );
    insert pb;

    Opportunity opp = new Opportunity(
      Name = 'Test Opportunity',
      CloseDate = flightEndDate,
      StageName = STAGE_VERBAL_CONFIRM,
      Flight_Start_Date__c = flightStartDate,
      Flight_End_Date__c = flightEndDate,
      AccountId = acc.Id,
      Primary_Billing_Contact__c = contact1.Id,
      Seller_Region__c = 'National Media & Entertainment',
      Brand_Name__c = 'Test',
      Brand_Id__c = '1111',
      IO_Number_Available__c = 'Not Available',
      CSM__c = UserInfo.getUserId(),
      Market_Type__c = 'M&E'
    );
    insert opp;

    Product2 productNative = new Product2(
      Name = 'CTV native',
      ProductCode = 'Code',
      isActive = true,
      Family = 'Managed Service Impressions',
      CanUseRevenueSchedule = true
    );

    insert productNative;

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
      IO_Impression_Goal__c = 2,
      Audience_Targeting__c = '1P ACR',
      Device_Type__c = 'CTV',
      Product_Full_Name__c = 'test Placement',
      Placement_Category__c = 'Added Value',
      Placement_Type__c = 'ROS',
      End_Date__c = system.now(),
      Product_Family__c = 'Managed Service Impressions',
      OpportunityId = opp.Id,
      Flight_Start_Date__c = flightStartDate,
      Flight_End_Date__c = flightEndDate,
      MinImpressions__c = MinImpressions,
      CPM__c = CPM,
      Country__c = Constants.COUNTRY_US
    );

    OpportunityLineItem oliIncremental = new OpportunityLineItem(
      PricebookEntryId = pbEntryNative.id,
      UnitPrice = 1000,
      IO_Impression_Goal__c = 2,
      Audience_Targeting__c = '1P ACR',
      Device_Type__c = 'CTV',
      Product_Full_Name__c = 'test Placement',
      Placement_Category__c = 'Added Value',
      Placement_Type__c = 'ROS',
      End_Date__c = system.now(),
      Product_Family__c = 'Managed Service Impressions',
      OpportunityId = opp.Id,
      Flight_Start_Date__c = flightStartDate,
      Flight_End_Date__c = flightEndDate,
      MinImpressions__c = MinImpressions,
      CPM__c = CPM,
      //Product_Booking_Date__c = bookingDate,
     // Reason__c = 'NA',
     // Type__c = Constants.PRODUCT_TYPE_INCREMENTAL,
      Country__c = 'India'
    );
      
    

    OpportunityLineItem oliMakeGood = new OpportunityLineItem(
      PricebookEntryId = pbEntryNative.id,
      UnitPrice = 0,
      OpportunityId = opp.Id,
      IO_Impression_Goal__c = 2,
      Audience_Targeting__c = '1P ACR',
      Device_Type__c = 'CTV',
      Product_Full_Name__c = 'test Placement',
      Placement_Category__c = 'Added Value',
      Placement_Type__c = 'ROS',
      End_Date__c = system.now(),
      Product_Family__c = 'Managed Service Impressions',
      Flight_Start_Date__c = flightStartDate,
      Flight_End_Date__c = flightEndDate,
      MinImpressions__c = MinImpressions,
      CPM__c = CPM,
     // Product_Booking_Date__c = bookingDate,
      //Reason__c = 'NA',
     // Type__c = Constants.PRODUCT_TYPE_MAKE_GOOD,
      Value__c = 100,
      Country__c = 'India'
    );

    OpportunityLineItem oliAddedValue = new OpportunityLineItem(
      PricebookEntryId = pbEntryNative.id,
      UnitPrice = 0,
      OpportunityId = opp.Id,
      IO_Impression_Goal__c = 2,
      Audience_Targeting__c = '1P ACR',
      Device_Type__c = 'CTV',
  
      Product_Full_Name__c = 'test Placement',
      
      Placement_Category__c = 'Added Value',
      Placement_Type__c = 'ROS',
      End_Date__c = system.now(),
      Product_Family__c = 'Managed Service Impressions',
      Flight_Start_Date__c = flightStartDate,
      Flight_End_Date__c = flightEndDate,
      MinImpressions__c = MinImpressions,
      CPM__c = CPM,
    //  Product_Booking_Date__c = bookingDate,
     // Reason__c = 'NA',
      //Type__c = Constants.PRODUCT_TYPE_ADDED_VALUE,
      Value__c = 100,
      Country__c = 'India'
    );

    // Reason and product booking date mandatory for incremental/revised
    try {
      exceptionThrown = false;
    //  oliIncremental.Reason__c = null;
      insert oliIncremental;
    } catch (Exception e) {
      exceptionThrown = true;
      System.assert(e.getMessage().contains('Reason is mandatory'));
    } finally {
    //  oliIncremental.Reason__c = 'NA';
      System.assertEquals(true, exceptionThrown, 'No exception was thrown');
    }

    try {
      exceptionThrown = false;
     // oliIncremental.Product_Booking_Date__c = null;
      insert oliIncremental;
    } catch (Exception e) {
      exceptionThrown = true;
      System.assert(
        e.getMessage().contains('Product Booking Date is mandatory')
      );
    } finally {
      //oliIncremental.Product_Booking_Date__c = bookingDate;
      System.assertEquals(true, exceptionThrown, 'No exception was thrown');
    }

    // Reason mandatory for added value/ Make good
    try {
      exceptionThrown = false;
    //  oliMakeGood.Reason__c = null;
      insert oliMakeGood;
    } catch (Exception e) {
      exceptionThrown = true;
      System.assert(e.getMessage().contains('Reason is mandatory'));
    } finally {
    //  oliMakeGood.Reason__c = 'NA';
      System.assertEquals(true, exceptionThrown, 'No exception was thrown');
    }

    try {
      exceptionThrown = false;
     /// oliAddedValue.Reason__c = null;
      insert oliAddedValue;
    } catch (Exception e) {
      exceptionThrown = true;
      System.assert(e.getMessage().contains('Reason is mandatory'));
    } finally {
      //oliAddedValue.Reason__c = 'NA';
      System.assertEquals(true, exceptionThrown, 'No exception was thrown');
    }
    
    // Value should be not empty for Make Good / Added Value
    try {
      exceptionThrown = false;
      oliMakeGood.Value__c = null;
      insert oliMakeGood;
    } catch (Exception e) {
      exceptionThrown = true;
      System.assert(
        e.getMessage().contains('products must have a value amount')
      );
    } finally {
      oliMakeGood.Value__c = 100;
      System.assertEquals(true, exceptionThrown, 'No exception was thrown');
    }

    try {
      exceptionThrown = false;
      oliAddedValue.Value__c = null;
      insert oliAddedValue;
    } catch (Exception e) {
      exceptionThrown = true;
      System.assert(
        e.getMessage().contains('products must have a value amount')
      );
    } finally {
      oliAddedValue.Value__c = 100;
      System.assertEquals(true, exceptionThrown, 'No exception was thrown');
    }

    // Booking amount should be 0 for Make Good/ Added Value
    try {
      exceptionThrown = false;
      oliMakeGood.UnitPrice = 100;
      insert oliMakeGood;
    } catch (Exception e) {
      exceptionThrown = true;
      System.assert(
        e.getMessage().contains('products should have booking amount = 0')
      );
    } finally {
      oliMakeGood.UnitPrice = 0;
      System.assertEquals(true, exceptionThrown, 'No exception was thrown');
    }

    try {
      exceptionThrown = false;
      oliAddedValue.UnitPrice = 100;
      insert oliAddedValue;
    } catch (Exception e) {
      exceptionThrown = true;
      System.assert(
        e.getMessage().contains('products should have booking amount = 0')
      );
    } finally {
      oliAddedValue.UnitPrice = 0;
      System.assertEquals(true, exceptionThrown, 'No exception was thrown');
    }

    // Type of product can't be null
    try {
      exceptionThrown = false;
      //oliMakeGood.Type__c = null;
      insert oliMakeGood;
    } catch (Exception e) {
      exceptionThrown = true;
      System.assert(
        e.getMessage().contains('Please select a type for the product')
      );
    } finally {
    //  oliMakeGood.Type__c = Constants.PRODUCT_TYPE_MAKE_GOOD;
      System.assertEquals(true, exceptionThrown, 'No exception was thrown');
    }

    // No exception should be throw for valid products
    try {
      exceptionThrown = false;
      insert oliIncremental;
      insert oliMakeGood;
      insert oliAddedValue;
    } catch (Exception e) {
      exceptionThrown = true;
    } finally {
      System.assertEquals(
        false,
        exceptionThrown,
        'No exception should be thrown for valid products'
      );
    }
	
    Test.stopTest();
  }*/
}