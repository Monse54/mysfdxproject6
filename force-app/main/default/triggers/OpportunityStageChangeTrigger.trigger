trigger OpportunityStageChangeTrigger on Opportunity(
  before insert,
  before update
) {
  // Constants
  String STAGE_VERBAL_CONFIRM = 'Verbal Confirm';
  String STAGE_CLOSED_WON = 'Closed Won';
  String BILLING_LEVEL_ACCOUNT = 'Account';
  String BILLING_LEVEL_AGENCY = 'Agency';
  String SELF_SERVICE = 'Self Service';

  // To reduce the total SOQL queries called in case if multiple opps are updated at once
  // Prefetch opportunity accounts
  List<Id> oppIds = new List<Id>();
  List<Id> accountIds = new List<Id>();
  for (Opportunity opp : Trigger.New) {
    oppIds.add(opp.Id);
    accountIds.add(opp.AccountId);
  }

  // prefetch all accounts
  Map<Id, Account> preAccounts = new Map<Id, Account>(
    [SELECT Id, Name, Type FROM Account WHERE Id IN :accountIds]
  );

  // Prefetch all pricebooks and record types
  Map<Id, Pricebook2> prePricebooks = new Map<Id, Pricebook2>(
    [SELECT Id, Name FROM Pricebook2]
  );
  Map<Id, RecordType> preRecordTypes = new Map<Id, RecordType>(
    [SELECT Id, Name FROM RecordType]
  );

  // Get Opportunity stage position
  // This would help us know whether certain stage
  // is before or after some other stage
  Map<String, Integer> stages = new Map<String, Integer>();
  Integer index = 0;
  for (
    PicklistEntry value : Opportunity.StageName.getDescribe()
      .getPicklistValues()
  ) {
    stages.put(value.getValue(), index++);
  }

  // Fetch the custom settings for verifying various fields
  Trigger_Settings__c ts = Trigger_Settings__c.getOrgDefaults();
  Boolean isActive = ts.Opportunity_Triggers_Active__c;

  for (Opportunity opp : Trigger.New) {
    System.debug('Opportunity Stage Change trigger ' + opp);
    // Check for mismatching "Record Type" (Pricebook) and "Opportunity Record Type" (RecordType)
    String oppPricebook = '';
    String oppRecordType = '';
    if (opp.RecordTypeId != null) {
      oppRecordType = preRecordTypes.get(opp.RecordTypeId).Name;
    }
    // If Pricebook is null (While inserting an opp) fill it with correct record type
    if (opp.Pricebook2Id == null && !opp.Skip_Validations__c) {
      if (oppRecordType != '' && oppRecordType != null) {
        for (Id key : prePricebooks.keySet()) {
          if (
            prePricebooks.get(key).Name ==
            OpportunityHelper.convertRecordTypeToPricebook(oppRecordType)
          ) {
            opp.Pricebook2Id = key;
            break;
          }
        }
      }
    }
    if (opp.Pricebook2Id != null) {
      oppPricebook = prePricebooks.get(opp.Pricebook2Id).Name;
    }
    // Check only for newer opps
    if (
      Trigger.isInsert ||
      (Trigger.isUpdate && opp.CreatedDate >= Constants.OPP_TYPE_MISMATCH_DATE)
    ) {
      if (
        !opp.Skip_Validations__c &&
        isActive &&
        OpportunityHelper.convertRecordTypeToPricebook(oppRecordType) !=
        oppPricebook
      ) {
        opp.Pricebook2Id.addError(
          'Please select Record Type as ' +
            OpportunityHelper.convertRecordTypeToPricebook(oppRecordType) +
            ' as this opportunity is of type: ' +
            oppRecordType
        );
      }
    }

    // Original Booking Amount is sum of non Revisied products
    List<OpportunityLineItem> products = [
      SELECT
        id,
        Flight_Start_Date__c,
        Flight_End_Date__c,
        CPM__c,
        UnitPrice,
        Product2.Id,
        Product2.Name,
        MinImpressions__c,
        Type__c
      FROM OpportunityLineItem
      WHERE OpportunityId = :opp.Id
    ];

    Decimal originalBookingAmount = 0.0;
    for (OpportunityLineItem li : products) {
      if (li.Type__c != Constants.PRODUCT_TYPE_INCREMENTAL) {
        originalBookingAmount += li.UnitPrice;
      }
    }
    System.debug(
      'Opportunity Stage Change trigger Amount ' + originalBookingAmount
    );
    opp.Original_Booking_Amount__c = originalBookingAmount;

    if (!stages.containsKey(opp.StageName)) {
      System.debug('Unrecognised stage name. Ignoring.');
      continue;
    }

    String oldStage;
    if (Trigger.isUpdate) {
      oldStage = Trigger.oldMap.get(opp.Id).StageName;
      System.debug('Old stage' + oldStage);
      if (!stages.containsKey(oldStage)) {
        System.debug('Unrecognised stage name. Ignoring.');
        continue;
      }
      if ((oldStage == STAGE_CLOSED_WON && opp.StageName != STAGE_CLOSED_WON)) {
        User currentUser = [
          SELECT id, Name, UserRole.Name, Profile.Name
          FROM User
          WHERE id = :UserInfo.getUserId()
        ];
        if (
          !Constants.CLOSED_WON_ROLES.contains(currentUser.UserRole.Name) &&
          currentUser.UserRole.Name != null &&
          isActive
        ) {
          opp.Id.addError(
            'Please contact Customer Service to change the stage of a Closed Won opportunity'
          );
        }
      }
    }

    if (stages.get(opp.StageName) < stages.get(STAGE_VERBAL_CONFIRM)) {
      continue;
    }
    if (opp.StageName == Constants.STAGE_CLOSED_LOST) {
      continue;
    }
    // Check if Primary Billing Contact is populated

    if (
      opp.ChekParentRecordType__c == false &&
      isActive &&
      opp.Primary_Billing_Contact__c == null
    ) {
      opp.Primary_Billing_Contact__c.addError(
        'Please add Primary Billing Contact!'
      );
      continue;
    }

    // Check if Billing Level is set
    if (isActive && String.isEmpty(opp.Billing_Level__c)) {
      opp.Billing_Level__c.addError('Please add Billing Level!');
      continue;
    }

    // Check if Brand id and name are set
    System.debug('Opp Stage chnage trigger brand ' + oppPricebook);
    if (oppPricebook != SELF_SERVICE) {
      if (
        isActive &&
        String.isEmpty(opp.Brand_name__c) &&
        !opp.Skip_Validations__c
      ) {
        opp.Brand_name__c.addError(
          'Please add brand to the Opportunity. If you are creating a new Opp, please create it in a stage before "' +
            Constants.STAGE_VERBAL_CONFIRM +
            '".'
        );
        continue;
      }
      if (
        isActive &&
        String.isEmpty(opp.Brand_id__c) &&
        !opp.Skip_Validations__c
      ) {
        opp.Brand_id__c.addError(
          'Brand id is not set for the Opportunity. If you are creating a new Opp, please create it in a stage before "' +
            Constants.STAGE_VERBAL_CONFIRM +
            '".'
        );
        continue;
      }
    }

    String billingLevel = opp.Billing_Level__c;

    // Check if Agency is populated when billing level is Agency
    if (
      isActive &&
      billingLevel == BILLING_LEVEL_AGENCY &&
      opp.Agency__c == null
    ) {
      opp.Agency__c.addError(
        'Please set Agency in Opportunity as Billing Level is set to Agency.'
      );
      continue;
    }

    // Check if Primary Billing Contact is assigned correctly
    if (
      isActive &&
      opp.ChekParentRecordType__c == false &&
      opp.Primary_Billing_Contact__c != null
    ) {
      Contact primaryBillingContact = [
        SELECT AccountId
        FROM Contact
        WHERE Id = :opp.Primary_Billing_Contact__c
      ];

      Id billingAccountId = null;
      if (billingLevel == BILLING_LEVEL_AGENCY) {
        billingAccountId = opp.Agency__c;
      } else if (billingLevel == BILLING_LEVEL_ACCOUNT) {
        billingAccountId = opp.AccountId;
      } else {
        System.debug('Unhandled Case for Billing Level - Ignoring.');
        continue;
      }

      if (isActive && billingAccountId != primaryBillingContact.AccountId) {
        if (billingLevel == BILLING_LEVEL_AGENCY) {
          opp.Primary_Billing_Contact__c.addError(
            'Primary Billing Contact is not correctly associated with Opportunity Agency.'
          );
        } else {
          opp.Primary_Billing_Contact__c.addError(
            'Primary Billing Contact is not correctly associated with Opportunity Account.'
          );
        }
      }
    }

    // Check if products have flight start/end dates and cpm selected

    if (Trigger.isUpdate) {
      if (stages.get(oldStage) == stages.get(opp.StageName)) {
        System.debug('Skipping since stage was not changed');
        continue;
      }
    }

    if (
      stages.get(opp.StageName) < stages.get(Constants.STAGE_WAITING_ASSETS)
    ) {
      continue;
    }

    if (isActive && products.size() <= 0 && !opp.Skip_Validations__c) {
      opp.id.addError('Please add at least 1 product before Closed Won');
    }

    if (stages.get(opp.StageName) < stages.get(Constants.STAGE_CLOSED_WON)) {
      continue;
    }

    // Opp stage is closed won
    List<Opportunity_Seller__c> sellers = [
      SELECT id, Seller__r.id, Opportunity__r.id
      FROM Opportunity_Seller__c
      WHERE Opportunity__r.id = :opp.Id
    ];

    if (isActive && sellers.size() <= 0) {
      opp.id.addError(
        'Please add atleast 1 seller before going to Closed Stage.'
      );
    }
  }
}