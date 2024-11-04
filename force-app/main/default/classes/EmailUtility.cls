public with sharing class EmailUtility {
  @AuraEnabled
  public static String sendSingleEmailWithoutTemplate(
    String toEmail,
    String ccEmail,
    String replyEmail,
    String subject,
    String body,
    Boolean isHTML
  ) {
    String result;

    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    String[] to = new List<String>{ toEmail };
    String[] cc = new List<String>{ ccEmail };

    email.setToAddresses(to);
    if (ccEmail != null && ccEmail != '') {
      email.setCcAddresses(cc);
    }
    if (replyEmail != null && replyEmail != '') {
      email.setInReplyTo(replyEmail);
    }

    email.setSubject(subject);

    if (isHTML != null && isHTML) {
      email.setHtmlBody(body);
    } else {
      email.setPlainTextBody(body);
    }
    try {
      Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
      result = 'Email sent';
    } catch (Exception e) {
      result = 'Email sending failed, Error: ' + e.getMessage();
    }
    return result;
  }
}