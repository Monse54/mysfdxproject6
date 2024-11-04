public with sharing class TestHelper {
  public static void setupTests() {
    // Insert custom settings
    Trigger_Settings__c ts = new Trigger_Settings__c();
    ts.Account_Trigger_Active__c = true;
    ts.Opp_Seller_Trigger_Active__c = true;
    ts.Opp_Product_Trigger_Active__c = true;
    ts.Opportunity_Triggers_Active__c = true;
    insert ts;
    // Insert env variables
    env__c env = new env__c();
    env.pmp_deal_followers__c = '12345';
    env.am_update_api__c = 'http://dummy.abc.xyz';
    insert env;
  }
}