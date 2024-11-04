/**
	* @author Ramesh Kumar Gurusamy
	* @date: 28-Dec2023
	* @description: Add/update/remove Agency.
	* @testClass: Test class for AgencyControllerTest.
**/
public class AgencyController {
	public Account account;
	public List <Agency__c> agencies {get;set;}
	
	public AgencyController(ApexPages.StandardController controller) {
		account = (Account)controller.getRecord();
		agencies = [SELECT Name, Agency__c 
					FROM Agency__c 
					WHERE Account__c=:account.Id];
	}
	
	public PageReference saveRecords() {
		System.debug('***saveRecords***');
		System.debug('agencies***' + agencies);
		try {
			upsert agencies;
			return ApexPages.CurrentPage();
		} catch(Exception e) { System.debug('e***' + e); return null; }
	}
	
	public PageReference addRecord() {
		System.debug('***addRecord***');
		try {
			Agency__c agency = new Agency__c();
			agency.Account__c = account.Id;
			agencies.add(agency);
			System.debug('agency***' + agency);
			return ApexPages.CurrentPage();
		} catch(Exception e) { System.debug('e***' + e); return null; }
	}
	
	public PageReference removeRecord() {
		System.debug('***removeRecord***');
		System.debug('***system.currentPageReference()***' + system.currentPageReference());
		System.debug('***system.currentPageReference().getParameters***' + system.currentPageReference().getParameters());
		Integer indexVal = Integer.valueof(System.currentPageReference().getParameters().get('index'));
		try {
			if(agencies[indexVal - 1].Id != null) { delete agencies[indexVal - 1]; }
			agencies.remove(indexVal - 1);
			return ApexPages.CurrentPage();
		} catch(Exception e) { System.debug('e***' + e); return null; }
	}
}