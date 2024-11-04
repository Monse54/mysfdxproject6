trigger NewOpportunityTrigger on Opportunity(before insert) {
  Opportunity opp;
  // In a before insert context, trigger context variables
  // are not yet committed to the database and hence cannot be queried.
  // In this context, we must query the related records directly,
  // using collections like Set<Id> and Map<Id, sObject>
  /*Set<Id> accountIds = new Set<Id>();
  for (Opportunity opp : Trigger.new) {
    if (opp.AccountId != null) {
      accountIds.add(opp.AccountId);
    }
    if (opp.Agency__c != null) {
      accountIds.add(opp.Agency__c);
    }
  }

  Map<Id, Account> accountById = new Map<Id, Account>(
    [SELECT Id, Name FROM Account WHERE Id IN :accountIds]
  );

  // Action
  for (Opportunity opp : Trigger.New) {
    if (opp.AccountId == null) {
      continue;
    }

    String accountName = accountById.get(opp.AccountId).Name;
    String agencyName = '';
    String campaignName = opp.Name;
    String opportunityName = '';*/

    /*
     * All of our opps will have the same naming convention
     * (Advertiser/Brand - Agency - Campaign Name).
     * Advertiser/Brand and Agency will pull through from the account/opp,
     * and campaign name should be the only part that sales can edit
     

    if (!String.isBlank(accountName)) {
      opportunityName += accountName + ' - ';
    }

    if (
      opp.Agency__c != null &&
      !String.isBlank(accountById.get(opp.Agency__c).Name)
    ) {
      agencyName = accountById.get(opp.Agency__c).Name;
      opportunityName += agencyName + ' - ';
    }

    opportunityName += campaignName;

    // Update the Opportunity name
    opp.Name = opportunityName;

    System.debug(opportunityName);
  }*/
}