public with sharing class BrandInfoLookupController {
  public static String BRAND_SEARCH_API = 'https://api.alphonso.tv/v1/metadata/brands';
  public static Integer BRAND_SEARCH_LIMIT = 200;

  // dev
  // public static String BRAND_API = 'http://abclipper-ui-staging.alphonso.tv:4402/api/v2/brands';
  // prod
  public static String BRAND_API = 'https://adclipper.alphonso.tv/api/v2/brands';

  // dev
  // public static String CAMPAIGN_UPDATE_API = 'http://devops10.alphonso.tv:4446/v1/campaigns/brand';
  // prod
  // public static String CAMPAIGN_UPDATE_API = 'https://server-mosaic.alphonso.tv/v3/campaign/brand';

  public static env__c env = env__c.getOrgDefaults();
  public static prod__c prodSettings = prod__c.getOrgDefaults();
  public static staging__c stagingSettings = staging__c.getOrgDefaults();

  @AuraEnabled(cacheable=true)
  public static List<Object> getBrands(String searchString) {
    List<Object> brandsList = new List<Object>();
    System.debug('Get brands' + searchString);
    if (searchString.length() == 0) {
      return brandsList;
    }

    Http http = new Http();
    HttpRequest request = new HttpRequest();

    // prod
    String endpoint =
      BRAND_SEARCH_API +
      '?q=' +
      searchString +
      '&limit=' +
      BRAND_SEARCH_LIMIT;

    // dev
    // String endpoint =
    //   BRAND_API +
    //   '?search=' +
    //   searchString +
    //   '&limit=' +
    //   BRAND_SEARCH_LIMIT;

    String authHeader = 'Bearer 0/426d4fd3f6154dfed80b406f97c6eae05e739bd26998a0a18475bc44cca0d945';
    System.debug('Endpoint ' + endpoint);

    request.setEndpoint(endpoint);
    request.setHeader('Authorization', authHeader);

    request.setMethod('GET');
    HttpResponse response = http.send(request);

    System.debug('Response' + response);
    // System.debug('Body' + JSON.deserializeUntyped(response.getBody()));

    if (response.getStatusCode() >= 200 && response.getStatusCode() < 300) {
      brandsList = (List<Object>) JSON.deserializeUntyped(response.getBody());
    }
    return brandsList;
  }

  @AuraEnabled(cacheable=true)
  public static List<Object> getBrandInfoFromName(String name) {
    List<Object> brandsList = new List<Object>();
    System.debug('Get brands info ' + name);
    if (name.length() == 0) {
      return brandsList;
    }

    Http http = new Http();
    HttpRequest request = new HttpRequest();

    String endpoint = BRAND_API + '?search=' + name;

    System.debug('Endpoint ' + endpoint);

    request.setEndpoint(endpoint);
    request.setMethod('GET');
    HttpResponse response = http.send(request);

    System.debug('Response' + response);

    if (response.getStatusCode() >= 200 && response.getStatusCode() < 300) {
      brandsList = (List<Object>) JSON.deserializeUntyped(response.getBody());
    }
    return brandsList;
  }

  @AuraEnabled
  public static void updateBrandInfo(
    Id accountId,
    String brandId,
    String brandName
  ) {
    Account acc = [SELECT Id FROM Account WHERE Id = :accountId];

    acc.Brand_Id__c = brandId;
    acc.Brand_Name__c = brandName;

    update acc;
  }

  @AuraEnabled
  public static void updateOpportunityBrandInfo(
    Id oppId,
    String brandId,
    String brandName
  ) {
    System.debug(oppId + ' : ' + brandId + ' : ' + brandName);

    Opportunity oppty = [SELECT Id FROM Opportunity WHERE Id = :oppId];

    oppty.Brand_Id__c = brandId;
    oppty.Brand_Name__c = brandName;

    update oppty;
  }

  @AuraEnabled
  public static Object addNewBrand(
    String name,
    Integer isValidated,
    String createdBy,
    String source
  ) {
    Object brandInfo;

    Http http = new Http();
    HttpRequest request = new HttpRequest();

    String endpoint = BRAND_API;
    // dev
    // String cookieValue = 'globals=%7B%22currentUser%22%3A%7B%22username%22%3A%22amitk%40alphonso.tv%22%2C%22authdata%22%3A%22YW1pdGtAYWxwaG9uc28udHY6QW1pVDEyMzQ%3D%22%2C%22role%22%3A%22curator%22%2C%22provider%22%3A%22local%22%2C%22team%22%3A%22alphonso%22%2C%22permission%22%3A%7B%22edit-title%22%3A%22true%22%2C%22view-dedup-stats%22%3A%22true%22%7D%2C%22tokenCreationTime%22%3A%222021-09-22T10%3A19%3A56.125Z%22%7D%2C%22brandValEnabled%22%3Atrue%2C%22prodValEnabled%22%3Afalse%7D';

    Map<String, Object> body = new Map<String, Object>();
    body.put('brand', name);
    body.put('brand_validated', isValidated);
    body.put('brand_created_by', createdBy);
    body.put('brand_created_on', DateTime.now().format('yyyy-MM-dd hh:mm:ss'));
    body.put('brand_source', source);

    request.setEndpoint(endpoint);
    request.setMethod('POST');
    request.setHeader('Content-Type', 'application/json;charset=UTF-8');
    request.setBody(JSON.serialize(body));
    // dev
    // request.setHeader('Cookie', cookieValue);
    // prod
    request.setHeader('app', 'new-abclipper');
    HttpResponse response = http.send(request);

    if (response.getStatusCode() >= 200 && response.getStatusCode() < 300) {
      brandInfo = (Object) JSON.deserializeUntyped(response.getBody());
    }
    System.debug(brandInfo);
    return brandInfo;
  }

  @AuraEnabled
  public static Object addBrandToCampaign(
    String oppId,
    String brandId,
    String brandName
  ) {
    System.debug('Add brand to CM');
    if (brandId.length() == 0 || brandName.length() == 0) {
      return null;
    }

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
      '/v3/campaign/brand' +
      '?api_key=' +
      apiKey +
      '&brand_name=' +
      brandName +
      '&brand_id=' +
      brandId +
      '&opportunity_id=' +
      oppId;
    System.debug('Endpoint ' + endpoint);
    request.setEndpoint(endpoint);
    request.setMethod('POST');
    request.setHeader('Content-Type', 'application/json');
    request.setHeader('authorization-token', authHeader);

    HttpResponse response = http.send(request);

    System.debug('Response ' + response);

    if (response.getStatusCode() >= 200 && response.getStatusCode() < 300) {
      Object success = (Object) JSON.deserializeUntyped(response.getBody());
      return success;
    }
    return null;
  }
}