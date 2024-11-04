/**
 * Created by cxu on 7/02/2017.
 */

public with sharing class FastOpportunityController {
  @AuraEnabled
  public static List<Pricebook2> getPricebooks() {
    List<string> pricebookFields = new List<string>{ 'Id', 'Name', 'IsActive' };
    if (checkSObjectAccessibleFSL('Pricebook2', pricebookFields)) {
      List<Pricebook2> pricebooks = [
        SELECT Id, Name
        FROM Pricebook2
        WHERE IsActive = TRUE
      ];
      return pricebooks;
    }
    return null;
  }

  @AuraEnabled
  public static List<PricebookEntry> getPricebookEntries(string pricebookId) {
    List<string> pricebookEntryFields = new List<string>{
      'Id',
      'Name',
      'UnitPrice',
      'IsActive'
    };
    List<string> productFields = new List<string>{ 'Name', 'ProductCode' };
    if (
      checkSObjectAccessibleFSL('PricebookEntry', pricebookEntryFields) &&
      checkSObjectAccessibleFSL('Product2', productFields)
    ) {
      return [
        SELECT Id, Name, Product2.Name, Product2.ProductCode, UnitPrice
        FROM PricebookEntry
        WHERE Pricebook2Id = :pricebookId AND IsActive = TRUE
      ];
    }
    return null;
  }

  @AuraEnabled
  public static Opportunity getOpportunity(string recordId) {
    List<string> opportunityFields = new List<string>{
      'Id',
      'Name',
      'Pricebook2Id'
    };
    List<string> opportunityLineItemFields = new List<string>{
      'Name',
      'Quantity',
      'UnitPrice',
      'ProductCode',
      'PricebookEntryId',
      'OpportunityId'
    };
    List<string> productFields = new List<string>{ 'Name' };
    if (
      checkSObjectAccessibleFSL('Opportunity', opportunityFields) &&
      checkSObjectAccessibleFSL(
        'OpportunityLineItem',
        opportunityLineItemFields
      ) &&
      checkSObjectAccessibleFSL('Product2', productFields)
    ) {
      List<Opportunity> opportunities = [
        SELECT
          Id,
          Name,
          Pricebook2Id,
          (
            SELECT
              Id,
              Name,
              Quantity,
              UnitPrice,
              ProductCode,
              PricebookEntry.Product2.Name,
              PricebookEntryId
            FROM OpportunityLineItems
            ORDER BY CreatedDate
          )
        FROM Opportunity
        WHERE Id = :recordId
      ];
      if (opportunities.size() > 0) {
        return opportunities[0];
      }
    }
    return null;
  }

  @AuraEnabled
  public static string updateOpportunity(
    Opportunity opportunity,
    string pricebookId
  ) {
    try {
      List<string> opportunityFields = new List<string>{ 'Pricebook2Id' };
      if (checkSObjectUpdatableFSL('Opportunity', opportunityFields)) {
        opportunity.Pricebook2Id = pricebookId;
        system.debug(opportunity);
        update opportunity;
        return '';
      }
      return 'You do not have permission to update Pricebook on opportunity. Contact your salesforce administrator.';
    } catch (Exception e) {
      return e.getMessage();
    }
  }

  @AuraEnabled
  public static List<OpportunityLineItem> updateLineItems(
    List<OpportunityLineItem> lineItems,
    string opportunityId
  ) {
    List<OpportunityLineItem> toBeInserted = new List<OpportunityLineItem>();
    List<OpportunityLineItem> toBeUpdated = new List<OpportunityLineItem>();

    Set<Id> newLineItemIds = new Set<Id>();

    for (OpportunityLineItem item : lineItems) {
      if (item.Id != null) {
        toBeUpdated.add(item);
        newLineItemIds.add(item.Id);
      } else {
        toBeInserted.add(item);
      }
    }
    List<OpportunityLineItem> toBeDeleted = new List<OpportunityLineItem>();
    List<string> opportunityLineItemFields = new List<string>{
      'Id',
      'OpportunityId'
    };
    List<string> updateFields = new List<string>{ 'Quantity', 'UnitPrice' };
    if (
      checkSObjectAccessibleFSL(
        'OpportunityLineItem',
        opportunityLineItemFields
      )
    ) {
      toBeDeleted = [
        SELECT Id
        FROM OpportunityLineItem
        WHERE OpportunityId = :opportunityId AND Id NOT IN :newLineItemIds
      ];
    }

    try {
      if (checkSObjectUpdatableFSL('OpportunityLineItem', updateFields)) {
        insert toBeInserted;
        update toBeUpdated;
        delete toBeDeleted;

        List<OpportunityLineItem> newLineItems = new List<OpportunityLineItem>();

        newLineItems.addAll(toBeInserted);
        newLineItems.addAll(toBeUpdated);
        newLineItems.sort();
        return newLineItems;
      }
    } catch (Exception e) {
      system.debug(e.getMessage());
    }
    return null;
  }

  private static boolean checkSObjectAccessibleFSL(
    string SObjectName,
    List<string> fields
  ) {
    SObjectType sObjectType = Schema.getGlobalDescribe().get(SObjectName);
    Map<String, Schema.SObjectField> fieldMap = sObjectType.getDescribe()
      .fields.getMap();

    for (String fieldToCheck : fields) {
      if (!fieldMap.get(fieldToCheck).getDescribe().isAccessible()) {
        return false;
      }
    }
    return true;
  }

  private static boolean checkSObjectUpdatableFSL(
    string SObjectName,
    List<string> fields
  ) {
    SObjectType sObjectType = Schema.getGlobalDescribe().get(SObjectName);
    Map<String, Schema.SObjectField> fieldMap = sObjectType.getDescribe()
      .fields.getMap();

    for (String fieldToCheck : fields) {
      if (!fieldMap.get(fieldToCheck).getDescribe().isUpdateable()) {
        return false;
      }
    }
    return true;
  }
}