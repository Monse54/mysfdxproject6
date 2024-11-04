@isTest
public class OpportunityAfterInsertTriggerTest {
  @isTest
  static void opportunityUpdateTest() {
    Test.startTest();

    Boolean exceptionThrown = false;

    Account acc = new Account(Name = 'Test Account');
    insert acc;
    acc.Account_Review_Status__c='Approved';
    update acc;

    Date flightStartDate = Date.newInstance(2021, 5, 12);
    Date flightEndDate = Date.newInstance(2021, 8, 20);
    Date bookingDate = Date.newInstance(2021, 3, 12);

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
      CloseDate = bookingDate,
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
	  Client_Direct__c=TRUE,
      Campaign_Name__c = 'test'
    );
    insert opp;
    Opportunity updatedOpp = [
      SELECT id, OwnerId
      FROM Opportunity
      WHERE id = :opp.Id
    ];

    List<Opportunity_Seller__c> osList = [
      SELECT id, Opportunity__c, Seller__c, Percentage__c
      FROM Opportunity_Seller__c
      WHERE Opportunity__c = :opp.Id
    ];
    System.assert(
      osList.size() == 1,
      'Number of Opportunity Sellers do not match'
    );
    System.assert(
      osList[0].Seller__c == updatedOpp.OwnerId,
      'Default Seller does not match'
    );
    System.assert(
      osList[0].Percentage__c == 100,
      'Default Percentage should be 100'
    );

    Test.StopTest();
  }
}