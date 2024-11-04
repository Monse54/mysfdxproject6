@isTest
public class BrandInfoLookupControllerTest {
  private class RestGetBrandsMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      String fullJson = '[{"id":2090,"name":"Diet Coke"},{"id":6095,"name":"Coker Tire"},{"id":10664,"name":"COCA COLA - ORIG COKE"},{"id":10679,"name":"COCA COLA - COKE RGE"},{"id":12911,"name":"COCA COLA - DIET COKE"}]';

      HTTPResponse res = new HTTPResponse();
      res.setHeader('Content-Type', 'text/json');
      res.setBody(fullJson);
      res.setStatusCode(200);
      return res;
    }
  }

  private class RestGetBrandInfoMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      String fullJson = '{"id":"12","name":"Apps"}';

      HTTPResponse res = new HTTPResponse();
      res.setHeader('Content-Type', 'text/json');
      res.setBody(fullJson);
      res.setStatusCode(200);
      return res;
    }
  }

  @isTest
  static void getBrandsTest() {
    Test.setMock(HttpCalloutMock.class, new RestGetBrandsMock());
    BrandInfoLookupController.getBrands('App');
  }

  @isTest
  static void updateBrandInfoTest() {
    Test.startTest();

    Test.setMock(HttpCalloutMock.class, new RestGetBrandInfoMock());
    Account acc = new Account();
    acc.Name = 'Test Account';
    insert acc;

    BrandInfoLookupController.updateBrandInfo(acc.Id, '12', 'Test Brand');

    Account updatedAcc = [
      SELECT Id, Brand_Id__c, Brand_Name__c
      FROM Account
      WHERE Id = :acc.Id
    ];

    System.assertEquals('12', updatedAcc.Brand_Id__c);
    System.assertEquals('Test Brand', updatedAcc.Brand_Name__c);

    Test.StopTest();
  }

  @isTest
  static void updateOpportunityBrandInfoTest() {
    Test.startTest();

    Test.setMock(HttpCalloutMock.class, new RestGetBrandInfoMock());
  

    Pricebook2 pb = new Pricebook2(
      Name = Constants.PRICEBOOK_MANAGED,
      isActive = true
    );
    insert pb;
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

    BrandInfoLookupController.updateOpportunityBrandInfo(
      opp.Id,
      '12',
      'Test Brand'
    );

    Opportunity updatedOppty = [
      SELECT Id, Brand_Id__c, Brand_Name__c
      FROM Opportunity
      WHERE Id = :opp.Id
    ];

    System.assertEquals('12', updatedOppty.Brand_Id__c);
    System.assertEquals('Test Brand', updatedOppty.Brand_Name__c);

    Test.StopTest();
  }

  private class RestAddNewBrandMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      String fullJson = '{"status": true,"id": 3803240}';

      HTTPResponse res = new HTTPResponse();
      res.setHeader('Content-Type', 'text/json');
      res.setBody(fullJson);
      res.setStatusCode(200);
      return res;
    }
  }

  @isTest
  static void addNewBrandTest() {
    Test.setMock(HttpCalloutMock.class, new RestAddNewBrandMock());
    Object response = BrandInfoLookupController.addNewBrand(
      'test-brand',
      0,
      'fahad@lgads.tv',
      'insights'
    );
    Object expected = (Object) JSON.deserializeUntyped(
      '{"status": true,"id": 3803240}'
    );

    System.assertEquals(response, expected);
  }

  private class RestAddBrandToCampaignMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      String fullJson = '{"message": "successfully updated alph brand"}';

      HTTPResponse res = new HTTPResponse();
      res.setHeader('Content-Type', 'text/json');
      res.setBody(fullJson);
      res.setStatusCode(200);
      return res;
    }
  }

  @isTest(SeeAllData=true)
  static void addBrandToCampaignTest() {
    Test.setMock(HttpCalloutMock.class, new RestAddBrandToCampaignMock());
    Object response = BrandInfoLookupController.addBrandToCampaign(
      '001235',
      '123344',
      'test-brand'
    );
    Object expected = (Object) JSON.deserializeUntyped(
      '{"message": "successfully updated alph brand"}'
    );

    System.assertEquals(response, expected);
  }
}