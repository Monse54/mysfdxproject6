public class Asana {
  public static env__c env = env__c.getOrgDefaults();
  @future(callout=true)
  public static void createFeasibilityAsanaTask(Id feasibiltyId) {
    Feasibilty__c record = [
      SELECT
        Asana_URL__c,
        Campaign_Name__c,
        Due_Date__c,
        Advertiser__c,
        Start_Date__c,
        End_Date__c,
        Opportunity__c,
        Max_Avails__c,
        Brand_Name__c,
        Priority__c,
        Type_of__c,
        Reseller__r.Name,
        CreatedById,
        Rate_Type__c,
        Currency__c,
        CPM_CPVC_Sale_Price__c,
        Max_Budget_Requested__c,
        Max_Quantity_Requested__c,
        Product_Type__c,
        Ad_Slot_Inventory__c,
        Creative_Notes__c,
        Ad_Format__c,
        Type_of_Carousal_Creatives__c,
        No_of_Carousel_Creatives_for_native__c,
        OS_Targeting__c,
        Targeting_File_Upload__c,
        Alphonso_Targeting__c,
        X3rd_Party_Targetting__c,
        Geo_Targeting__c,
        Special_Occasion__c,
        Extra_Notes__c,
        Fraud_Verification_Vendor__c,
        Viewability_Verification_Vendor__c,
        Viewability_Guarantee_Terms__c,
        Research_Study__c,
        Flight_Scheduling__c,
        RFP_Link__c,
        RFP_Briefs__c,
        X3rd_Party_Verification_Requirement__c,
        Industry_Type__c,
        Segment_Task_URL__c
      FROM Feasibilty__c
      WHERE Id = :feasibiltyId
    ][0];
    String FEASIBILITY_PROJECT_ID = env.feasibility_project_id__c;
    String SEGMENT_PROJECT_ID = env.segment_project_id__c;

    // Create Segment Task

    String newline = '\n ---- \n \n';
    Map<String, Object> body = new Map<String, Object>();
    Map<String, Object> data = new Map<String, Object>();
    String html =
      '<body><strong>Opportunity Id:</strong>' +
      record.Opportunity__c +
      '\n';
    html += newline;

    html += '</body>';

    // ----- feasibility ------
    data.put('projects', new List<String>{ SEGMENT_PROJECT_ID });
    data.put(
      'name',
      (record.Advertiser__c != null ? record.Advertiser__c : '') +
      ' ' +
      (record.Campaign_Name__c != null ? record.Campaign_Name__c : '')
    );

    data.put('html_notes', html);
    body.put('data', data);

    String url = createAsanaTask(body);

    record.segment_task_URL__c = url;

    // Create Feasibility Task
    User user_record = [
      SELECT Username, email, asana_gid__c
      FROM User
      WHERE id = :record.CreatedById
    ];
    Opportunity opportunity = [
      SELECT id, name, RecordType.Name
      FROM Opportunity
      WHERE id = :record.Opportunity__c
    ];

    String MANAGED_SERVICE_RECORD_TYPE = '1-Managed Service';
    String PROGRAMMATIC_RECORD_TYPE = '2-Self Service';
    String MS_RESELLER_RECORD_TYPE = 'Reseller';

    body = new Map<String, Object>();
    data = new Map<String, Object>();
    Map<String, Object> membership = new Map<String, Object>();
    Map<String, String> custom_fields = new Map<String, String>();
    Map<String, String> priority_mapping = new Map<String, String>();
    // ---- feasibility ------
    priority_mapping.put('Urgent', '1200156207097389');
    priority_mapping.put('High', '1200156207097390');
    priority_mapping.put('Medium', '1200156207097391');
    priority_mapping.put('Low', '1200156207097392');

    // ------ media planning testing ------
    // priority_mapping.put('Urgent', '1202209249836267');
    // priority_mapping.put('High', '1202209249836257');
    // priority_mapping.put('Medium', '1202209249834181');
    // priority_mapping.put('Low', '1202209249834162');

    Map<String, String> section_mapping = new Map<String, String>();
    // ----- feasibility ------
    section_mapping.put(
      MANAGED_SERVICE_RECORD_TYPE +
      '-' +
      Constants.FEASIBILITY_INDUSTRY_TYPE_ENTERTAINMENT,
      '1202180886651968'
    );
    section_mapping.put(
      MANAGED_SERVICE_RECORD_TYPE +
      '-' +
      Constants.FEASIBILITY_INDUSTRY_TYPE_GM,
      '1202180886651969'
    );
    section_mapping.put(PROGRAMMATIC_RECORD_TYPE, '1201434813703855');
    section_mapping.put(MS_RESELLER_RECORD_TYPE, '1205008443551357');


    // ----- media planning testing ------
    // section_mapping.put(
    //   MANAGED_SERVICE_RECORD_TYPE +
    //   '-' +
    //   Constants.FEASIBILITY_INDUSTRY_TYPE_ENTERTAINMENT,
    //   '1202209296552107'
    // );
    // section_mapping.put(
    //   MANAGED_SERVICE_RECORD_TYPE +
    //   '-' +
    //   Constants.FEASIBILITY_INDUSTRY_TYPE_GM,
    //   '1202209296552110'
    // );
    // section_mapping.put(PROGRAMMATIC_RECORD_TYPE, '1202209296552111');

    html =
      '<body><strong>Task created by:</strong>' +
      user_record.Username +
      '\n';
    html += '<strong>Start Date: </strong>' + record.Start_Date__c + '\n';
    html += '<strong>End Date: </strong>' + record.End_Date__c + '\n';
    html +=
      '<strong>Advertiser: </strong>' +
      (record.Advertiser__c == null
        ? '-'
        : record.Advertiser__c.escapeHtml4()) +
      '\n';
    html +=
      '<strong>Brand: </strong>' +
      (record.Brand_Name__c == null
        ? '-'
        : record.Brand_Name__c.escapeHtml4()) +
      '\n';
    html +=
      '<strong>Reseller Name: </strong>' +
      (record.Reseller__r.Name == null
        ? '-'
        : record.Reseller__r.Name) +
      '\n';
    html +=
      '<strong>Campaign Name: </strong>' +
      (record.Campaign_Name__c == null ? '-' : record.Campaign_Name__c) +
      '\n';
    html += '<strong>Opportunity Id: </strong>' + record.Opportunity__c + '\n';
    html += newline;
    html +=
      '<strong>Expected Budget (in dollars): </strong>' +
      record.Max_Budget_Requested__c +
      '\n';
    html +=
      '<strong>Expected Budget (Impressions): </strong>' +
      record.Max_Quantity_Requested__c +
      '\n';
    html += '<strong>RFP Link: </strong>' + record.RFP_Link__c + '\n';
    html +=
      '<strong>Ad Slot/Inventory Length: </strong>' +
      record.Ad_Slot_Inventory__c +
      '\n';
    html +=
      '<strong>Ad Product Type: </strong>' +
      record.Product_Type__c +
      '\n';
    html += '<strong>RFP Briefs: </strong>' + record.RFP_Briefs__c + '\n';
    html += newline;

    html +=
      '<strong>Type of Carousel Creative: </strong>' +
      record.Type_of_Carousal_Creatives__c +
      '\n';
    html +=
      '<strong>No of Carousel Creatives ( in case of Native ): </strong>' +
      record.No_of_Carousel_Creatives_for_native__c +
      '\n';
    html +=
      '<strong>OS Targeting: </strong>' +
      record.OS_Targeting__c +
      '\n';
    html +=
      '<strong>Targetting Files: </strong>' +
      record.Targeting_File_Upload__c +
      '\n';
    html +=
      '<strong>LG Ads Targetting: </strong>' +
      (record.Alphonso_Targeting__c == null
        ? '-'
        : record.Alphonso_Targeting__c.escapeHtml4()) +
      '\n';
    html +=
      '<strong>3rd party Targetting: </strong>' +
      (record.X3rd_Party_Targetting__c == null
        ? '-'
        : record.X3rd_Party_Targetting__c.escapeHtml4()) +
      '\n';
    html +=
      '<strong>Geo Targetting: </strong>' +
      (record.Geo_Targeting__c == null
        ? '-'
        : record.Geo_Targeting__c.escapeHtml4()) +
      '\n';
    html +=
      '<strong>3rd Party Verification Requirement: </strong>' +
      (record.X3rd_Party_Verification_Requirement__c == null
        ? '-'
        : record.X3rd_Party_Verification_Requirement__c.escapeHtml4()) +
      '\n';
    html += 
      '<strong>Special Occasion: </strong>' +
      record.Special_Occasion__c +
      '\n';
    html +=
      '<strong>Flight Scheduling: </strong>' +
      (record.Flight_Scheduling__c == null
        ? '-'
        : record.Flight_Scheduling__c.escapeHtml4()) +
      '\n';
    html += newline;

    html += '</body>';

    // ------ feasibility --------
    membership.put('project', FEASIBILITY_PROJECT_ID);
    // ------ media planing testing -------
    // membership.put('project', '1202209296552105');

    String sectionString = '';
    if (record.Reseller__r.Name != null) {
      sectionString += MS_RESELLER_RECORD_TYPE;
    } else if (opportunity.RecordType.Name == MANAGED_SERVICE_RECORD_TYPE) {
      sectionString += opportunity.RecordType.Name + '-' + record.Industry_Type__c;
    } else {
      sectionString += opportunity.RecordType.Name;
    }

    membership.put('section', section_mapping.get(sectionString));
    // ----- feasibility ------
    custom_fields.put(
      '1200156207097388',
      priority_mapping.get(record.Priority__c)
    );
    custom_fields.put(
      Constants.ASANA_SEGMENT_CUSTOM_FIELD,
      record.segment_task_URL__c
    );
    // ----- media planning ----
    // custom_fields.put(
    //   '1202209249833130',
    //   priority_mapping.get(records.Priority__c)
    // );

    data.put(
      'name',
      (record.Advertiser__c != null ? record.Advertiser__c : '') +
      ' ' +
      (record.Campaign_Name__c != null ? record.Campaign_Name__c : '')
    );
    // ----- feasibility ------
    data.put('projects', new List<String>{ FEASIBILITY_PROJECT_ID });
    // ------ media planing testing ------
    // data.put('projects', new List<String>{ '1202209296552105' });

    data.put('memberships', new List<Object>{ membership });
    data.put('due_on', record.Due_Date__c);
    data.put('custom_fields', custom_fields);
    data.put('html_notes', html);
    body.put('data', data);

    url = createAsanaTask(body);

    record.Asana_URL__c = url;
    try {
      if (
        record.Advertiser__c != null &&
        record.Advertiser__c.trim().toLowerCase().startsWith('a4')
      ) {
        String requestBody = SlackHelper.feasibilityHelp(
          user_record.Email,
          url,
          record.Advertiser__c,
          opportunity
        );
        SlackHelper.sendSlackAlertSync(requestBody);
      }
    } catch (Exception e) {
      System.debug('Exception while sending slack alert ' + e.getMessage());
    }
    update record;
  }

  @future(callout=true)
  public static void createCaseAsanaTask(Id caseId) {
    List<Case> recordsList = [
      SELECT
        Asana_URL__c,
        OwnerId,
        Opportunity__c,
        Subject,
        Description,
        Comments,
        Origin,
        Status,
        SuppliedCompany,
        SuppliedEmail,
        SuppliedName,
        SuppliedPhone
      FROM Case
      WHERE Id = :caseId
    ];
      
    Case records = new Case();
    if(recordsList.size() < 1)
        return;
    else
        records = recordsList[0];
    List<User> user_record_list = [
      SELECT Username, asana_gid__c
      FROM User
      WHERE id = :records.OwnerId
    ];
      
    User user_record  = null;
    if(user_record_list.size() > 0)
        user_record = user_record_list[0];

    Map<String, Object> body = new Map<String, Object>();
    Map<String, Object> data = new Map<String, Object>();
    Map<String, Object> membership = new Map<String, Object>();

    String html = '<body>';
    html += '<strong>Opportunity Id:</strong>' + records.Opportunity__c + '\n';
    html += '<strong>Case Origin:</strong>' + records.Origin + '\n';
    html += '<strong>Status:</strong>' + records.Status + '\n';
    html += '<strong>Subject:</strong>' + records.Subject + '\n';
    html += '<strong>Description:</strong>' + records.Description + '\n';
    html += '</body>';

    membership.put('project', '1200134875094939');
    membership.put('section', '1200156207097412');
    data.put('name', records.Subject);
    data.put('projects', new List<String>{ '1200134875094939' });
    data.put('memberships', new List<Object>{ membership });
    data.put('html_notes', html);
    body.put('data', data);

    String url = createAsanaTask(body);

    records.Asana_URL__c = url;
    update records;
  }

  @future(callout=true)
  public static void createProgrammaticDealAsanaTask(Id pdId) {
    String PD_PROJECT_ID = env.pd_project_id__c;

    Datetime tomorrow = Datetime.now().addDays(1);
    String dueDate = tomorrow.format('yyyy-MM-dd', 'Asia/Kolkata');

    Programmatic_Deal_Request__c record = [
      SELECT
        Name,
        Opportunity_Product__c,
        Flight_Start_Date__c,
        Flight_End_Date__c,
        Inventory_Type__c,
        Creative_Lengths__c,
        CPM__c,
        CPM_Type__c,
        DSP__c,
        Seat_Id_DSP__c,
        Partner_Id_DSP__c,
        Targeting__c,
        Block_List__c,
        Inclusion_List__c,
        OwnerId,
        Opportunity_Product__r.OpportunityId,
        Opportunity_Product__r.Opportunity.Name
      FROM Programmatic_Deal_Request__c
      WHERE Id = :pdId
      LIMIT 1
    ][0];

    Map<String, Object> body = new Map<String, Object>();
    Map<String, Object> data = new Map<String, Object>();
    Map<String, Object> membership = new Map<String, Object>();

    String oppId = record.Opportunity_Product__r.OpportunityId;
    String oppName = record.Opportunity_Product__r.Opportunity.Name;

    String oppLink = URL.getSalesforceBaseUrl().toExternalForm() + '/' + oppId;
    String requestLink =
      URL.getSalesforceBaseUrl().toExternalForm() +
      '/' +
      pdId;

    String targeting = '';
    String blockList = '';
    String inclusionList = '';

    if (record.Targeting__c != null && record.Targeting__c.length() > 0) {
      targeting = record.Targeting__c.escapeHtml4();
    }

    if (record.Block_List__c != null && record.Block_List__c.length() > 0) {
      blockList = record.Block_List__c.escapeHtml4();
    }

    if (
      record.Inclusion_List__c != null &&
      record.Inclusion_List__c.length() > 0
    ) {
      inclusionList = record.Inclusion_List__c.escapeHtml4();
    }

    String html = '<body>';
    html += '<strong>Campaign Name:</strong> ' + oppName + '\n';
    html += '<strong>Opportunity Id:</strong> ' + oppId + '\n';
    html +=
      '<strong>Opportunity Link:</strong> ' +
      '<a href="' +
      oppLink +
      '">' +
      oppName +
      '</a>' +
      '\n';
    html +=
      '<strong>Flight Start Date:</strong> ' +
      record.Flight_Start_Date__c.format() +
      '\n';
    html +=
      '<strong>Flight End Date:</strong> ' +
      record.Flight_End_Date__c.format() +
      '\n';
    html +=
      '<strong>Inventory Type:</strong> ' +
      record.Inventory_Type__c +
      '\n';
    html +=
      '<strong>Creative Lengths:</strong> ' +
      record.Creative_Lengths__c +
      '\n';
    html += '<strong>CPM:</strong> ' + record.CPM__c + '\n';
    html += '<strong>CPM Type:</strong> ' + record.CPM_Type__c + '\n';
    html += '<strong>DSP:</strong> ' + record.DSP__c.escapeHtml4() + '\n';
    html +=
      '<strong>Client\'s Seat Id on DSP:</strong> ' +
      record.Seat_Id_DSP__c +
      '\n';
    html +=
      '<strong>Client\'s Partner Id on DSP:</strong> ' +
      record.Partner_Id_DSP__c +
      '\n';
    html += '<strong>Targeting:</strong> ' + targeting + '\n';
    html += '<strong>Block List:</strong> ' + blockList + '\n';
    html += '<strong>Inclusion List:</strong> ' + inclusionList + '\n';
    html +=
      '<strong>Request Link:</strong> ' +
      '<a href="' +
      requestLink +
      '">' +
      record.Name +
      '</a>' +
      '\n';
    html += '</body>';

    membership.put('project', PD_PROJECT_ID);
    data.put('memberships', new List<Object>{ membership });

    data.put('projects', new List<String>{ PD_PROJECT_ID });
    data.put('name', record.Name + ': ' + oppName);
    data.put('html_notes', html);
    data.put('due_on', dueDate);
    body.put('data', data);

    String url = createAsanaTask(body);

    record.Asana_URL__c = url;
    update record;
  }

  public static string createAsanaTask(Map<String, Object> body) {
    HttpRequest request = new HttpRequest();
    String endpoint = 'https://app.asana.com/api/1.0/tasks';
    String authHeader = 'Bearer 1/164440441056927:6d50fa612a7cf24a32ff0a24889c8452';

    request.setHeader('Content-Type', 'application/json;charset=UTF-8');
    request.setHeader('Authorization', authHeader);
    request.setBody(JSON.serialize(body));
    request.setEndPoint(endpoint);
    request.setMethod('POST');

    HttpResponse response = new Http().send(request);

    Map<String, Object> jsonParse = (Map<String, Object>) Json.deserializeUntyped(
      response.getBody()
    );
    System.debug('Json ' + jsonParse);

    Map<String, Object> rsp_body = (Map<String, Object>) jsonParse.get('data');
    String rval = 'ASANA_ERROR';
    if (rsp_body == null) {
      try {
        List<Object> errors = (List<Object>) jsonParse.get('errors');
        if (errors != null && errors.size() > 0) {
          Map<String, Object> firstError = (Map<String, Object>) errors[0];
          System.debug('Error ' + firstError.get('message'));
          rval += ' ' + firstError.get('message').toString();
        } else {
          rval += ' No errors in json';
        }
      } catch (Exception e) {
        System.debug('Exception ' + e.getMessage());
        rval += ' ' + e.getMessage();
      }
      if (rval.length() > 255) {
        rval = rval.substring(0, 255);
      }
      return rval;
    }

    String url = (String) rsp_body.get('permalink_url');
    return url;
  }
}