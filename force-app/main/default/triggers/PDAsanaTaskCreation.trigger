trigger PDAsanaTaskCreation on Programmatic_Deal_Request__c(after insert) {
  for (Programmatic_Deal_Request__c p : Trigger.New) {
    Asana.createProgrammaticDealAsanaTask(p.Id);
  }
}