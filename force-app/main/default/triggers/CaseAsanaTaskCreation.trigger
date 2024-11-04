trigger CaseAsanaTaskCreation on Case(after insert) {
  for (Case c : Trigger.new) {
    Asana.createCaseAsanaTask(c.Id);
  }
}