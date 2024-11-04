public with sharing class DateUtility {
  @AuraEnabled
  public static Date minDate(Date d1, Date d2) {
    if (d1 != null && d2 != null)
      return d1 < d2 ? d1 : d2;
    else if (d1 != null)
      return d1;
    else if (d2 != null)
      return d2;
    else
      return null;
  }

  @AuraEnabled
  public static Date maxDate(Date d1, Date d2) {
    if (d1 != null && d2 != null)
      return d1 > d2 ? d1 : d2;
    else if (d1 != null)
      return d1;
    else if (d2 != null)
      return d2;
    else
      return null;
  }
}