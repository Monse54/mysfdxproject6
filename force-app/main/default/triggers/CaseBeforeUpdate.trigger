trigger CaseBeforeUpdate on Case (before update) {
    for (Case newCase : Trigger.new) {
        Case oldCase = Trigger.oldMap.get(newCase.Id);
        
        if (newCase.Status != 'New' && newCase.Record_Type_Name__c == 'RFI') {
            List<ContentDocumentLink> links = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :newCase.Id];
            
            if (links.size() < 1) {
                newCase.addError('You must upload at least one file before moving the case status to "RFI Support Requested" or further');
            }
        }
    }
}