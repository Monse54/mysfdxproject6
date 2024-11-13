import { api, track } from "lwc";
import LightningModal from "lightning/modal";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import createCloneRecord from "@salesforce/apex/ShowOpportunityProductDataController.insertCloneRecord";
import fetchcloningdates from "@salesforce/apex/ShowOpportunityProductDataController.fetchcloningdates";
import getExactDateTime from "@salesforce/apex/ShowOpportunityProductDataController.getExactDateTime";

export default class CloneRecordEdit extends LightningModal {
  @api Fields;
  @api objectName;
  @api titleheader;
  @api layoutName;
  @api relatedrecId;
  @api recId;
  @api showEdit;
  productId;
  @track startInputDate;
  @track endInputDate;
  @track maxInputDate;
  errormessage;
  showerror = false;
  showspinner = false; // initialize spinner state
  handleStartDateChange(event) {
    this.startInputDate = event.target.value;
  }

  handleEndDateChange(event) {
    this.endInputDate = event.target.value;
  }

  handleMaxDateChange(event) {
    this.maxInputDate = event.target.value;
  }

  connectedCallback() {
    if (this.recId) {
      fetchcloningdates({ oliid: this.recId })
        .then((data) => {
          console.log("Fetched data:", JSON.stringify(data));
          if (data) {
            getExactDateTime({ dt: data[0].Start_Date__c })
              .then((startdate) => {
                this.startInputDate = startdate.toLocaleString("en-GB", { timeZone: "GMT" });

              });

            getExactDateTime({ dt: data[0].End_Date__c })
              .then((enddate) => {
                this.endInputDate = enddate.toLocaleString("en-GB", { timeZone: "GMT" });
                console.log("End Date:", this.endInputDate);
              });

            getExactDateTime({ dt: data[0].Max_Extension_Time__c })
              .then((maxdate) => {
                this.maxInputDate = maxdate.toLocaleString("en-GB", { timeZone: "GMT" });
                console.log("Max Extension Date:", this.maxInputDate);
              });
          }
        })
        .catch((error) => {
          console.error("Exception Received:", JSON.stringify(error.body.message));
          this.showerror = true;
          this.errormessage = error.body.message;
        });
    }
  }

  handleOkay() {
    this.close("canceled");
  }

  handleSubmit(event) {
    this.showspinner = true;
    event.preventDefault(); // stop the form from submitting

    const fields = event.detail.fields;
    fields.Start_Date__c = this.startInputDate;
    fields.End_Date__c = this.endInputDate;
    fields.Max_Extension_Time__c = this.maxInputDate;
    createCloneRecord({
      fieldSet: JSON.stringify(fields),
      oppId: this.relatedrecId,
      lineItemId: this.recId,
      bookingDate: fields.Product_Booking_Date__c // Ensure this field is passed correctly
    })
      .then((result) => {
        console.log("Record created successfully");
        this.close(result);
        this.showerror = false;
      })
      .catch((error) => {
        console.error("Error creating record:", JSON.stringify(error.body.message));
        this.showerror = true;
        this.errormessage = error.body.message;
      })
      .finally(() => {
        this.showspinner = false; // Hide spinner after operation completes
      });
  }

  showToast(message, title = "Error", variant = "error") {
    const event = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(event);
  }
}