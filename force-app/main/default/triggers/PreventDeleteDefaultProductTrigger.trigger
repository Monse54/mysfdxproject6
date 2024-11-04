trigger PreventDeleteDefaultProductTrigger on Opportunity_Billing_Ad_Server__c (before delete) {
    BillingAdserverHandler.beforeDelete(Trigger.old);
}