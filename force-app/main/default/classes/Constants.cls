public class Constants {
  public static final String PRODUCT_TYPE_DEFAULT = 'Default';
  public static final String PRODUCT_TYPE_INCREMENTAL = 'Incremental';
  public static final String PRODUCT_TYPE_MAKE_GOOD = 'Make Good';
  public static final String PRODUCT_TYPE_ADDED_VALUE = 'Added Value';

  public static final String STAGE_CLOSED_LOST = 'Closed Lost';
  public static final String STAGE_CLOSED_WON = 'Closed Won';
  public static final String STAGE_WAITING_ASSETS = 'Waiting on Assets - Closed Won';
  public static final String STAGE_NEGOTIATION = 'Negotiation';
  public static final String STAGE_VERBAL_CONFIRM = 'Verbal Confirm';

  public static final String ACCOUNT_TYPE_BRAND = 'Brand (Client)';
  public static final String ACCOUNT_TYPE_RESELLER = 'Reseller';
  public static final String ACCOUNT_TYPE_AGENCY = 'Agency';

  public static final String BUSINESS_VERTICAL_RESELLER = 'Reseller';
  public static final String BUSINESS_VERTICAL_NATIONAL_ME = 'National Media & Entertainment';

  public static final String RECORD_TYPE_MANAGED = '1-Managed Service';
  public static final String RECORD_TYPE_SelfService = '2-Self Service';
  public static final String RECORD_TYPE_CORPORATE = '3-Corporate';

  public static final String PRICEBOOK_MANAGED = 'Managed Service';
  public static final String PRICEBOOK_SELF = 'Self Service';
  public static final String PRICEBOOK_CORPORATE = 'Corporate';

  public static final String FEASIBILITY_INDUSTRY_TYPE_ENTERTAINMENT = 'Entertainment';
  public static final String FEASIBILITY_INDUSTRY_TYPE_GM = 'General Market';
  public static final String COUNTRY_US = 'United States';
  public static final String COUNTRY_CANADA = 'Canada';

  public static final String PRODUCT_SPONSORED_SEARCH = 'Sponsored Search';
  public static final String PRODUCT_INSIGHTS = 'Insights and Attribution';
  public static final String PRODUCT_ROADBLOCK = 'Roadblock';
  public static final String PRODUCT_PROG_PMP = 'Programmatic PMP';
  public static final String PRODUCT_PROG_GUARANTEED = 'Programmatic Guaranteed';

  public static final Date OPP_TYPE_MISMATCH_DATE = Date.newInstance(
    2022,
    3,
    25
  );
  public static final String CM_API_KEY = 'czNyVjNSLUBkc19DQG1wQCE2JC1zM2NSMzc=';
  public static final String ASANA_SEGMENT_CUSTOM_FIELD = '1203655136398949';

  public static final List<String> CLOSED_WON_ROLES = new List<String>{
    'Account Management', 'Finance', 'Operations', 'Product', 'Marketing', 'Others'
  };
}