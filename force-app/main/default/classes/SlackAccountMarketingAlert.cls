public class SlackAccountMarketingAlert {
  public class AccountHelpInput {
    @InvocableVariable(required=true)
    public String userName;
    @InvocableVariable(required=true)
    public Account accountRecord;
    @InvocableVariable(required=true)
    public String domainURL;
    @InvocableVariable(required=true)
    public String customNote;
  }

  @InvocableMethod(label='Send Account Marketing Help Slack Alert')
  public static void accountMarketingHelpAlert(List<AccountHelpInput> inputs) {
    AccountHelpInput input = inputs[0];
    String userName = input.userName;
    String domainUrl = input.domainURL;
    String customNote = input.customNote;
    Account acc = input.accountRecord;
    SlackHelper.accountMarketingHelp(userName, domainUrl, customNote, acc);
  }
}