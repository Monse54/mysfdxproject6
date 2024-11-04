global class ScheduleUpdateCurrencyExchangeRate implements Schedulable {
  public static String EXCHANGE_RATE_API = 'https://openexchangerates.org/api/latest.json?app_id=af321b1003104d0ea016bf80f366c761&base=USD';

  global void execute(SchedulableContext ctx) {
    updateCurrency();
  }

  @future(callout=true)
  public static void updateCurrency() {
    Map<String, Object> exchangeRates = new Map<String, Object>();
    HttpRequest req = new HttpRequest();
    req.setEndpoint(EXCHANGE_RATE_API);
    req.setMethod('GET');
    HttpResponse response = new Http().send(req);
    Map<String, Object> jsonParse = (Map<String, Object>) Json.deserializeUntyped(
      response.getBody()
    );
    Map<String, Object> rsp_body = (Map<String, Object>) jsonParse.get('rates');

    if (rsp_body != null) {
      exchangeRates = rsp_body;
    }

    CurrencyType[] allCurrencies = [
      SELECT IsoCode
      FROM CurrencyType
      WHERE IsActive = TRUE AND IsCorporate = FALSE
    ];
    CurrencyType baseCurrency = [
      SELECT IsoCode
      FROM CurrencyType
      WHERE IsActive = TRUE AND IsCorporate = TRUE
    ][0];

    Double baseCurrencyRate = (Double) exchangeRates.get(baseCurrency.IsoCode);

    for (CurrencyType c : allCurrencies) {
      String isoCode = c.IsoCode;
      Double conversionRate =
        (Double) exchangeRates.get(isoCode) / baseCurrencyRate;
      Map<String, Object> body = new Map<String, Object>();
      body.put('IsoCode', isoCode);
      body.put('ConversionRate', conversionRate);
      body.put('StartDate', System.today());

      req.setEndpoint(
        URL.getSalesforceBaseUrl().toExternalForm() +
        '/services/data/v52.0/sobjects/DatedConversionRate/'
      );
      req.setBody(JSON.serialize(body));
      req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
      req.setHeader('Content-Type', 'application/json');
      req.setMethod('POST');
      HttpResponse res = new Http().send(req);

      System.debug('response: ' + res);
    }
  }
}