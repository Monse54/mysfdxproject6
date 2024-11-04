@isTest
private class PGBillingLandingProcessorBatchTest {
    
    @isTest
    static void setupTestData() {
        Account demandPartner = new Account(
            Name = 'Test Demand Partner',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Demand Partner').getRecordTypeId(),
            CurrencyIsoCode = 'USD',
            NetSuite_Internal_ID__c = 'NS123',
            Net_Term__c = '30',
            Type = 'Demand Partner',
            Account_Review_Status__c = 'Approved'
        );
        insert demandPartner;
        list<Programmatic_Billing_Landing__c> lstpbl = new list<Programmatic_Billing_Landing__c>();
        Programmatic_Billing_Landing__c billingRecord1 = new Programmatic_Billing_Landing__c(
            Status__c = 'To be processed',
            Demand_Partner__c = 'Test Demand Partner',
            Currency_Code__c = 'USD',
            Net_term__c = '30',
            Netsuite_Customer__c = 'NS123'
        );
        lstpbl.add(billingRecord1);
        Programmatic_Billing_Landing__c billingRecord2 = new Programmatic_Billing_Landing__c(
            Status__c = 'To be processed',
            Demand_Partner__c = 'New Demand Partner',
            Currency_Code__c = 'EUR',
            Net_term__c = '15',
            Netsuite_Customer__c = 'NS456'
        );
        lstpbl.add(billingRecord2);
        
        insert lstpbl;
        
        Test.startTest();
        
        PGBillingLandingProcessorBatchScheduler abs= new PGBillingLandingProcessorBatchScheduler();
        String cronExpr = '0 0 0 15 3 ? 2025';
        String jobId = System.schedule('myJobTestJobName', cronExpr, abs);
        abs.execute(null);
        
        Test.stopTest();
    }
}