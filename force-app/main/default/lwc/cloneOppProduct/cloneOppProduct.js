import { LightningElement, api, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getRecord } from "lightning/uiRecordApi";

import OPP_ID from "@salesforce/schema/OpportunityLineItem.Opportunity.Id";
import PRODUCT_ID from "@salesforce/schema/OpportunityLineItem.Product2.Id";
import OLI_ID from "@salesforce/schema/OpportunityLineItem.Id";
import OPP_STAGE from "@salesforce/schema/OpportunityLineItem.Opportunity.StageName";
import BOOKING_AMOUNT from "@salesforce/schema/OpportunityLineItem.UnitPrice";
import FLIGHT_START_DATE from "@salesforce/schema/OpportunityLineItem.Flight_Start_Date__c";
import FLIGHT_END_DATE from "@salesforce/schema/OpportunityLineItem.Flight_End_Date__c";
import MIN_IMPRESSIONS from "@salesforce/schema/OpportunityLineItem.MinImpressions__c";
import CPM from "@salesforce/schema/OpportunityLineItem.CPM__c";
import VALUE from "@salesforce/schema/OpportunityLineItem.Value__c";
import FULL_NAME from "@salesforce/schema/OpportunityLineItem.Product_Full_Name__c";
import RETAIL_CPM from "@salesforce/schema/OpportunityLineItem.Retail_CPM__c";
import TYPE from "@salesforce/schema/OpportunityLineItem.Type__c";
import COUNTRY from "@salesforce/schema/OpportunityLineItem.Country__c";
import REASON from "@salesforce/schema/OpportunityLineItem.Reason__c";
import BOOKING_DATE from "@salesforce/schema/OpportunityLineItem.Product_Booking_Date__c";
import cloneOppProduct from "@salesforce/apex/OppProductHelper.cloneOppProduct";

const CLOSED_WON = "Closed Won";
const FIELDS = [
  OLI_ID,
  OPP_ID,
  OPP_STAGE,
  BOOKING_AMOUNT,
  FLIGHT_START_DATE,
  FLIGHT_END_DATE,
  MIN_IMPRESSIONS,
  CPM,
  VALUE,
  FULL_NAME,
  RETAIL_CPM,
  TYPE,
  COUNTRY,
  REASON,
  BOOKING_DATE,
  PRODUCT_ID
];

export default class CloneOppProduct extends NavigationMixin(LightningElement) {
  @api recordId;
  pageData;
  showLoadingSpinner = false;
  //   @wire(getObjectInfo, { objectApiName: "OpportunityLineItem" })
  //   oliObj;

  @wire(getRecord, {
    recordId: "$recordId",
    fields: FIELDS
  })
  wiredAccountInfo({ error, data }) {
    if (data) {
      if (!data || !data.fields) {
        return;
      }
      this.pageData = data;
      console.log("page data load", this.pageData);
    } else if (error) {
      console.error(error);
    }
  }

  getMessageFromError(error) {
    if (error.message) {
      return error.message;
    }
    if (error.body && error.body.message) {
      return error.body.message;
    }
    return "Some unkown error occured";
  }

  async clickEvent(evt) {
    console.log("IN click");
    const oppStage =
      this.pageData.fields.Opportunity.value.fields.StageName.value;
    console.log("page data", this.pageData);
    if (oppStage === CLOSED_WON) {
      await this.dispatchEvent(
        new ShowToastEvent({
          title: "Note",
          message:
            "Cannot duplicate product for Closed Won Opps. Please move the opp to a previous stage.",
          variant: "Error"
        })
      );
    } else {
      evt.preventDefault();
      evt.stopPropagation();
      const currentValues = {
        OpportunityId: this.pageData.fields.Opportunity.value.fields.Id.value,
        UnitPrice: this.pageData.fields.UnitPrice.value,
        Flight_Start_Date__c: this.pageData.fields.Flight_Start_Date__c.value,
        Flight_End_Date__c: this.pageData.fields.Flight_End_Date__c.value,
        MinImpressions__c: this.pageData.fields.MinImpressions__c.value,
        CPM__c: this.pageData.fields.CPM__c.value,
        Value__c: this.pageData.fields.Value__c.value,
        Product_Full_Name__c: this.pageData.fields.Product_Full_Name__c.value,
        Retail_CPM__c: this.pageData.fields.Retail_CPM__c.value,
        Type__c: this.pageData.fields.Type__c.value,
        Country__c: this.pageData.fields.Country__c.value,
        Reason__c: this.pageData.fields.Reason__c.value,
        Product_Booking_Date__c:
          this.pageData.fields.Product_Booking_Date__c.value,
        Product2Id: this.pageData.fields.Product2.value.fields.Id.value
      };
      try {
        this.showLoadingSpinner = true;
        const id = await cloneOppProduct({ oli: currentValues });
        this.showLoadingSpinner = false;
        // Navigate to the new product
        this[NavigationMixin.Navigate]({
          type: "standard__recordPage",
          attributes: {
            recordId: id,
            objectApiName: "OpportunityLineItem",
            actionName: "view"
          }
        });
      } catch (error) {
        console.log("Error", error);
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error cloning product",
            message: this.getMessageFromError(error),
            variant: "error"
          })
        );
        this.showLoadingSpinner = false;
      }
    }
  }
}