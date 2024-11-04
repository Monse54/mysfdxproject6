@isTest
public class SlackMarketingAlertTest {
  private class RestMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      String fullJson = '{"message":"OK"}';

      HTTPResponse res = new HTTPResponse();
      res.setHeader('Content-Type', 'text/json');
      res.setBody(fullJson);
      res.setStatusCode(200);
      return res;
    }
  }

  @isTest
  static void accountMarketingHelpAlertTest() {
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new RestMock());

    Account acc = new Account(Name = 'Test Account');

    SlackAccountMarketingAlert.AccountHelpInput input = new SlackAccountMarketingAlert.AccountHelpInput();
    input.userName = 'Test User';
    input.domainURL = 'Domain URL';
    input.customNote = 'Test Custom Note';
    input.accountRecord = acc;

    List<SlackAccountMarketingAlert.AccountHelpInput> inputs = new List<SlackAccountMarketingAlert.AccountHelpInput>();
    inputs.add(input);

    SlackAccountMarketingAlert.accountMarketingHelpAlert(inputs);

    Test.StopTest();
  }

  @isTest
  static void opportunityMarketingHelpAlert() {
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new RestMock());

    Account acc = new Account(
      Name = 'Test Account',
      Type = Constants.ACCOUNT_TYPE_AGENCY
    );
    insert acc;
    acc.Account_Review_Status__c='Approved';
    update acc;

    Date flightStartDate = Date.newInstance(2021, 5, 12);
    Date flightEndDate = Date.newInstance(2021, 8, 20);

    Pricebook2 pb = new Pricebook2(
      Name = Constants.PRICEBOOK_MANAGED,
      isActive = true
    );
    insert pb;

    Opportunity opp = new Opportunity(
      Name = 'Test Opportunity',
      CloseDate = flightEndDate,
      StageName = 'RFP received',
      Flight_Start_Date__c = flightStartDate,
      Flight_End_Date__c = flightEndDate,
      AccountId = acc.Id,
      Campaign_Name__c = 'test',
      Seller_Region__c = 'National Media & Entertainment',
      IO_Number_Available__c = 'Not Available',
      CSM__c = UserInfo.getUserId(),
      Market_Type__c = 'M&E',
      Client_Direct__c = true
    );
    insert opp;

    SlackOppMarketingAlert.OpportunityHelpInput input = new SlackOppMarketingAlert.OpportunityHelpInput();
    input.userName = 'Test User';
    input.domainURL = 'Domain URL';
    input.customNote = 'Test Custom Note';
    input.opportuntiyRecord = opp;

    List<SlackOppMarketingAlert.OpportunityHelpInput> inputs = new List<SlackOppMarketingAlert.OpportunityHelpInput>();
    inputs.add(input);

    SlackOppMarketingAlert.opportunityMarketingHelpAlert(inputs);

    Test.StopTest();
  }
}