public class SlackOppMarketingAlert {
  public class OpportunityHelpInput {
    @InvocableVariable(required=true)
    public String userName;
    @InvocableVariable(required=true)
    public Opportunity opportuntiyRecord;
    @InvocableVariable(required=true)
    public String domainURL;
    @InvocableVariable(required=true)
    public String customNote;
  }

  @InvocableMethod(label='Send Opportunity Marketing Help Slack Alert')
  public static void opportunityMarketingHelpAlert(
    List<OpportunityHelpInput> inputs
  ) {
    OpportunityHelpInput input = inputs[0];
    String userName = input.userName;
    String domainUrl = input.domainURL;
    String customNote = input.customNote;
    Opportunity opp = input.opportuntiyRecord;
    SlackHelper.opportunityMarketingHelp(userName, domainUrl, customNote, opp);
  }
}