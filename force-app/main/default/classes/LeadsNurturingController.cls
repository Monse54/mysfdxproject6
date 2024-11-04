public with sharing class LeadsNurturingController {
  public static String LEADS_REFRESH_ENDPOINT = 'https://leads-nurturing.alphonso.tv/v1/leads/refresh/';
  public static String LEADS_API_KEY = 'Leads-TGVhZHMtTnVydHVyaW5nLVNlcnZlci1BUEktS2V5Cg==';

  public static void updateLeadsReport(Account acc) {
    Id accountId = acc.Id;
    String accName = acc.Name;
    String brandId = acc.Brand_Id__c;
    String compIds = acc.Competition_Brand_Ids__c;

    System.debug(accountId);
    System.debug(brandId);
    System.debug(accName);
    System.debug(compIds);
    List<String> refreshTypes = new List<String>{
      'adSpend',
      'competitive-analysis',
      'r+f',
      'resonance'
    };
    sendRefreshRequest(acc.Id, refreshTypes);
  }

  @future(callout=true)
  public static void sendRefreshRequest(
    Id accountId,
    List<String> refreshTypes
  ) {
    Account account = [
      SELECT Id, Name, Brand_Id__c, Competition_Brand_Ids__c
      FROM Account
      WHERE Id = :accountId
    ][0];

    for (String refreshType : refreshTypes) {
      HttpRequest request = new HttpRequest();
      Map<String, Object> body = new Map<String, Object>();
      Map<String, Object> accountInfo = new Map<String, Object>();
      accountInfo.put('Id', accountId);
      accountInfo.put('Name', account.Name);
      accountInfo.put('Brand_Id__c', account.Brand_Id__c);
      accountInfo.put(
        'Competition_Brand_Ids__c',
        account.Competition_Brand_Ids__c
      );
      body.put('Account', accountInfo);

      String endpoint =
        LEADS_REFRESH_ENDPOINT +
        refreshType +
        '?api_key=' +
        LEADS_API_KEY;
      request.setHeader('Content-Type', 'application/json;charset=UTF-8');
      request.setBody(JSON.serialize(body));
      request.setEndPoint(endpoint);
      request.setMethod('POST');

      HttpResponse response = new Http().send(request);
      System.debug(response);
    }
  }
}