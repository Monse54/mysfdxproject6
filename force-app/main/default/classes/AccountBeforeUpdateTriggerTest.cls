@isTest
public class AccountBeforeUpdateTriggerTest {
  @isTest
  public static void accountBeforeUpdateTest() {
    TestHelper.setupTests();
    Account acc = new Account(
      Name = 'Test Account',
      Website = 'www.lg.com',
      Type = Constants.ACCOUNT_TYPE_BRAND
    );
    Account duplAcc = new Account(
      Name = 'Test Account 1',
      Website = 'www.lg.com',
      Type = Constants.ACCOUNT_TYPE_BRAND
    );
    Boolean exceptionThrown = false;
    Test.startTest();
    insert acc;

    try {
      exceptionThrown = false;
      insert duplAcc;
    } catch (Exception e) {
      exceptionThrown = true;
      System.assert(e.getMessage().containsIgnoreCase('duplicate'));
    } finally {
      System.assertEquals(exceptionThrown, true, 'No exception was thrown');
    }

    try {
      exceptionThrown = false;
      duplAcc.Name = 'Test Account';
      insert duplAcc;
    } catch (Exception e) {
      exceptionThrown = true;
      System.assert(
        e.getMessage()
          .containsIgnoreCase(
            'duplicate'
          )
      );
    } finally {
      System.assertEquals(exceptionThrown, true, 'No exception was thrown');
    }

    Test.stopTest();
  }
}