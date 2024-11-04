/**
	* @author Ramesh Kumar Gurusamy (CFG)
	* @date: 25-Jan-2024
	* @description: Add/update/remove Brand.
	* @testClass: Test class for BrandControllerTest.
**/
public class BrandController {
	public Account account;
	public List <Brand__c> brands {get;set;}
	
	public BrandController(ApexPages.StandardController controller) {
		account = (Account)controller.getRecord();
		brands = [SELECT Name 
                  FROM Brand__c 
                  WHERE Account__c=:account.Id];
	}
	
	public PageReference saveRecords() {
		System.debug('***saveRecords***');
		System.debug('brands***' + brands);
		try {
			upsert brands;
			return ApexPages.CurrentPage();
		} catch(Exception e) { System.debug('e***' + e); return null; }
	}
	
	public PageReference addRecord() {
		System.debug('***addRecord***');
		try {
			Brand__c agency = new Brand__c();
			agency.Account__c = account.Id;
			brands.add(agency);
			System.debug('agency***' + agency);
			return ApexPages.CurrentPage();
		} catch(Exception e) { System.debug('e***' + e); return null; }
	}
	
	public PageReference removeRecord() {
		System.debug('***removeRecord***');
		System.debug('***system.currentpagereference()***' + system.currentpagereference());
		System.debug('***system.currentpagereference().getparameters***' + system.currentpagereference().getparameters());
		Integer indexVal = Integer.valueof(system.currentpagereference().getparameters().get('index'));
		try {
			if(brands[indexVal - 1].Id != null) { delete brands[indexVal - 1]; }
			brands.remove(indexVal - 1);
			return ApexPages.CurrentPage();
		} catch(Exception e) { System.debug('e***' + e); return null; }
	}
}