/* 
@author         : Ramesh Kumar Gurusamy
@team           : CFG
@description    : Handler for OpportunityTrigger. 
@createdDate    : 22-Dec-2023
@testClass      : OpportunityTriggerTest
*/
public class OpportunityTriggerHandler {
  
  private static final String BILLING = 'Billing Contact';
  private static final String MAIN_BILLING = 'Main Point Of Contact (Primary)';
  private static final String AGENCY = 'Agency';
  private static final String ACCOUNT = 'Account';
  public static boolean updateFromOppTrigger = false;
  public static boolean isFirstRun = true;

    public static Trigger_Settings__c settings = Trigger_Settings__c.getInstance();
    public static Boolean isOpportunityTriggerActive = settings.Opportunity_Triggers_Active__c;
    public static Boolean isOppSellerTriggerActive = settings.Opp_Seller_Trigger_Active__c;
     
  public static void onBeforeInsert(List<Opportunity> triggerNew) {

    Set<String> accountIds = new Set<String>();
    for (Opportunity opp : triggerNew) {
        
      if (String.isBlank(opp.Primary_Billing_Contact__c)) {
        accountIds.add(opp.AccountId);
      }
    }
    System.debug('accountIds***' + accountIds);
    Map<String, Contact> pContactMap = new Map<String, Contact>();
    if (accountIds != null && !accountIds.isEmpty()) {
      pContactMap = getPrimaryContacts(accountIds);
    }
    System.debug('pContactMap***' + pContactMap);
    for (Opportunity opp : triggerNew) {
      if (String.isBlank(opp.Primary_Billing_Contact__c)) {
        Contact bContact = pContactMap.get(opp.AccountId);
        if (bContact != null) {
          opp.Primary_Billing_Contact__c = bContact.Id;
        }
      }
      if (isOpportunityTriggerActive &&
        String.isNotBlank(opp.Primary_Billing_Contact__c) &&
        String.isNotBlank(opp.Secondary_Billing_Contact__c) &&
        opp.Primary_Billing_Contact__c == opp.Secondary_Billing_Contact__c) {opp.addError('Primary Billing Contact and Secondary Billing Contact can not be same user.');}
      String rtName;
      if (!test.IsRunningTest()) {
        rtName = [
          SELECT id, DeveloperName
          FROM RecordType
          WHERE id = :opp.recordTypeId
        ]
        .DeveloperName;
      }
      if (rtName == 'Parent_Opportunity') {updateOpportunityNameBasedOnRecordType(opp);
      } else if (opp.Skip_Validations__c == false) {
        if (
          String.isNotBlank(opp.Account_Name__c) ||String.isNotBlank(opp.Primary_Agency_Name__c)
        ) {
          if (opp.Account_Name__c != opp.Primary_Agency_Name__c) {
            updateOpportunityNameBasedOnRecordType(opp); } else if (opp.Account_Name__c == opp.Primary_Agency_Name__c) { updateOpportunityNameBasedOnRecordType(opp);
          }
        }
        // if(String.isNotBlank(opp.Flight_Start_Date_Quarter__c)) { opp.Name = String.isNotBlank(opp.Name) ? opp.Name + ' - ' + opp.Flight_Start_Date_Quarter__c : opp.Flight_Start_Date_Quarter__c; }
        // if(String.isNotBlank(opp.Campaign_Name__c)) { opp.Name = opp.Name + ' - ' + opp.Campaign_Name__c; }
        if (String.isNotBlank(opp.Name) && opp.Name.length() > 120) { opp.Name = opp.Name.subString(0, 120);
        }
        opp.Billing_Level__c = ACCOUNT;
        //opp.Client_Direct__c = TRUE;
        if (
          (String.isNotBlank(opp.Account_Record_Type_Name__c) &&
          AGENCY.equalsIgnoreCase(opp.Account_Record_Type_Name__c)) ||
          String.isNotBlank(opp.Agency__c)
        ) {
          opp.Billing_Level__c = AGENCY;
          //opp.Client_Direct__c = FALSE;
          // opp.Holding_Company__c = opp.Agency_Parent_Account__c;
        }
      }
    }
  }

  public static void onAfterInsert(List<Opportunity> triggerNew) {

    System.debug('triggerNew***' + triggerNew);
    List<OpportunityContactRole> ocrList = new List<OpportunityContactRole>();
    List<Opportunity> oppsHasAgency = new List<Opportunity>();
    Map<String, Integer> contactMap = new Map<String, Integer>();
    for (Opportunity opp : triggerNew) {
      if (String.isNotBlank(opp.Primary_Billing_Contact__c)) {
        OpportunityContactRole ocr = createOCR(
          opp.Id,
          BILLING,
          opp.Primary_Billing_Contact__c
        );
        ocrList.add(ocr);
        contactMap.put(opp.Primary_Billing_Contact__c, 1);
      }
      if (String.isNotBlank(opp.Secondary_Billing_Contact__c)) {
        OpportunityContactRole ocr = createOCR(
          opp.Id,
          BILLING,
          opp.Secondary_Billing_Contact__c
        );
        ocrList.add(ocr);
        contactMap.put(opp.Secondary_Billing_Contact__c, 2);
      }
      if (String.isNotBlank(opp.Main_Point_Of_Contact_Primary__c)) {
        OpportunityContactRole ocr = createOCR(
          opp.Id,
          MAIN_BILLING,
          opp.Main_Point_Of_Contact_Primary__c
        );
        ocrList.add(ocr);
        contactMap.put(opp.Main_Point_Of_Contact_Primary__c, 0);
      }
      if (
        String.isNotBlank(opp.Agency__c) &&
        !opp.Skip_Validations__c // Added 2 conditions to handle parent opp
      ) {
        oppsHasAgency.add(opp);
      }
    }
    System.debug('ocrList***' + ocrList);
    if (ocrList != null && !ocrList.isEmpty()) {
      insert ocrList;
    }
    System.debug('contactMap***' + contactMap);
    if (contactMap != null && !contactMap.isEmpty()) {
      try {
        updateContacts(contactMap);
      } catch (Exception e) {
        System.debug('e***' + e);
          if(isOpportunityTriggerActive){
              triggerNew[0].addError('Error: ' + e.getMessage());
        	//triggerNew[0].addError('Email is mandatory for the linked billing contact(s).');
          }
      }
    }
    System.debug('oppsHasAgency***' + oppsHasAgency);
    if (oppsHasAgency != null && !oppsHasAgency.isEmpty()) {
      createAgency(oppsHasAgency);
    }
  }

  public static void onBeforeUpdate(
    
    List<Opportunity> triggerNew,
    Map<Id, Opportunity> triggerOldMap
  ) {

    validateOpportunitieswitoutProduct(Trigger.new);
 
    for (Opportunity opp : triggerNew) {

      Opportunity oldOpp = triggerOldMap.get(opp.Id);
         if(isOpportunityTriggerActive && opp.ChekParentRecordType__c == true && (opp.StageName == 'Closed Won' || opp.StageName == 'closed lost')  && oldopp.Amount != opp.Amount){
            opp.addError('Budget updates are not allowed once the Opportunity Stage is set to Closed Won or Closed Lost.');
        }
      if (
         isOpportunityTriggerActive &&
        String.isNotBlank(opp.Primary_Billing_Contact__c) &&
        String.isNotBlank(opp.Secondary_Billing_Contact__c) &&
        opp.Primary_Billing_Contact__c == opp.Secondary_Billing_Contact__c) { opp.addError('Primary Billing Contact and Secondary Billing Contact can not be same user.');
      }
      if (
        oldOpp != null &&
        opp != null &&
        (oldOpp.AccountId != opp.AccountId ||
        oldOpp.Agency__c != opp.Agency__c) ) { opp.Billing_Level__c = ACCOUNT;
        //opp.Client_Direct__c = TRUE;
        if (
          (String.isNotBlank(opp.Account_Record_Type_Name__c) &&
          AGENCY.equalsIgnoreCase(opp.Account_Record_Type_Name__c)) ||
          String.isNotBlank(opp.Agency__c)
        ) {
          opp.Billing_Level__c = AGENCY;
          //opp.Client_Direct__c = FALSE;
          opp.Holding_Company__c = opp.Agency_Parent_Account__c;
        }
      }
      String rtName;
      if (!test.IsRunningTest()) {
        rtName = [
          SELECT id, DeveloperName
          FROM RecordType
          WHERE id = :opp.recordTypeId
        ]
        .DeveloperName;
      }
      if (rtName == 'Parent_Opportunity') { updateOpportunityNameBasedOnRecordType(opp);
      } else if (
        (opp.Agency_RecordName__c != oldOpp.Agency_RecordName__c ||
        opp.Name != oldOpp.Name ||
        oldOpp.Agency__c != opp.Agency__c ||
        oldOpp.AccountId != opp.AccountId ||
        oldOpp.Flight_Start_Date__c != opp.Flight_Start_Date__c ||
        oldOpp.Campaign_Name__c != opp.Campaign_Name__c ||
        oldOpp.Flight_End_Date__c != opp.Flight_End_Date__c ||
        oldOpp.Primary_Agency_Name__c != opp.Primary_Agency_Name__c ||
        opp.PMX_Lift__c != oldOpp.PMX_Lift__c) && !opp.Skip_Validations__c
      ) {
        if (
          String.isNotBlank(opp.Account_Name__c) || String.isNotBlank(opp.Primary_Agency_Name__c)
        ) {
          if (opp.Account_Name__c != opp.Primary_Agency_Name__c) {
            updateOpportunityNameBasedOnRecordType(opp); } else if (opp.Account_Name__c == opp.Primary_Agency_Name__c) {   updateOpportunityNameBasedOnRecordType(opp); }
        }

        //if(String.isNotBlank(opp.Flight_Start_Date_Quarter__c)) { opp.Name = String.isNotBlank(opp.Name) ? opp.Name + ' - ' + opp.Flight_Start_Date_Quarter__c : opp.Flight_Start_Date_Quarter__c; }
        //if(String.isNotBlank(opp.Campaign_Name__c)) { opp.Name = String.isNotBlank(opp.Name) ? opp.Name + ' - ' + opp.Campaign_Name__c : opp.Campaign_Name__c; }
      }
      if (String.isNotBlank(opp.Name) && opp.Name.length() > 120) { opp.Name = opp.Name.subString(0, 120); }
    }
      
       if(isFirstRun){
         	OpportunityProductHelper.updateFlightDates(trigger.newMap.keySet(),true,(Map<Id,Opportunity>)trigger.newMap);
        isFirstRun = false;
      }
      
  }

  public static void onAfterUpdate(
    List<Opportunity> triggerNew,
    Map<Id, Opportunity> triggerNewmap,
    Map<Id, Opportunity> triggerOldMap
  ) {
    List<OpportunityContactRole> ocrList = [
      SELECT Id, ContactId, OpportunityId, Role, IsPrimary
      FROM OpportunityContactRole
      WHERE OpportunityId IN :triggerNewmap.keyset()
    ];
    set<Id> ids = new set<Id>();
    System.debug('ocrList***' + ocrList);
    List<OpportunityContactRole> ocrToCreate = new List<OpportunityContactRole>();
    Map<String, OpportunityContactRole> ocrToUpdate = new Map<String, OpportunityContactRole>();
    Map<String, OpportunityContactRole> ocrToDelete = new Map<String, OpportunityContactRole>();
    List<Opportunity> oppsHasAgency = new List<Opportunity>();
    List<Opportunity> oppsRemovedAgency = new List<Opportunity>();
    Map<String, Integer> contactMap = new Map<String, Integer>();
    Map<String, Integer> contactMapDelete = new Map<String, Integer>();
    for (Opportunity opp : triggerNew) {
      Opportunity oldOpp = triggerOldMap.get(opp.Id);
      if (
        String.isNotBlank(opp.Agency__c) && opp.Agency__c != oldOpp.Agency__c ) { oppsHasAgency.add(opp);
      } else if (
        String.isBlank(opp.Agency__c) && opp.Agency__c != oldOpp.Agency__c) {  oppsRemovedAgency.add(oldOpp);
      }
        if(opp.Flight_Start_Date__c != oldopp.Flight_Start_Date__c || opp.Flight_End_Date__c != oldopp.Flight_End_Date__c){
            ids.add(opp.id); 
        }
      if (
        String.isNotBlank(opp.Primary_Billing_Contact__c) &&
        String.isNotBlank(oldOpp.Primary_Billing_Contact__c) &&
        opp.Primary_Billing_Contact__c != oldOpp.Primary_Billing_Contact__c
      ) {
        for (OpportunityContactRole ocr : ocrList) {
          if (
            ocr.OpportunityId == opp.Id &&
            BILLING.equalsIgnoreCase(ocr.Role) &&
            ocr.ContactId == oldOpp.Primary_Billing_Contact__c
          ) {
            OpportunityContactRole ocrNew = new OpportunityContactRole();
            ocrNew.Id = ocr.Id;
            ocrNew.ContactId = opp.Primary_Billing_Contact__c;
            ocrToUpdate.put(ocr.Id, ocrNew);
            contactMap.put(opp.Primary_Billing_Contact__c, 1);
          }
        }
      } else if (
        opp.Primary_Billing_Contact__c != oldOpp.Primary_Billing_Contact__c &&
        String.isBlank(opp.Primary_Billing_Contact__c) &&
        String.isNotBlank(oldOpp.Primary_Billing_Contact__c)
      ) {
        for (OpportunityContactRole ocr : ocrList) {
          if (
            ocr.OpportunityId == opp.Id &&
            BILLING.equalsIgnoreCase(ocr.Role) &&
            ocr.ContactId == oldOpp.Primary_Billing_Contact__c
          ) {
            ocrToDelete.put(ocr.Id, ocr);
            contactMapDelete.put(ocr.ContactId, 1);
          }
        }
      } else if (
        opp.Primary_Billing_Contact__c != oldOpp.Primary_Billing_Contact__c &&
        String.isNotBlank(opp.Primary_Billing_Contact__c) &&
        String.isBlank(oldOpp.Primary_Billing_Contact__c)
      ) {
        OpportunityContactRole ocr = createOCR(
          opp.Id,
          BILLING,
          opp.Primary_Billing_Contact__c
        );
        ocrToCreate.add(ocr);
        contactMap.put(opp.Primary_Billing_Contact__c, 1);
      }
      if (
        String.isNotBlank(opp.Secondary_Billing_Contact__c) &&
        String.isNotBlank(oldOpp.Secondary_Billing_Contact__c) &&
        opp.Secondary_Billing_Contact__c != oldOpp.Secondary_Billing_Contact__c
      ) {
        for (OpportunityContactRole ocr : ocrList) {
          if (
            ocr.OpportunityId == opp.Id &&
            BILLING.equalsIgnoreCase(ocr.Role) &&
            ocr.ContactId == oldOpp.Secondary_Billing_Contact__c
          ) {
            OpportunityContactRole ocrNew = new OpportunityContactRole();
            ocrNew.Id = ocr.Id;
            ocrNew.ContactId = opp.Secondary_Billing_Contact__c;
            ocrToUpdate.put(ocr.Id, ocrNew);
            contactMap.put(opp.Secondary_Billing_Contact__c, 2);
          }
        }
      } else if (
        opp.Secondary_Billing_Contact__c !=
        oldOpp.Secondary_Billing_Contact__c &&
        String.isBlank(opp.Secondary_Billing_Contact__c) &&
        String.isNotBlank(oldOpp.Secondary_Billing_Contact__c)
      ) {
        for (OpportunityContactRole ocr : ocrList) {
          if (
            ocr.OpportunityId == opp.Id &&
            BILLING.equalsIgnoreCase(ocr.Role) &&
            ocr.ContactId == oldOpp.Secondary_Billing_Contact__c
          ) {
            ocrToDelete.put(ocr.Id, ocr);
            contactMapDelete.put(ocr.ContactId, 2);
          }
        }
      } else if (
        opp.Secondary_Billing_Contact__c !=
        oldOpp.Secondary_Billing_Contact__c &&
        String.isBlank(oldOpp.Secondary_Billing_Contact__c) &&
        String.isNotBlank(Opp.Secondary_Billing_Contact__c)
      ) {
        OpportunityContactRole ocr = createOCR(
          opp.Id,
          BILLING,
          opp.Secondary_Billing_Contact__c
        );
        ocrToCreate.add(ocr);
        contactMap.put(opp.Secondary_Billing_Contact__c, 2);
      }
      if (
        String.isNotBlank(opp.Main_Point_Of_Contact_Primary__c) &&
        String.isNotBlank(oldOpp.Main_Point_Of_Contact_Primary__c) &&
        opp.Main_Point_Of_Contact_Primary__c !=
        oldOpp.Main_Point_Of_Contact_Primary__c) { for (OpportunityContactRole ocr : ocrList) {          if (
            ocr.OpportunityId == opp.Id &&
            MAIN_BILLING.equalsIgnoreCase(ocr.Role) &&
            ocr.ContactId == oldOpp.Main_Point_Of_Contact_Primary__c
          ) {
            OpportunityContactRole ocrNew = new OpportunityContactRole();
            ocrNew.Id = ocr.Id;
            ocrNew.ContactId = opp.Main_Point_Of_Contact_Primary__c;
            ocrToUpdate.put(ocr.Id, ocrNew);
            contactMap.put(opp.Main_Point_Of_Contact_Primary__c, 0);
          }
        }
      } else if (
        opp.Main_Point_Of_Contact_Primary__c !=
        oldOpp.Main_Point_Of_Contact_Primary__c &&
        String.isBlank(opp.Main_Point_Of_Contact_Primary__c) &&
        String.isNotBlank(oldOpp.Main_Point_Of_Contact_Primary__c)
      ) {
        for (OpportunityContactRole ocr : ocrList) {
          if (
            ocr.OpportunityId == opp.Id &&
            MAIN_BILLING.equalsIgnoreCase(ocr.Role) &&
            ocr.ContactId == oldOpp.Main_Point_Of_Contact_Primary__c
          ) {
            ocrToDelete.put(ocr.Id, ocr);
            contactMapDelete.put(ocr.ContactId, 0);
          }
        }
      } else if (
        opp.Main_Point_Of_Contact_Primary__c !=
        oldOpp.Main_Point_Of_Contact_Primary__c && String.isBlank(oldOpp.Main_Point_Of_Contact_Primary__c) && String.isNotBlank(Opp.Main_Point_Of_Contact_Primary__c) ) {  OpportunityContactRole ocr = createOCR(
          opp.Id,
          MAIN_BILLING,
          opp.Main_Point_Of_Contact_Primary__c
        );
        ocrToCreate.add(ocr);
        contactMap.put(opp.Main_Point_Of_Contact_Primary__c, 0);
      }
    }
    
	 
      
      
    System.debug('ocrToCreate***' + ocrToCreate);
    if (ocrToCreate != null && !ocrToCreate.isEmpty()) {
      insert ocrToCreate;
    }
    System.debug('ocrToUpdate***' + ocrToUpdate);
    if (ocrToUpdate != null && !ocrToUpdate.isEmpty()) {
      updateFromOppTrigger = true;
      update ocrToUpdate.values();
    }
    System.debug('ocrToDelete***' + ocrToDelete);
    if (ocrToDelete != null && !ocrToDelete.isEmpty()) {
      updateFromOppTrigger = true;
      delete ocrToDelete.values();
    }
    System.debug('contactMap***' + contactMap);
    if (contactMap != null && !contactMap.isEmpty()) {
      try {
        updateContacts(contactMap);
      } catch (Exception e) {
        System.debug('e***' + e);
          if(isOpportunityTriggerActive){
              triggerNew[0].addError('Error: ' + e.getMessage());
        	//triggerNew[0].addError('Email is mandatory for the linked billing contact(s).');
          }
      }
    }
    System.debug('contactMapDelete***' + contactMapDelete);
    if (contactMapDelete != null && !contactMapDelete.isEmpty()) {
      updateContactsDelete(contactMapDelete);
    }
    System.debug('oppsHasAgency***' + oppsHasAgency);
    if (oppsHasAgency != null && !oppsHasAgency.isEmpty()) {createAgency(oppsHasAgency);
    }
    System.debug('oppsRemovedAgency***' + oppsRemovedAgency);
    if (oppsRemovedAgency != null && !oppsRemovedAgency.isEmpty()) {deleteAgency(oppsRemovedAgency);
    }
  }

  public static OpportunityContactRole createOCR(
    String oppId,
    String roleName,
    String contactId
  ) {
    OpportunityContactRole ocr = new OpportunityContactRole();
    ocr.OpportunityId = oppId;
    ocr.Role = roleName;
    ocr.ContactId = contactId;
    return ocr;
  }

  // Link agency and account.
  public static void createAgency(List<Opportunity> opps) {
    System.debug('***createAgency***');
    List<Agency__c> agencyToBeCreated = new List<Agency__c>();
    for (Opportunity opp : opps) {
      List<Agency__c> agencys = [
        SELECT Id
        FROM Agency__c
        WHERE Agency__c = :opp.Agency__c AND Account__c = :opp.AccountId
      ];
      System.debug('agencys***' + agencys);
      if (agencys == null || agencys.isEmpty()) {
        Agency__c agencyNew = new Agency__c();
        agencyNew.Agency__c = opp.Agency__c;
        agencyNew.Account__c = opp.AccountId;
        agencyToBeCreated.add(agencyNew);
      }
    }
    System.debug('agencyToBeCreated***' + agencyToBeCreated);
    if (agencyToBeCreated != null && !agencyToBeCreated.isEmpty()) {
      insert agencyToBeCreated;
    }
  }

  // Link agency and account.
  public static void deleteAgency(List<Opportunity> opps) {
    System.debug('***deleteAgency***');
    List<Agency__c> agencyToBeDeleted = new List<Agency__c>();
    for (Opportunity opp : opps) {
      List<Agency__c> agencys = [
        SELECT Id
        FROM Agency__c
        WHERE Agency__c = :opp.Agency__c AND Account__c = :opp.AccountId
      ];
      System.debug('agencys***' + agencys);
      if (agencys != null && !agencys.isEmpty()) {
        agencyToBeDeleted.addAll(agencys);
      }
    }
    System.debug('agencyToBeDeleted***' + agencyToBeDeleted);
    if (agencyToBeDeleted != null && !agencyToBeDeleted.isEmpty()) {
      delete agencyToBeDeleted;
    }
  }

  // Update the checkbox based on primary or seconday billing contacts.
  public static void updateContacts(Map<String, Integer> contactMap) {
    System.debug('***updateContacts***');
    Map<String, Contact> contactUpdateMap = new Map<String, Contact>();
    for (String contactId : contactMap.keySet()) {
      Integer count = contactMap.get(contactId);
      Contact contact = new Contact();
      contact.Id = contactId;
      if (count == 1) {
        contact.Is_Billing_Contact__c = true;
      } else if (count == 2) {
        contact.Is_Secondary_Billing_Contact__c = true;
      }
      contactUpdateMap.put(contactId, contact);
    }
    System.debug('contactUpdateMap***' + contactUpdateMap);
    if (contactUpdateMap != null && !contactUpdateMap.isEmpty()) {
      update contactUpdateMap.values();
    }
  }

  // Update the checkbox based on primary or seconday billing contacts on removal.
  public static void updateContactsDelete(Map<String, Integer> contactMap) {
    System.debug('***updateContactsDelete***');
    Map<String, Contact> contactUpdateMap = new Map<String, Contact>();
    for (String contactId : contactMap.keySet()) {
      Integer count = contactMap.get(contactId);
      Contact contact = new Contact();
      contact.Id = contactId;
      contact.Is_Billing_Contact__c = false;
      contact.Is_Secondary_Billing_Contact__c = false;
      contactUpdateMap.put(contactId, contact);
    }
    System.debug('contactUpdateMap***' + contactUpdateMap);
    if (contactUpdateMap != null && !contactUpdateMap.isEmpty()) {
      update contactUpdateMap.values();
    }
  }

  // Get primary contacts by accountIds.
  public static Map<String, Contact> getPrimaryContacts(
    Set<String> accountIds
  ) {
    System.debug('***getPrimaryContacts***');
    Map<String, Contact> contactMap = new Map<String, Contact>();
    List<Contact> contacts = [
      SELECT Id, Name, AccountId
      FROM Contact
      WHERE AccountId IN :accountIds AND Is_Billing_Contact__c = TRUE
      ORDER BY LastModifiedDate DESC
    ];
    System.debug('contacts***' + contacts);
    if (contacts != null && !contacts.isEmpty()) {
      for (Contact contact : contacts) {
        contactMap.put(contact.AccountId, contact);
      }
    }
    System.debug('contactMap***' + contactMap);
    return contactMap;
  }

  public static void updateOpportunityNameBasedOnRecordType(Opportunity opp) {
    String rtName = Schema.SObjectType.Opportunity.getRecordTypeInfosById()
      .get(opp.RecordTypeId)
      .getDeveloperName();
    System.debug(rtName);

    String pmxValue = (opp.PMX_Lift__c != null && opp.PMX_Lift__c == 'Yes')? 'Publicis PMX lift': null;
   // String priagencyname = (opp.Primary_Agency_Name__c == 'Apex Exchange' ||opp.Primary_Agency_Name__c == 'Publicis PMX') ? 'Publicis PMX lift' : null;
    if (rtName == 'Parent_Opportunity') { String holdingCompanyName = (opp.Holding_Company_Name__c != null) ? opp.Holding_Company_Name__c : '';      String accountName = (opp.Account_Name__c != null)   ? opp.Account_Name__c    : '';  String primaryAgencyName = (opp.Primary_Agency_Name__c != null)  ? opp.Primary_Agency_Name__c   : '';
      String campaignName = (opp.Campaign_Name__c != null)
        ? opp.Campaign_Name__c
        : '';
      String contractStartFormatted = (opp.Contract_Start__c != null)
        ? DateTime.newInstance(
              opp.Contract_Start__c,
              Time.newInstance(0, 0, 0, 0)
            )
            .format('MM/dd/yyyy')
        : '';
      String contractEndFormatted = (opp.Contract_End__c != null)
        ? DateTime.newInstance(
              opp.Contract_End__c,
              Time.newInstance(0, 0, 0, 0)
            )
            .format('MM/dd/yyyy')
        : '';

      opp.Name = 'Parent Opportunity';

      if (holdingCompanyName != '') {
        opp.Name += ' - ' + holdingCompanyName;
      }
      if (accountName != '') {
        opp.Name += ' - ' + accountName;
      }
      if (primaryAgencyName != '') {
        opp.Name += ' - ' + primaryAgencyName;
      }
      if (campaignName != '') {
        if (
          opp.Primary_Agency_Name__c == 'Apex Exchange' ||
          opp.Primary_Agency_Name__c == 'Publicis PMX'
        ) {
          opp.Name += ' - ' + 'Publicis PMX lift';
        }
        opp.Name += ' - ' + campaignName;
      }
      if (contractStartFormatted != '') {
        opp.Name += ' - ' + contractStartFormatted;
      }
      if (contractEndFormatted != '') {
        opp.Name += ' - ' + contractEndFormatted;
      }
    } else if (rtName == 'Self_Service') { opp.Name = (opp.Account_Name__c != null ? opp.Account_Name__c + '_' : '') + (opp.Primary_Agency_Name__c != null ? opp.Primary_Agency_Name__c + '_' : '') +   (opp.Campaign_Name__c != null ? opp.Campaign_Name__c + '_' : '');
      if (opp.Account_Name__c == opp.Primary_Agency_Name__c) {
        opp.Name =
          (opp.Account_Name__c != null ? opp.Account_Name__c + ' ' : '') +
          (opp.Campaign_Name__c != null ? opp.Campaign_Name__c + ' ' : '');
      }
    } else if (
      rtName != 'Self_Service' &&
      rtName != 'One_Managed_Service' &&   rtName != 'Three_Corporate') { opp.Name =(opp.Account_Name__c != null ? opp.Account_Name__c + '_' : '') +   (opp.Primary_Agency_Name__c != null  ? opp.Primary_Agency_Name__c + '_'  : '')  +   (opp.Campaign_Name__c != null ? opp.Campaign_Name__c : '') +  '_' +  (opp.Flight_Start_Date__c != null  ? DateTime.newInstance( opp.Flight_Start_Date__c,Time.newInstance(0, 0, 0, 0)).format('M/d/yy') + ' - '   : '') +
        (opp.Flight_End_Date__c != null
          ? DateTime.newInstance(
                opp.Flight_End_Date__c,
                Time.newInstance(0, 0, 0, 0)
              )
              .format('M/d/yy')
          : '');
      if (opp.Account_Name__c == opp.Primary_Agency_Name__c) {
        opp.Name = opp.Name =
          (opp.Account_Name__c != null ? opp.Account_Name__c + '_' : '') +
          (opp.Campaign_Name__c != null ? opp.Campaign_Name__c + '_' : '') +
          (opp.Flight_Start_Date__c != null
            ? DateTime.newInstance(
                  opp.Flight_Start_Date__c,
                  Time.newInstance(0, 0, 0, 0)
                )
                .format('M/d/yy') + ' - '
            : '') +
          (opp.Flight_End_Date__c != null
            ? DateTime.newInstance(
                  opp.Flight_End_Date__c,
                  Time.newInstance(0, 0, 0, 0)
                )
                .format('M/d/yy')
            : '');
      }
    } else if (rtName == 'One_Managed_Service' || rtName == 'Three_Corporate') {
      if (opp.Account_Name__c == opp.Primary_Agency_Name__c) { opp.Name = (opp.Account_Name__c != null ? opp.Account_Name__c + '_' : '') +   (opp.Agency_RecordName__c != null? opp.Agency_RecordName__c + '_'  : '') +  (pmxValue != null ? pmxValue + '_' : '')  +   (opp.Campaign_Name__c != null ? opp.Campaign_Name__c + '_' : '') +    (opp.Flight_Start_Date__c != null ? DateTime.newInstance( opp.Flight_Start_Date__c, Time.newInstance(0, 0, 0, 0) ).format('M/d/yy') + ' - '  : '') +
          (opp.Flight_End_Date__c != null
            ? DateTime.newInstance(
                  opp.Flight_End_Date__c,
                  Time.newInstance(0, 0, 0, 0)
                )
                .format('M/d/yy')
            : '');
      } else {
        opp.Name =
          (opp.Account_Name__c != null ? opp.Account_Name__c + '_' : '') +
          (opp.Primary_Agency_Name__c != null
            ? opp.Primary_Agency_Name__c + '_'   : '') +
          (opp.Agency_RecordName__c != null   ? opp.Agency_RecordName__c + '_'   : '') +
          (pmxValue != null ? pmxValue + '_' : '') +
          (opp.Campaign_Name__c != null ? opp.Campaign_Name__c + '_' : '') +
          (opp.Flight_Start_Date__c != null
            ? DateTime.newInstance(
                  opp.Flight_Start_Date__c,
                  Time.newInstance(0, 0, 0, 0)
                )
                .format('M/d/yy') + ' - '   : '') +
          (opp.Flight_End_Date__c != null
            ? DateTime.newInstance(
                  opp.Flight_End_Date__c,
                  Time.newInstance(0, 0, 0, 0)
                )
                .format('M/d/yy')      : '');
      }
    }
  }
  public static void OnbeforeDelete(list<Opportunity> oldopportunity) {

    Id userId = UserInfo.getUserId();
    String userProfile = [
      SELECT Name
      FROM Profile
      WHERE Id IN (SELECT ProfileId FROM User WHERE Id = :userId)
    ]
    .Name;

    for (Opportunity opp : oldopportunity) {
      if (isOpportunityTriggerActive &&
        opp.has_been_Closed__c == true && userProfile != 'System Administrator') {  opp.addError( 'Deletion not allowed if stage was ever moved to Waiting on Assets - Closed Won or later stages.'  );
      }
    }
  }
  public static void validateOpportunitieswitoutProduct(
    List<Opportunity> opportunities
  ) {

	 String rtName = Schema.SObjectType.Opportunity.getRecordTypeInfosById()
      .get(opportunities[0].RecordTypeId)
      .getDeveloperName();
    System.debug(rtName);
    Set<Id> opportunityIdsToCheck = new Set<Id>();
    for (Opportunity opp : opportunities) {
      if (opp.Probability > 25) {
        opportunityIdsToCheck.add(opp.Id);
      }
    }

    Map<Id, Integer> opportunityProductCounts = new Map<Id, Integer>();
    if (!opportunityIdsToCheck.isEmpty()) {
      List<AggregateResult> results = [
        SELECT OpportunityId, COUNT(Id) productCount
        FROM OpportunityLineItem
        WHERE OpportunityId IN :opportunityIdsToCheck
        GROUP BY OpportunityId
      ];

      for (AggregateResult result : results) { opportunityProductCounts.put((Id) result.get('OpportunityId'), (Integer) result.get('productCount') );
      }
    }

    for (Opportunity opp : opportunities) {
      if (opp.Probability > 25) {
        Integer productCount = opportunityProductCounts.get(opp.Id);
        if (isOpportunityTriggerActive &&
          (productCount == null || productCount == 0) && rtName != 'Parent_Opportunity' && !test.IsRunningTest() && isOpportunityTriggerActive) {opp.addError('The opportunity must have at least one related Opportunity Product before changing to the stage ' +  opp.StageName );
        }
      }
    }
  }

  public static void onClone(List<Opportunity> newOpportunities) {
        
        List<Opportunity> lstARecords = newOpportunities;
        
        if(lstARecords.get(0).isClone()){
            lstARecords.get(0).cloned_id__c = lstARecords.get(0).getCloneSourceId();
        }
    }

}