public class BillingAdserverHandler {
    public static void beforeDelete(List<Opportunity_Billing_Ad_Server__c> oldRecords) {
        for (Opportunity_Billing_Ad_Server__c record : oldRecords) {
          if (record.Product__c == 'Default') {record.addError('You cannot delete the Default Billing Ad Server'); } 
        }
    }
}