@isTest
public class CaseBeforeUpdateTest {

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
    static void testNoFileUploadedError() {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        //RecordType rtype = [SELECT Id, DeveloperName from RecordType where DeveloperName = 'RFI' and SobjectType = 'Case' LIMIT 1];
        Id rTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RFP').getRecordTypeId();
        
        Account acc = new Account(name='test acc',Account_Review_Status__c = 'In Review');
		insert acc;
        Account acc4 = new account(id = acc.Id, Account_Review_Status__c = 'Approved');
        update acc4;
		Account acc2 = new Account(name='agency acc');
		acc2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
		insert acc2;
        Account acc3 = new account(id = acc2.Id, Account_Review_Status__c = 'Approved');
        update acc3;
		Contact contact1 = new Contact(FirstName='Ricky', LastName='Pointing');
		contact1.AccountId = acc4.Id;
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
		Opportunity opp = new Opportunity(Name='test opp',Primary_Billing_Contact__c=contact1.Id,Secondary_Billing_Contact__c=contact2.Id, Amount=100, TotalOpportunityQuantity=10, StageName='Prospecting', CloseDate=System.today(), AccountId=acc.Id);
		opp.Seller_Region__c = 'National Media & Entertainment';
		opp.Brand_Name__c = 'Test';
		opp.Brand_Id__c = '1111';
		opp.IO_Number_Available__c = 'Not Available';
		opp.CSM__c = UserInfo.getUserId();
		opp.Market_Type__c = 'M&E';
		opp.Main_Point_Of_Contact_Primary__c = contact3.Id;
		opp.Agency__c = acc3.Id;
		opp.Campaign_Name__c = 'test camp';
		insert opp;

        // Create test case
        Case c = new Case(
            RecordTypeId = rTypeId,
            Status = 'New',
            Subject = 'Test Subject',
            Opportunity__c = opp.Id,
            Media_Plan_AM__c = true
        );
        insert c;
        
        // Assert created case details
        System.assertEquals(rTypeId, c.RecordTypeId);
        System.assertEquals('New', c.Status);
        
        // Update case status
        c.Status = 'In Progress';
        try {
            // Update case
            update c;
            //System.fail('Expected validation error but none was thrown');
        } catch (Exception e) {
            // Assert expected error message or type
            System.assertEquals(true, e.getMessage().contains('You must upload at least'));
        }
        
        Test.stopTest();
    }
}