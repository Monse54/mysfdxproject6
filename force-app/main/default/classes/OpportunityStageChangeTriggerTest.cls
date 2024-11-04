@isTest(isParallel=false)
public class OpportunityStageChangeTriggerTest {
  @isTest
  static void resellerAccountTest() {
    TestHelper.setupTests();
    Test.startTest();

    Boolean exceptionThrown = false;

    Account acc1 = new Account(
      Name = 'Test Account 1',
      Type = Constants.ACCOUNT_TYPE_RESELLER
    );
     
    Account acc2 = new Account(
      Name = 'Test Account 2',
      Type = Constants.ACCOUNT_TYPE_AGENCY
    );
      
    insert new List<Account>{ acc1, acc2 };
        
    acc2.Account_Review_Status__c  = 'Approved';
    update acc2;
      
    acc1.Account_Review_Status__c  = 'Approved';
    update acc1;

    Date flightStartDate = Date.newInstance(2021, 5, 12);
    Date flightEndDate = Date.newInstance(2021, 8, 20);
    Date bookingDate = Date.newInstance(2021, 3, 12);

    Contact contact1 = new Contact(
      LastName = 'Account Contact',
      AccountId = acc1.Id,
      Email = 'test1234@gmail.com'
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
      Campaign_Name__c = 'test',
      StageName = 'RFP received',
      Flight_Start_Date__c = flightStartDate,
      Flight_End_Date__c = flightEndDate,
      AccountId = acc1.Id,
      Seller_Region__c = Constants.BUSINESS_VERTICAL_RESELLER,
      Brand_Name__c = 'Test',
      Brand_Id__c = '1111',
      //IO_Number_Available__c = 'Not Available',
      CSM__c = UserInfo.getUserId(),
      Client_Direct__c = true,
      Market_Type__c = 'M&E'
    );

    try {
      opp.Seller_Region__c = Constants.BUSINESS_VERTICAL_NATIONAL_ME;
      insert opp;
    } catch (Exception e) {
      exceptionThrown = true;
      /*System.assert(
        e.getMessage().contains('Please select business vertical as Reseller')
      );*/
    } finally {
      opp.Seller_Region__c = Constants.BUSINESS_VERTICAL_RESELLER;
     // System.assertEquals(true, exceptionThrown, 'No exception was thrown');
    }

    try {
      opp.Seller_Region__c = Constants.BUSINESS_VERTICAL_RESELLER;
      opp.AccountId = acc2.id;
      insert opp;
    } catch (Exception e) {
      exceptionThrown = true;
      
    } finally {
      opp.AccountId = acc1.id;
      System.assertEquals(true, exceptionThrown, 'No exception was thrown');
    }

    try {
      exceptionThrown = false;
      opp.Seller_Region__c = Constants.BUSINESS_VERTICAL_NATIONAL_ME;
      opp.AccountId = acc2.id;
      insert opp;
    } catch (Exception e) {
      exceptionThrown = true;
    } finally {
     
    }

    try {
      exceptionThrown = false;
      opp.Seller_Region__c = Constants.BUSINESS_VERTICAL_RESELLER;
      opp.AccountId = acc1.id;
      System.debug('Inserting opp' + opp.id + ' ' + opp.AccountId);
      update opp;
    } catch (Exception e) {
      exceptionThrown = true;
      System.debug('Exception thrown ' + e.getMessage());
      System.debug('Opp ' + opp.Account.Name);
    } finally {
      /*System.assertEquals(
        true,
        exceptionThrown,
        'Exception should not be thrown'
      );*/
    }

    Test.StopTest();
  }

  @isTest
  static void recordTypeMismatchTest() {
    TestHelper.setupTests();
    Test.startTest();

    Boolean exceptionThrown = false;

    Account acc = new Account(
      Name = 'Test Account',
      Type = Constants.ACCOUNT_TYPE_AGENCY
    );
    insert acc;
	acc.Account_Review_Status__c='Approved';
    update acc;
    Opportunity opp = new Opportunity(
      Name = 'Test Opportunity',
      CloseDate = Date.newInstance(2022, 3, 30),
      StageName = 'RFP received',
      Campaign_Name__c = 'test',
      AccountId = acc.Id,
      Seller_Region__c = 'National Media & Entertainment',
      Brand_Name__c = 'Test',
      Brand_Id__c = '1111',
      //IO_Number_Available__c = 'Not Available',
      CSM__c = UserInfo.getUserId(),
      Market_Type__c = 'M&E'
    );

    Pricebook2 managedPB = new Pricebook2(
      Name = Constants.PRICEBOOK_MANAGED,
      IsActive = true
    );
    Pricebook2 selfPB = new Pricebook2(
      Name = Constants.PRICEBOOK_SELF,
      IsActive = true
    );
    Pricebook2 insightsPB = new Pricebook2(
      Name = Constants.PRICEBOOK_CORPORATE,
      IsActive = true
    );
    insert new List<Pricebook2>{ managedPB, selfPB, insightsPB };

    RecordType managedRT = [
      SELECT id, name
      FROM RecordType
      WHERE name = :Constants.RECORD_TYPE_MANAGED
    ];
    

    // Tests using today as CreatedDate
    try {
     
      opp.Pricebook2Id = selfPB.id;
      insert opp;
    } catch (Exception e) {
      exceptionThrown = true;
     
    } finally {
     // System.assertEquals(true, exceptionThrown, 'No exception was thrown');
    }

    try {
      exceptionThrown = false;
      opp.Pricebook2Id = managedPB.id;
      insert opp;
    } catch (Exception e) {
      exceptionThrown = true;
      
    } finally {
      
    }

    try {
      exceptionThrown = false;
      opp.Pricebook2Id = insightsPB.id;
      insert opp;
    } catch (Exception e) {
      exceptionThrown = true;
     
    } finally {
      System.assertEquals(true, exceptionThrown, 'No exception was thrown');
    }

    try {
      exceptionThrown = false;
      opp.RecordTypeId = managedRT.id;
      opp.Pricebook2Id = insightsPB.id;
      insert opp;
    } catch (Exception e) {
      exceptionThrown = true;
      
    } finally {
      //System.assertEquals(true, exceptionThrown, 'No exception was thrown');
    }

    try {
      exceptionThrown = false;
      
      opp.Pricebook2Id = selfPB.id;
      insert opp;
    } catch (Exception e) {
      exceptionThrown = true;
      
    } finally {
      //System.assertEquals(true, exceptionThrown, 'No exception was thrown');
    }

    try {
      exceptionThrown = false;
      
      opp.Pricebook2Id = managedPB.id;
      insert opp;
    } catch (Exception e) {
      exceptionThrown = true;
     
    } finally {
     // System.assertEquals(true, exceptionThrown, 'No exception was thrown');
    }

    try {
      exceptionThrown = false;
      opp.RecordTypeId = managedRT.id;
      insert opp;
    } catch (Exception e) {
      exceptionThrown = true;
    } finally {
      
     
      
    }

    try {
      exceptionThrown = false;
      opp.RecordTypeId = managedRT.id;
      opp.Pricebook2Id = managedPB.id;
      update opp;
    } catch (Exception e) {
      exceptionThrown = true;
    } finally {
      
    }

    try {
      exceptionThrown = false;
      opp.Pricebook2Id = selfPB.id;
      update opp;
    } catch (Exception e) {
      exceptionThrown = true;
    } finally {
      
    }

    try {
      exceptionThrown = false;
      
      opp.Pricebook2Id = insightsPB.id;
      update opp;
    } catch (Exception e) {
      exceptionThrown = true;
    } finally {
      
    }

    Test.StopTest();
  }

  @isTest
  static void recordTypeMismatchTestOlderOpp() {
    TestHelper.setupTests();
    Account acc = new Account(
      Name = 'Test Account',
      Type = Constants.ACCOUNT_TYPE_AGENCY
    );
    insert acc;
    acc.Account_Review_Status__c='Approved';
    update acc;

    Pricebook2 managedPB = new Pricebook2(
      Name = Constants.PRICEBOOK_MANAGED,
      IsActive = true
    );
    Pricebook2 selfPB = new Pricebook2(
      Name = Constants.PRICEBOOK_SELF,
      IsActive = true
    );
    Pricebook2 insightsPB = new Pricebook2(
      Name = Constants.PRICEBOOK_CORPORATE,
      IsActive = true
    );
    insert new List<Pricebook2>{ managedPB, selfPB, insightsPB };

    Opportunity opp = new Opportunity(
      Name = 'Test Opportunity',
      CloseDate = Date.newInstance(2022, 3, 30),
      StageName = 'RFP received',
      Campaign_Name__c = 'test',
      AccountId = acc.Id,
      Seller_Region__c = 'National Media & Entertainment',
      Brand_Name__c = 'Test',
      Brand_Id__c = '1111',
      //IO_Number_Available__c = 'Not Available',
      CSM__c = UserInfo.getUserId(),
      Market_Type__c = 'M&E',
      Client_Direct__c = true,
      Flight_Start_Date__c = system.today(),
      Flight_End_Date__c = system.today()
    );
    insert opp;

    Test.setCreatedDate(opp.Id, Constants.OPP_TYPE_MISMATCH_DATE.addDays(-1));
    Test.startTest();

    Boolean exceptionThrown = false;

    RecordType managedRT = [
      SELECT id, name
      FROM RecordType
      WHERE name = :Constants.RECORD_TYPE_MANAGED
    ];
    
    // Tests using older CreatedDate
    try {
      exceptionThrown = false;
      opp.RecordTypeId = managedRT.id;
      opp.Pricebook2Id = selfPB.id;
      update opp;
    } catch (Exception e) {
      exceptionThrown = true;
      System.debug('Error ' + e.getMessage());
    } finally {
      System.assertEquals(
        false,
        exceptionThrown,
        'No exception should be thrown for older created date'
      );
    }

    try {
      exceptionThrown = false;
      opp.Pricebook2Id = managedPB.id;
      update opp;
    } catch (Exception e) {
      exceptionThrown = true;
      System.debug('Error ' + e.getMessage());
    } finally {
      System.assertEquals(
        false,
        exceptionThrown,
        'No exception should be thrown for older created date'
      );
    }

    try {
      exceptionThrown = false;
      
      opp.Pricebook2Id = selfPB.id;
      update opp;
    } catch (Exception e) {
      exceptionThrown = true;
      System.debug('Error ' + e.getMessage());
    } finally {
      /*System.assertEquals(
        false,
        exceptionThrown,
        'No exception should be thrown for older created date'
      );*/
    }

    try {
      exceptionThrown = false;
      
      opp.Pricebook2Id = managedPB.id;
      update opp;
    } catch (Exception e) {
      exceptionThrown = true;
      System.debug('Error ' + e.getMessage());
    } finally {
      /*System.assertEquals(
        false,
        exceptionThrown,
        'No exception should be thrown for older created date'
      );*/
    }

    try {
      exceptionThrown = false;
      opp.RecordTypeId = managedRT.id;
      opp.Pricebook2Id = insightsPB.id;
      update opp;
    } catch (Exception e) {
      exceptionThrown = true;
      System.debug('Error ' + e.getMessage());
    } finally {
      /*System.assertEquals(
        false,
        exceptionThrown,
        'No exception should be thrown for older created date'
      );*/
    }

    try {
      exceptionThrown = false;
      opp.Pricebook2Id = insightsPB.id;
      update opp;
    } catch (Exception e) {
      exceptionThrown = true;
      System.debug('Error ' + e.getMessage());
    } finally {
      /*System.assertEquals(
        false,
        exceptionThrown,
        'No exception should be thrown for older created date'
      );*/
    }

    Test.StopTest();
  }

  @isTest
  static void opportunityClosedWonTest() {
    TestHelper.setupTests();
    Date flightStartDate = Date.newInstance(2021, 5, 12);
    Date flightEndDate = Date.newInstance(2021, 8, 20);
    Id pricebookId = Test.getStandardPricebookId();

    Account acc = new Account(
      Name = 'Test Account',
      Type = Constants.ACCOUNT_TYPE_AGENCY
    );
    insert acc;
	acc.Account_Review_Status__c='Approved';
    update acc;
    Contact contact1 = new Contact(
      LastName = 'Account Contact',
      AccountId = acc.Id,
      Email = 'test234@gmail.com'
    );
    insert contact1;

    Product2 productNative = new Product2(
      Name = 'CTV native',
      ProductCode = 'Code',
      isActive = true,
      CanUseRevenueSchedule = true
    );
    insert productNative;

    Pricebook2 managedPB = new Pricebook2(
      Name = Constants.PRICEBOOK_MANAGED,
      IsActive = true
    );

    insert new List<Pricebook2>{ managedPB };

    PricebookEntry pbEntryNative = new PricebookEntry(
      Pricebook2Id = managedPB.id,
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
      CloseDate = Date.newInstance(2022, 3, 30),
      StageName = 'RFP received',
      AccountId = acc.Id,
      Campaign_Name__c = 'test',
      Seller_Region__c = 'National Media & Entertainment',
      Brand_Name__c = 'Test',
      Brand_Id__c = '1111',
	  Primary_billing_contact__c = contact1.Id,
      //IO_Number_Available__c = 'Not Available',
      CSM__c = UserInfo.getUserId(),
      Market_Type__c = 'M&E',
      Client_Direct__c = true,
      Flight_Start_Date__c = system.today(),
      Flight_End_Date__c = system.today()
    );
    insert opp;

    OpportunityLineItem oliCTVNative = new OpportunityLineItem(
      PricebookEntryId = pbEntryNative.id,
      UnitPrice = 1000,
      OpportunityId = opp.Id,
      Flight_Start_Date__c = flightStartDate,
      Flight_End_Date__c = flightEndDate,
      MinImpressions__c = 100000,
      CPM__c = 20,
      Country__c = Constants.COUNTRY_US
    );

    Test.startTest();

    Boolean exceptionThrown = false;

    try {
      exceptionThrown = false;
      opp.StageName = Constants.STAGE_CLOSED_WON;
      opp.Default_Billing_Ad_Server__c = 'Adform';
      opp.Country__c = 'India';
      opp.Main_Point_Of_Contact_Primary__c = contact1.id;
      update opp;
    } catch (Exception e) {
      exceptionThrown = true;
      System.debug('Exception ' + e.getMessage());
     
    } finally {
      System.assertEquals(true, exceptionThrown, 'No exception was thrown');
    }

    try {
      exceptionThrown = false;
      opp.StageName = 'Dummy';
      update opp;  
      opp.StageName = Constants.STAGE_WAITING_ASSETS;
      update opp;
    } catch (Exception e) {
      exceptionThrown = true;
      
    } finally {
      //System.assertEquals(true, exceptionThrown, 'No exception was thrown');
    }

    try {
      exceptionThrown = false;
      opp.StageName = Constants.STAGE_CLOSED_WON;
      insert oliCTVNative;
      update opp;
    } catch (Exception e) {
      exceptionThrown = true;
    } finally {
      
    }

    Test.StopTest();
  }
}