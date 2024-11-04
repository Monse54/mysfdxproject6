@isTest
private class EmailSenderTest {
    
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
    
    
@testSetup
    static void setupTestData() {
        User currentUser = [SELECT Id,Email FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

        // Create a Queue
        Group queue = new Group(Type='Queue', Name='Test Queue');
        insert queue;
        
        GroupMember groupMember = new GroupMember(GroupID = queue.Id, UserOrGroupId = currentUser.Id);
        insert groupMember;
        
    }

@isTest
static void testSendEmailWithHTMLBody() {
    try {
        Test.startTest();
		list<group> queue = [select id,type from group where type = 'Queue'];
        system.debug('Queue information '+queue );
        // Create a Case
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Schema.RecordTypeInfo rfiRecordTypeInfo = Case.SObjectType.getDescribe().getRecordTypeInfosByName().get('RFI');
        Id rfiRecordTypeId = rfiRecordTypeInfo.getRecordTypeId();
        Case c = new Case();
        c.RecordTypeId = rfiRecordTypeId;
        c.Status = 'New';
        c.Subject = 'Test Subject';
        c.OwnerId = queue[0].Id;
        insert c;


        Schema.RecordTypeInfo rfpRecordTypeInfo = Case.SObjectType.getDescribe().getRecordTypeInfosByName().get('RFP');
        Id rfpRecordTypeId = rfpRecordTypeInfo.getRecordTypeId();

        Case c2 = new Case();
        c2.RecordTypeId = rfpRecordTypeId;
        c2.Status = 'New';
        c2.Subject = 'Test Subject';
        c2.OwnerId = queue[0].Id;
        c2.Deck_350k_AM__c = True;
        insert c2;
        system.debug(c+'case owner informaiton');
        system.debug(queue[0].Id+'first queue id');
        List<EmailSender.EmailParameters> emailParamsList = new List<EmailSender.EmailParameters>();
        EmailSender.EmailParameters emailParams = new EmailSender.EmailParameters();
        emailParams.recordTypeName = 'Test Record Type';
        emailParams.caseNumber = '000001';
        emailParams.htmlBody = '<html><body>This is a test email body.</body></html>';
        emailParams.caseId = c.Id;
        emailParamsList.add(emailParams);

        EmailSender.EmailParameters emailParams2 = new EmailSender.EmailParameters();
        emailParams2.recordTypeName = 'Test Record Type';
        emailParams2.caseNumber = '000001';
        emailParams2.htmlBody = '<html><body>This is a test email body.</body></html>';
        emailParams2.caseId = c2.Id;
        emailParamsList.add(emailParams2);


        // Call the method under test
        EmailSender.sendEmailWithHTMLBody(emailParamsList);

        Test.stopTest();
    } catch (Exception e) {
        System.debug('An unexpected exception occurred: ' + e.getMessage());
    }
}

}