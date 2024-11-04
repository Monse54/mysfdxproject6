public with sharing class CMController {
  public static env__c env = env__c.getOrgDefaults();
  public static prod__c prodSettings = prod__c.getOrgDefaults();
  public static staging__c stagingSettings = staging__c.getOrgDefaults();

  @future(callout=true)
  public static void updateAMOnCM(String csmId, String oppId) {
    System.debug('Add AM to CM');
    if (csmId.length() == 0 || oppId.length() == 0) {
      return;
    }

    try {
      Http http = new Http();
      HttpRequest request = new HttpRequest();

      String apiKey = Constants.CM_API_KEY;
      String authHeader = env.current_env__c == 'staging'
        ? stagingSettings.mosaic_auth_token__c
        : prodSettings.mosaic_auth_token__c;
      String mosaicUrl = env.current_env__c == 'staging'
        ? stagingSettings.mosaic_url__c
        : prodSettings.mosaic_url__c;

      String endpoint =
        mosaicUrl +
        '/v3/campaign/account-manager' +
        '?api_key=' +
        apiKey +
        '&id=' +
        csmId +
        '&opportunity_id=' +
        oppId;
      System.debug('Endpoint ' + endpoint);
      request.setEndpoint(endpoint);
      request.setMethod('POST');
      request.setHeader('Content-Type', 'application/json');
      request.setHeader('authorization-token', authHeader);

      HttpResponse response = http.send(request);

      System.debug('Response ' + response);

      if (
        !(response.getStatusCode() >= 200 &&
        response.getStatusCode() < 300)
      ) {
        // Send slack alert for AM failed
        String requestBody = SlackHelper.AMUpdateFailedMessage(
          oppId,
          csmId,
          response.toString()
        );
        SlackHelper.sendSlackAlertSync(requestBody);
      }
    } catch (Exception e) {
      // Send slack alert for AM failed
      String requestBody = SlackHelper.AMUpdateFailedMessage(
        oppId,
        csmId,
        e.getMessage()
      );
      SlackHelper.sendSlackAlertSync(requestBody);
    }
  }
}