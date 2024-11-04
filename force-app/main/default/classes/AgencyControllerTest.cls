/**
	* @author Ramesh Kumar Gurusamy
	* @date: 28-Dec-2023
	* @description: Test class for AgencyController.
**/
@isTest
public class AgencyControllerTest {
	static testMethod void testMethod1() {
		
		Account testAccount = new Account();
		testAccount.Name='Test Account';
		insert testAccount;
		
		Account testAccount2 = new Account();
		testAccount2.Name='TestAccount2';
		insert testAccount2;

		Test.StartTest(); 

		ApexPages.StandardController sc = new ApexPages.StandardController(testAccount);
		AgencyController aController = new AgencyController(sc);
		
		// Negative cases.
		try {
			aController.saveRecords();
			aController.removeRecord();
		} catch (Exception e) {
			System.debug('e***' + e);
		}
		
		aController.addRecord();
		List<Agency__c> agencies = aController.agencies;
		for(Agency__c agency: agencies) {
			if(agency.Agency__c == null) agency.Agency__c = testAccount2.Id;
		}
		aController.saveRecords();
		System.currentPageReference().getParameters().put('index', '1');
		aController.removeRecord();
		Test.StopTest();
	}
}