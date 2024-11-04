trigger AsanaTaskCreation on Feasibilty__c(after insert) {
  List<Id> oppIds = new List<Id>();
  for (Feasibilty__c f : Trigger.new) {
    oppIds.add(f.Opportunity__c);
  }

  Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>(
    [
      SELECT id, name, RecordType.Name, Pricebook2.Name
      FROM Opportunity
      WHERE id IN :oppIds
    ]
  );

  for (Feasibilty__c f : Trigger.new) {
    // Check if opportunity is managed service then industry cannot be none
    Opportunity opp = oppMap.get(f.Opportunity__c);
    System.debug('Feasibilty ' + opp);
    if (
      opp.RecordType.Name == Constants.RECORD_TYPE_MANAGED &&
      f.Industry_Type__c == null
    ) {
      f.Industry_Type__c.addError('Please select an Industry type.');
      continue;
    }
    Asana.createFeasibilityAsanaTask(f.Id);
  }
}