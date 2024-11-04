/**
	* @author Ramesh Kumar Gurusamy
	* @date: 3-Apr-2022
	* @description: Test class for AdvertiserController.
**/
@isTest
public class AdvertiserControllerTest {
	static testMethod void testMethod1() {
		
		Account testAccount = new Account();
		testAccount.Name='Test Account';
		insert testAccount;
		
		Account testAccount2 = new Account();
		testAccount2.Name='TestAccount2';
		insert testAccount2;

		Test.StartTest(); 

		ApexPages.StandardController sc = new ApexPages.StandardController(testAccount);
		AdvertiserController aController = new AdvertiserController(sc);
		
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