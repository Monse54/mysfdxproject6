global class PGBillingLandingProcessorBatch implements Database.Batchable<sObject> {

    private list<Programmatic_Billing_Landing__c> lstpgbillupd = new list<Programmatic_Billing_Landing__c>();
    private list<Programmatic_Billing_Landing__c> lstpgbillfinal = new list<Programmatic_Billing_Landing__c>();
    private map<string,Account> accinsmap = new map<string,Account>();
    private set<Id> success = new set<Id>();
    private set<Id> failed = new set<Id>();
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String strstatus = 'To be processed';
        return Database.getQueryLocator([
            SELECT Id,Status__c,Demand_Partner__c,Currency_Code__c,Net_term__c,Netsuite_Customer__c,Status_Message__c,Account__c
            FROM Programmatic_Billing_Landing__c 
            WHERE Status__c = :strstatus
            //WHERE Id='a0qVC000002NmncYAC'
        ]);
    }

    global void execute(Database.BatchableContext BC, List<Programmatic_Billing_Landing__c> scope) {
        Set<String> demandpartner = new Set<String>();
       // Id RecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Demand_Partner').getRecordTypeId();
        Id RecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Demand Partner').getRecordTypeId();
        Map<String,Account> accmap = new Map<String,Account>();
        for(Programmatic_Billing_Landing__c sc : scope) {
            if(!demandpartner.contains(sc.Demand_Partner__c))
                demandpartner.add(sc.Demand_Partner__c);
        }
        //Removed record type filter in query.
        List<Account> lstacc = [Select id,Name from Account where Name = :demandpartner];
        if(!lstacc.isEmpty()) {
            for(Account Acc : lstacc) {
                accmap.put(Acc.Name,Acc);
            }
        }
        
        for(Programmatic_Billing_Landing__c sc : scope) {
            if(accmap.containsKey(sc.Demand_Partner__c)){
                sc.Account__c = accmap.get(sc.Demand_Partner__c).Id;
                lstpgbillupd.add(sc);
            } else if (!accinsmap.containsKey(sc.Demand_Partner__c)){
                Account Acctemp = new Account();
                Acctemp.CurrencyIsoCode = sc.Currency_Code__c;
                Acctemp.Name = sc.Demand_Partner__c;
                Acctemp.Netsuite_Account_Name__c = sc.Netsuite_Customer__c;
                Acctemp.Net_Term__c = sc.Net_term__c;
                Acctemp.RecordTypeId = RecordType;
                Acctemp.Type = 'Demand Partner';
                Acctemp.Account_Review_Status__c = 'Approved';
                accinsmap.put(sc.Demand_Partner__c,Acctemp);
            }       
        }
        
        Insert accinsmap.values();       
        for(Programmatic_Billing_Landing__c sc : scope){
            if(accinsmap.containsKey(sc.Demand_Partner__c)){
                sc.Account__c=accinsmap.get(sc.Demand_Partner__c).Id;
                lstpgbillupd.add(sc);
            }
        }
        Database.SaveResult[] srList = Database.update(lstpgbillupd, false);
        for (Database.SaveResult sr : srList){
            if (sr.isSuccess()){
                Programmatic_Billing_Landing__c temp = new Programmatic_Billing_Landing__c();
                temp.Id = sr.getId();
                temp.Status__c = 'Success';
                lstpgbillfinal.add(temp);
            }else{
                Programmatic_Billing_Landing__c temp = new Programmatic_Billing_Landing__c();
                temp.Id = sr.getId();
                temp.Status__c = 'Failed';
                String error;
                for (Database.Error err : sr.getErrors()){
                    error = String.valueOf(err.getMessage());
                }
                temp.Status_Message__c = error;
                lstpgbillfinal.add(temp);
            }
        }
        Update lstpgbillfinal;
    }

    global void finish(Database.BatchableContext BC) {
        // Optional: Add any post-processing logic here
    }

}