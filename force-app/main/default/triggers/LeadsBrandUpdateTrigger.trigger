trigger LeadsBrandUpdateTrigger on Account(after update) {
  for (Account acc : Trigger.New) {
    if (
      Trigger.isInsert ||
      (Trigger.isUpdate &&
      (Trigger.oldMap.get(acc.Id).Brand_Id__c != acc.Brand_Id__c ||
      Trigger.oldMap.get(acc.Id).Competition_Brand_Ids__c !=
      acc.Competition_Brand_Ids__c))
    ) {
      if (Trigger.isUpdate) {
        System.debug(
          'OLD Brand_Id__c: ' + Trigger.oldMap.get(acc.Id).Brand_Id__c
        );
        System.debug('NEW Brand_Id__c: ' + acc.Brand_Id__c);
        System.debug(
          'OLD Competition_Brand_Ids__c: ' +
          Trigger.oldMap.get(acc.Id).Competition_Brand_Ids__c
        );
        System.debug(
          'NEW Competition_Brand_Ids__c: ' + acc.Competition_Brand_Ids__c
        );
      }
      LeadsNurturingController.updateLeadsReport(acc);
    }
  }
}