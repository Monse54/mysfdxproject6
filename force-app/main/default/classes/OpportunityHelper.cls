public with sharing class OpportunityHelper {
  public static String convertRecordTypeToPricebook(String recordType) {
    if (recordType == Constants.RECORD_TYPE_MANAGED) {
      return Constants.PRICEBOOK_MANAGED;
    }
    if (recordType == Constants.RECORD_TYPE_SelfService) {
      return Constants.PRICEBOOK_SELF;
    }
    if (recordType == Constants.RECORD_TYPE_CORPORATE) {
      return Constants.PRICEBOOK_CORPORATE;
    }
    throw new IllegalArgumentException('Unknown Record Type ' + recordType);
  }
}