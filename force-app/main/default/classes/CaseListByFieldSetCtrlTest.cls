@isTest(SeeAllData=true)
private class CaseListByFieldSetCtrlTest {

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
    static void testFetchCaseFieldSetData() {
        // Create a test opportunity
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Opportunity testOpp = [Select id from Opportunity Limit 1];//new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting',CloseDate=System.TODAY(), Seller_Region__c='General Market East', Market_Type__c='GM');

        // Create test cases related to the opportunity
        Case testCase1 = new Case(Subject = 'Test Case 1', Opportunity__c = testOpp.Id);
        Case testCase2 = new Case(Subject = 'Test Case 2', Opportunity__c = testOpp.Id);
        insert new List<Case>{testCase1, testCase2};

        // Call the fetchCaseFieldSetData method
        List<Case> resultCases = CaseListByFieldSetCtrl.fetchCaseFieldSetData(testOpp.Id);

        //Assert that the result contains the expected cases
        System.assertEquals(2, resultCases.size(), 'The number of cases returned should be 2');
    }

    @isTest
    static void testGetFieldSet() {
        // Call the getFieldSet method with valid parameters
        String result = CaseListByFieldSetCtrl.getFieldSet('Case', 'CaseListlwcFieldSet');

        // Assert that the result is not empty
        System.assertNotEquals('', result, 'The result should not be empty');
    }

    @isTest
    static void testGetFieldSetWithInvalidParameters() {
        // Call the getFieldSet method with invalid parameters
        String result = CaseListByFieldSetCtrl.getFieldSet('InvalidObject', 'InvalidFieldSet');
    }
}