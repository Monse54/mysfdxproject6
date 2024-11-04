/**
	* @author Ramesh Kumar Gurusamy
	* @date: 28-Dec-2023
	* @description: Add/update/remove Advertiser.
	* @testClass: Test class for AdvertiserControllerTest.
**/
public class AdvertiserController {
	public Account account;
	public List <Agency__c> agencies {get;set;}
	
	public AdvertiserController(ApexPages.StandardController controller) {
		account = (Account)controller.getRecord();
		agencies = [SELECT Name, Account__c 
					FROM Agency__c 
					WHERE Agency__c=:account.Id];
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
			agency.Agency__c = account.Id;
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
	}}