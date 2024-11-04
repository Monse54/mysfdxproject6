trigger AccountBeforeUpdateTrigger on Account(before insert, before update) {
  System.debug('Account trigger called');
  Integer i = 0;
  // Commented as part of Run duplicate report task: https://app.asana.com/0/1206340290454999/1206283722284751
  // Find Duplicates take atmost 50 length arrays
  /*List<DataCloud.FindDuplicatesResult> duplResults = new List<Datacloud.FindDuplicatesResult>();
  while (i < Trigger.new.size()) {
    List<Account> slice = new List<Account>();
    for (Integer j = 0; j < 50 && i < Trigger.new.size(); j++) {
      slice.add(Trigger.new.get(i));
      i++;
    }
    duplResults.addAll(Datacloud.FindDuplicates.findDuplicates(slice));
  }

  // Create a map from acc Name -> acc to prevent creation of accounts with exact same name
  Set<String> names = new Set<String>();
  for (Account acc : Trigger.new) {
    names.add(acc.Name);
    System.debug('Printing acc.name' + acc.Name);
  }

  List<Account> lstAccount = [
    SELECT name, id
    FROM account
    WHERE name IN :names
  ];

  Map<String, Account> mapNameWiseAccount = new Map<String, Account>();
  for (Account acc : lstAccount) {
    mapNameWiseAccount.put(acc.name, acc);
  }

  // Check if trigger should be active
  Trigger_Settings__c ts = Trigger_Settings__c.getOrgDefaults();
  Boolean isActive = ts.Account_Trigger_Active__c;

  i = 0;
  for (Account acc : Trigger.new) {
    List<Datacloud.DuplicateResult> dr = duplResults[i].getDuplicateResults();
    i += 1;
    // Accounts with exact same name are not allowed
    if (
      isActive &&
      Trigger.isInsert &&
      mapNameWiseAccount.containsKey(acc.Name)
    ) {
      acc.Name.addError(
        'Account with name "' +
        acc.Name +
        '" already exists. Please use the existing account or select a different name.'
      );
    }
    // Duplicate Note is mandatory if there are duplicates for the account
    if (
      isActive &&
      dr.size() > 0 &&
      dr[0].getErrorMessage() != null &&
      (acc.Duplicate_Note__c == null ||
      acc.Duplicate_Note__c == '')
    ) {
      acc.Duplicate_Note__c.addError(
        'An Account with Name similar to "' +
        acc.Name +
        '" exists. If you still want to create this account please mention the reason for similar name.'
      );
    }
  }*/
}