@isTest
public with sharing class EmailUtilityTest {
  @isTest
  static void sendSingleEmailWithoutTemplateTest1() {
    Test.startTest();
    String toEmail = 'fahad@lgads.tv';
    String subject = 'Test Mail';
    String body = '<h2> Test Mail </h2>';
    String result = EmailUtility.sendSingleEmailWithoutTemplate(
      toEmail,
      '',
      '',
      subject,
      body,
      true
    );
    System.assertEquals(result, 'Email sent');
    Test.stopTest();
  }

  @isTest
  static void sendSingleEmailWithoutTemplateTest2() {
    Test.startTest();
    String toEmail = 'fahad@lgads.tv';
    String subject = 'Test Mail';
    String body = 'Test Mail';
    String result = EmailUtility.sendSingleEmailWithoutTemplate(
      toEmail,
      '',
      '',
      subject,
      body,
      false
    );
    System.assertEquals(result, 'Email sent');
    Test.stopTest();
  }
}