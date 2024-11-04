public class SlackHelper {
  public static String ALERTMAN_URL = 'https://alertman.alphonso.tv/v1/output/slack?api_key=Alertman-QWxlcnRNYW5hZ2VyX01hbmdv';
  public static env__c env = env__c.getOrgDefaults();
  public static String feasibilityChannel = env.feasibility_alert_channel__c;
  public static String feasibilityTeam = env.feasibility_team__c;
  public static String sfCoreChannel = env.sf_core_channel__c;
  public static String sfCoreTeam = env.sf_core_team__c;
  public static Map<String, String> slackChannels = new Map<String, String>{
    'marketing-help' => 'CJXKVPALQ',
    feasibilityChannel => feasibilityChannel,
    sfCoreChannel => sfCoreChannel
  };
  public static Map<String, String> slackAppName = new Map<String, String>{
    'marketing-help' => 'Marketing Help',
    'salesforce' => 'Salesforce'
  };

  class Text {
    public String type;
    public String text;
  }
  class Field {
    public String type;
    public String text;
  }
  class BlockText {
    public String type;
    public Text text;
  }
  class BlockFields {
    public String type;
    public List<Field> fields;
  }
  public class SlackPayload {
    public String channel;
    public String username;
    public String icon_emoji;
    public List<Object> blocks;
    public String attention;
  }

  public static void accountMarketingHelp(
    String userName,
    String domainUrl,
    String customNote,
    Account acc
  ) {
    System.debug(acc);
    SlackPayload message = new SlackPayload();
    message.channel = slackChannels.get('marketing-help');
    message.username = slackAppName.get('marketing-help');

    Text mainText = new Text();
    mainText.type = 'mrkdwn';
    mainText.text =
      userName +
      ' needs help with Account: *<' +
      domainUrl +
      acc.Id +
      '|' +
      acc.Name +
      '>*';

    Text customNoteText = new Text();
    customNoteText.type = 'mrkdwn';
    customNoteText.text = '*Custom Note:*\n```' + customNote + '```';

    Field accountName = new Field();
    accountName.type = 'mrkdwn';
    accountName.text = '*Account Name:*\n' + acc.Name;

    Field accountId = new Field();
    accountId.type = 'mrkdwn';
    accountId.text = '*Id:*\n' + acc.Id;

    BlockText mainBlock = new BlockText();
    mainBlock.type = 'section';
    mainBlock.text = mainText;

    BlockText customNoteBlock = new BlockText();
    customNoteBlock.type = 'section';
    customNoteBlock.text = customNoteText;

    BlockFields accDetails = new BlockFields();
    accDetails.type = 'section';
    List<Field> accDetailFields = new List<Field>();
    accDetailFields.add(accountName);
    accDetailFields.add(accountId);
    accDetails.fields = accDetailFields;

    List<Object> messageBlocks = new List<Object>();
    messageBlocks.add(mainBlock);
    messageBlocks.add(customNoteBlock);
    messageBlocks.add(accDetails);

    message.blocks = messageBlocks;

    String requestBody = JSON.serialize(message);
    System.debug(message);
    System.debug(requestBody);
    SlackHelper.sendSlackAlert(requestBody);
  }

  public static void opportunityMarketingHelp(
    String userName,
    String domainUrl,
    String customNote,
    Opportunity opp
  ) {
    System.debug(opp);
    SlackPayload message = new SlackPayload();
    message.channel = slackChannels.get('marketing-help');
    message.username = slackAppName.get('marketing-help');

    Text mainText = new Text();
    mainText.type = 'mrkdwn';
    mainText.text =
      userName +
      ' needs help with Opportunity: *<' +
      domainUrl +
      opp.Id +
      '|' +
      opp.Name +
      '>*';

    Text customNoteText = new Text();
    customNoteText.type = 'mrkdwn';
    customNoteText.text = '*Custom Note:*\n```' + customNote + '```';

    Field campaignName = new Field();
    campaignName.type = 'mrkdwn';
    campaignName.text = '*Campaign Name:*\n' + opp.Name;

    Field campaignId = new Field();
    campaignId.type = 'mrkdwn';
    campaignId.text = '*Id:*\n' + opp.Id;

    Field campaignStage = new Field();
    campaignStage.type = 'mrkdwn';
    campaignStage.text = '*Stage:*\n' + opp.StageName;

    Field campaignBookingDate = new Field();
    campaignBookingDate.type = 'mrkdwn';
    campaignBookingDate.text = '*Booking Date:*\n' + opp.CloseDate;

    BlockText mainBlock = new BlockText();
    mainBlock.type = 'section';
    mainBlock.text = mainText;

    BlockText customNoteBlock = new BlockText();
    customNoteBlock.type = 'section';
    customNoteBlock.text = customNoteText;

    BlockFields oppDetails = new BlockFields();
    oppDetails.type = 'section';
    List<Field> oppDetailFields = new List<Field>();
    oppDetailFields.add(campaignName);
    oppDetailFields.add(campaignId);
    oppDetailFields.add(campaignStage);
    oppDetailFields.add(campaignBookingDate);
    oppDetails.fields = oppDetailFields;

    List<Object> messageBlocks = new List<Object>();
    messageBlocks.add(mainBlock);
    messageBlocks.add(customNoteBlock);
    messageBlocks.add(oppDetails);

    message.blocks = messageBlocks;

    String requestBody = JSON.serialize(message);
    System.debug(message);
    System.debug(requestBody);
    SlackHelper.sendSlackAlert(requestBody);
  }

  public static String feasibilityHelp(
    String userEmail,
    String asanaURL,
    String advertiser,
    Opportunity opp
  ) {
    System.debug('Settings ' + feasibilityChannel + ' ' + feasibilityTeam);
    SlackPayload message = new SlackPayload();
    message.channel = slackChannels.get(feasibilityChannel);
    message.username = slackAppName.get('salesforce');

    Text mainText = new Text();
    mainText.type = 'mrkdwn';
    mainText.text =
      'New Feasibility Request created for `' +
      advertiser +
      '` <@' +
      userEmail.split('@')[0] +
      '>\n';
    mainText.text += 'URL: ' + asanaURL;

    Field oppName = new Field();
    oppName.type = 'mrkdwn';
    oppName.text = '*Opportunity Name:*\n' + opp.Name;

    Field oppId = new Field();
    oppId.type = 'mrkdwn';
    oppId.text = '*Id:*\n' + opp.Id;

    BlockText mainBlock = new BlockText();
    mainBlock.type = 'section';
    mainBlock.text = mainText;

    BlockFields oppDetails = new BlockFields();
    oppDetails.type = 'section';
    List<Field> oppDetailFields = new List<Field>();
    oppDetailFields.add(oppName);
    oppDetailFields.add(oppId);
    oppDetails.fields = oppDetailFields;

    List<Object> messageBlocks = new List<Object>();
    messageBlocks.add(mainBlock);
    messageBlocks.add(oppDetails);

    message.blocks = messageBlocks;

    message.attention = feasibilityTeam;

    String requestBody = JSON.serialize(message);
    System.debug(message);
    System.debug(requestBody);
    return requestBody;
  }

  public static String AMUpdateFailedMessage(
    String oppId,
    String csmId,
    String error
  ) {
    SlackPayload message = new SlackPayload();
    message.channel = slackChannels.get(sfCoreChannel);
    message.username = slackAppName.get('salesforce');

    Text mainText = new Text();
    mainText.type = 'mrkdwn';
    mainText.text =
      'Updating AM on CM failed for `' +
      oppId +
      '` CSM Id `' +
      csmId +
      '` <@' +
      sfCoreTeam +
      '>\n';
    mainText.text += 'Error: ' + error;

    BlockText mainBlock = new BlockText();
    mainBlock.type = 'section';
    mainBlock.text = mainText;

    List<Object> messageBlocks = new List<Object>();
    messageBlocks.add(mainBlock);

    message.blocks = messageBlocks;
    String requestBody = JSON.serialize(message);
    System.debug(message);
    System.debug(requestBody);
    return requestBody;
  }

  @future(callout=true)
  public static void sendSlackAlert(String requestBody) {
    System.HttpResponse response = SlackHelper.sendSlackAlertSync(requestBody);
    System.debug(response);
  }

  public static System.HttpResponse sendSlackAlertSync(String requestBody) {
    HttpRequest request = new HttpRequest();
    request.setMethod('POST');
    request.setEndPoint(ALERTMAN_URL);
    request.setHeader('Content-Type', 'application/json');
    request.setBody(requestBody);

    HttpResponse response = new Http().send(request);
    System.debug(response);
    return response;
  }
}