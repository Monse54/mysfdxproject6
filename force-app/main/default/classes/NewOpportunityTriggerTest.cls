@isTest
public class NewOpportunityTriggerTest {
  // @isTest
  // static void test() {
  //   Test.startTest();

  //   // Constants
  //   String ACCOUNT_NAME = 'Test Account';
  //   String AGENCY_NAME = 'Test Agency';
  //   String OPP_NAME = 'Test Opportunity';

  //   Account acc = new Account(Name = ACCOUNT_NAME);
  //   Account agency = new Account(Name = AGENCY_NAME);
  //   insert acc;
  //   insert agency;

  //   Date flightStartDate = Date.newInstance(2021, 5, 12);
  //   Date flightEndDate = Date.newInstance(2021, 8, 20);

  //   Pricebook2 pb = new Pricebook2(
  //     Name = Constants.PRICEBOOK_MANAGED,
  //     isActive = true
  //   );
  //   insert pb;

  //   // Opportunity without Agency
  //   Opportunity opp1 = new Opportunity(
  //     Name = 'Test Opportunity',
  //     CloseDate = flightEndDate,
  //     StageName = 'RFP received',
  //     Flight_Start_Date__c = flightStartDate,
  //     Flight_End_Date__c = flightEndDate,
  //     AccountId = acc.Id,
  //     Seller_Region__c = 'National Media & Entertainment',
  //     IO_Number_Available__c = 'Not Available',
  //     Market_Type__c = 'M&E',
  // 	Client_Direct__c=TRUE
  //   );
  //   insert opp1;

  //   Opportunity oppRes = [
  //     SELECT Id, Name
  //     FROM Opportunity
  //     WHERE Id = :opp1.Id
  //   ][0];

  //   System.assertEquals(ACCOUNT_NAME + ' - ' + OPP_NAME, oppRes.Name);

  //   // Opportunity with Agency
  //   Opportunity opp2 = new Opportunity(
  //     Name = 'Test Opportunity',
  //     CloseDate = flightEndDate,
  //     StageName = 'RFP received',
  //     Flight_Start_Date__c = flightStartDate,
  //     Flight_End_Date__c = flightEndDate,
  //     AccountId = acc.Id,
  //     Seller_Region__c = 'National Media & Entertainment',
  //     Agency__c = agency.Id,
  //     IO_Number_Available__c = 'Not Available',
  //     Market_Type__c = 'M&E',
  // 	Client_Direct__c=TRUE
  //   );
  //   insert opp2;

  //   oppRes = [SELECT Id, Name FROM Opportunity WHERE Id = :opp2.Id][0];

  //   System.assertEquals(
  //     ACCOUNT_NAME +
  //     ' - ' +
  //     AGENCY_NAME +
  //     ' - ' +
  //     OPP_NAME,
  //     oppRes.Name
  //   );
  // }
}