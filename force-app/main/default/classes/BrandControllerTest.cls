/**
	* @author Ramesh Kumar Gurusamy (CFG)
	* @date: 25-Jan-2024
	* @description: Test class for BrandController.
**/
@isTest
public class BrandControllerTest {
	static testMethod void testMethod1() {
		
		Account testAccount = new Account();
		testAccount.Name='Test Account';
		insert testAccount;
		
		Account testAccount2 = new Account();
		testAccount2.Name='TestAccount2';
		insert testAccount2;

		Test.StartTest(); 

		ApexPages.StandardController sc = new ApexPages.StandardController(testAccount);
		BrandController bController = new BrandController(sc);
		
		// Negative cases.
		try {
			bController.saveRecords();
			bController.removeRecord();
		} catch (Exception e) {
			System.debug('e***' + e);
		}
		
		bController.addRecord();
		List<Brand__c> brands = bController.brands;
		for(Brand__c brand: brands) {
			if(brand.Name == null) brand.Name = testAccount2.Id;
		}
		bController.saveRecords();
		System.currentPageReference().getParameters().put('index', '1');
		bController.removeRecord();
		Test.StopTest();
	}
}