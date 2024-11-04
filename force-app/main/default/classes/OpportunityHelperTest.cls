@isTest
public class OpportunityHelperTest {
  @isTest
  static void convertRecordTypeToPricebookTest() {
    String pName1 = OpportunityHelper.convertRecordTypeToPricebook(
      Constants.RECORD_TYPE_MANAGED
    );
    String pName2 = OpportunityHelper.convertRecordTypeToPricebook(
      Constants.RECORD_TYPE_SelfService
    );
    String pName3 = OpportunityHelper.convertRecordTypeToPricebook(
      Constants.RECORD_TYPE_CORPORATE
    ); 
    System.assert(
      pName1.equals(Constants.PRICEBOOK_MANAGED),
      'Record Type and Pricebook Name mismatch for Managed Service'
    );
    System.assert(
      pName2.equals(Constants.PRICEBOOK_SELF),
      'Record Type and Pricebook Name mismatch for Self Service'
    );
    System.assert(
      pName3.equals(Constants.PRICEBOOK_CORPORATE),
      'Record Type and Pricebook Name mismatch for Insights'
    );

    Boolean exceptionThrown = false;
    try {
      String pName4 = OpportunityHelper.convertRecordTypeToPricebook('Test');
    } catch (Exception ex) {
      exceptionThrown = true;
      System.assert(ex.getMessage().contains('Unknown Record Type'));
    } finally {
      System.assertEquals(true, exceptionThrown, 'No exception was thrown');
    }
  }
}