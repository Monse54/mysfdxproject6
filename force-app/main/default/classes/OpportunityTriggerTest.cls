/* 
	@author		 : Ramesh Kumar Gurusamy
	@team		   : CFG
	@createdDate	: 23-Dec-2023
	@description	: Test class for OpportunityTrigger.
*/
@isTest
public class OpportunityTriggerTest {
	static testMethod void testCreateOpp() {
        Date flightStartDate = Date.newInstance(2021, 5, 12);
        Date flightEndDate = Date.newInstance(2021, 8, 20);
        Date bookingDate = Date.newInstance(2021, 3, 12);
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
		Opportunity opp = new Opportunity(Name='test opp',Primary_Billing_Contact__c=contact1.Id,Secondary_Billing_Contact__c=contact2.Id, Amount=100, TotalOpportunityQuantity=10, StageName='Prospecting', CloseDate=System.today(), AccountId=acc.Id);
		opp.Seller_Region__c = 'National Media & Entertainment';
		opp.Brand_Name__c = 'Test';
		opp.Brand_Id__c = '1111';
        opp.Dropbox_URL__c = 'http://nnnn';
		opp.IO_Number_Available__c = 'Not Available';
		opp.CSM__c = UserInfo.getUserId();
		opp.Market_Type__c = 'M&E';
		opp.Main_Point_Of_Contact_Primary__c = contact3.Id;
		opp.Agency__c = acc2.Id;
		opp.Campaign_Name__c = 'test camp';
        opp.Flight_Start_Date__c = flightStartDate;
      	opp.Flight_End_Date__c = flightEndDate;
		insert opp;
		opp.Secondary_Billing_Contact__c = contact3.Id;
		opp.Campaign_Name__c = 'test camp2';
		update opp;
		opp.Primary_Billing_Contact__c = contact2.Id;
		opp.Campaign_Name__c = '';
		update opp;
		opp.Secondary_Billing_Contact__c = contact1.Id;
		update opp;
		opp.Main_Point_Of_Contact_Primary__c = contact3.Id;
		update opp;
		//opp.Main_Point_Of_Contact_Primary__c = contact2.Id;
		//update opp;
		Test.startTest();
		opp.Primary_Billing_Contact__c = null;
		opp.Secondary_Billing_Contact__c = null;
		opp.Main_Point_Of_Contact_Primary__c = null;
		opp.Agency__c = acc2.Id;
		update opp;
		opp.Primary_Billing_Contact__c = contact1.Id;
		opp.Secondary_Billing_Contact__c = contact2.Id;
		//opp.Main_Point_Of_Contact_Primary__c = contact3.Id;
		//opp.Agency__c = null;
		//opp.Client_Direct__c = TRUE;
		update opp;
        List<Opportunity> lstopp = new List<Opportunity>();
		Opportunity opp2 = new Opportunity(Name='test opp2', Amount=100, TotalOpportunityQuantity=10, StageName='Prospecting', CloseDate=System.today(), AccountId=acc.Id);
		opp2.Seller_Region__c = 'National Media & Entertainment';
		opp2.Brand_Name__c = 'Test';
		opp2.Brand_Id__c = '1111';
        opp2.Dropbox_URL__c = 'http://nnnn';
		opp2.IO_Number_Available__c = 'Not Available';
		opp2.CSM__c = UserInfo.getUserId();
		opp2.Market_Type__c = 'M&E';
		opp2.Agency__c = acc2.Id;
        opp2.Flight_Start_Date__c = flightStartDate;
      	opp2.Flight_End_Date__c = flightEndDate;
		insert opp2;
		opp2.Is_Name_Manual_Update__c = FALSE;
        opp2.StageName='Proposal submitted';
        opp2.Campaign_Name__c = 'test';
        opp2.Primary_KPI__c = 'In Geo';
        opp2.Secondary_KPI__c = 'Fraud';
        opp2.X3P_Verification_Partner__c = 'IAS : Brand Safety';
		//opp2.Agency__c = null;
		//opp2.Client_Direct__c = TRUE;
		update opp2;
        lstopp.add(opp2);
        OpportunityTriggerHandler.deleteAgency(lstopp);
        list<Opportunity_Billing_Ad_Server__c> oldRecords = new list<Opportunity_Billing_Ad_Server__c>();
          Opportunity_Billing_Ad_Server__c  objBAdserver = new Opportunity_Billing_Ad_Server__c();
          objBAdserver.Billing_Ad_Server__c = 'Innovid';
          objBAdserver.Product__c = 'Cross Device Display' ; 
          objBAdserver.Opportunity__c = opp.Id;
          insert objBAdserver;
      	oldRecords.add(objBAdserver);
     // BillingAdserverHandler.beforeDelete(oldRecords);
        try{
            delete objBAdserver;
        	delete opp2;
        }catch(Exception e ){
           system.debug('Getting Error: '+e );
        }
        
		Test.stopTest();
	}
    
    static testMethod void testCreateParentOpp() {
    Date flightStartDate = Date.newInstance(2021, 5, 12);
    Date flightEndDate = Date.newInstance(2021, 8, 20);
    Date bookingDate = Date.newInstance(2021, 3, 12);
    Account acc = new Account(name = 'test acc');
    insert acc;
    acc.Account_Review_Status__c = 'Approved';
    update acc;
    Account acc2 = new Account(name = 'agency acc');
    acc2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('Agency')
      .getRecordTypeId();
    insert acc2;
    acc2.Account_Review_Status__c = 'Approved';
    update acc2;
    Contact contact1 = new Contact(FirstName = 'Ricky', LastName = 'Pointing');
    contact1.AccountId = acc.Id;
    contact1.Is_Billing_Contact__c = true;
    contact1.Email = 'test.user1@example.com';
    insert contact1;
    Contact contact2 = new Contact(FirstName = 'Bark', LastName = 'Putin');
    contact2.Email = 'test.user2@example.com';
    contact2.AccountId = acc.Id;
    insert contact2;
    Contact contact3 = new Contact(FirstName = 'Test', LastName = 'Data');
    contact3.Email = 'test.user3@example.com';
    contact3.AccountId = acc.Id;
    insert contact3;
    String parentOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Parent Opportunity').getRecordTypeId();
    Opportunity opp = new Opportunity(
      RecordTypeId=parentOppRecordTypeId,
      Name = 'test opp',
      Dropbox_URL__c = 'http://nnnn',
      Primary_Billing_Contact__c = contact1.Id,
      Secondary_Billing_Contact__c = contact2.Id,
      Amount = 100,
      TotalOpportunityQuantity = 10,
      StageName = 'Prospecting',
      CloseDate = System.today(),
      AccountId = acc.Id
    );
    opp.Seller_Region__c = 'National Media & Entertainment';
    opp.Brand_Name__c = 'Test';
    opp.Brand_Id__c = '1111';
    opp.IO_Number_Available__c = 'Not Available';
    opp.CSM__c = UserInfo.getUserId();
    opp.Market_Type__c = 'M&E';
    opp.Main_Point_Of_Contact_Primary__c = contact3.Id;
    opp.Agency__c = acc2.Id;
    opp.Campaign_Name__c = 'test camp';
    opp.Flight_Start_Date__c = flightStartDate;
    opp.Flight_End_Date__c = flightEndDate;
    insert opp;
    opp.Secondary_Billing_Contact__c = contact3.Id;
    opp.Campaign_Name__c = 'test camp2';
    update opp;
    opp.Primary_Billing_Contact__c = contact2.Id;
    opp.Campaign_Name__c = '';
    update opp;
    opp.Secondary_Billing_Contact__c = contact1.Id;
    update opp;
    opp.Main_Point_Of_Contact_Primary__c = contact3.Id;
    update opp;
    //opp.Main_Point_Of_Contact_Primary__c = contact2.Id;
    //update opp;
    Test.startTest();
    opp.Primary_Billing_Contact__c = null;
    opp.Secondary_Billing_Contact__c = null;
    opp.Main_Point_Of_Contact_Primary__c = null;
    opp.Agency__c = acc2.Id;
    update opp;
    opp.Primary_Billing_Contact__c = contact1.Id;
    opp.Secondary_Billing_Contact__c = contact2.Id;
    //opp.Main_Point_Of_Contact_Primary__c = contact3.Id;
    //opp.Agency__c = null;
    //opp.Client_Direct__c = TRUE;
    update opp;
    List<Opportunity> lstopp = new List<Opportunity>();
    Opportunity opp2 = new Opportunity(
      Name = 'test opp2',
      Amount = 100,
      Dropbox_URL__c = 'http://nnnn',
      TotalOpportunityQuantity = 10,
      StageName = 'Prospecting',
      CloseDate = System.today(),
      AccountId = acc.Id
    );
    opp2.Seller_Region__c = 'National Media & Entertainment';
    opp2.Brand_Name__c = 'Test';
    opp2.Brand_Id__c = '1111';
    opp2.IO_Number_Available__c = 'Not Available';
    opp2.CSM__c = UserInfo.getUserId();
    opp2.Market_Type__c = 'M&E';
    opp2.Agency__c = acc2.Id;
    opp2.Flight_Start_Date__c = flightStartDate;
    opp2.Flight_End_Date__c = flightEndDate;
    insert opp2;
    opp2.Is_Name_Manual_Update__c = false;
    opp2.StageName = 'Proposal submitted';
    opp2.Campaign_Name__c = 'test';
    opp2.Primary_KPI__c = 'In Geo';
    opp2.Secondary_KPI__c = 'Fraud';
    opp2.X3P_Verification_Partner__c = 'IAS : Brand Safety';
    //opp2.Agency__c = null;
    //opp2.Client_Direct__c = TRUE;
    update opp2;
    lstopp.add(opp2);
    OpportunityTriggerHandler.deleteAgency(lstopp);
    list<Opportunity_Billing_Ad_Server__c> oldRecords = new List<Opportunity_Billing_Ad_Server__c>();
    Opportunity_Billing_Ad_Server__c objBAdserver = new Opportunity_Billing_Ad_Server__c();
    objBAdserver.Billing_Ad_Server__c = 'Brightroll';
    objBAdserver.Product__c = 'Cross Device Video';
    objBAdserver.Opportunity__c = opp.Id;
    insert objBAdserver;
    oldRecords.add(objBAdserver);
    // BillingAdserverHandler.beforeDelete(oldRecords);
    try{
            delete objBAdserver;
    		delete opp2;
        }catch(Exception e ){
           system.debug('Getting Error: '+e );
        }
    
    Test.stopTest();
  }
}