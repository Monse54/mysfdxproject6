import { api } from "lwc";
import LightningModal from "lightning/modal";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import createCloneRecord from "@salesforce/apex/ShowOpportunityProductDataController.insertCloneRecord";
export default class CloneRecordEdit extends LightningModal {
  @api Fields;
  @api objectName;
  @api titleheader;
  @api layoutName;
  @api relatedrecId;
  @api recId;
  @api showEdit;
  productId;
  errormessage;
  showerror = false;
  showspinner;
  handleOkay() {
    this.close("canceled");
  }

  handleSubmit(event) {
    this.showspinner = true;
    this.template
      .querySelectorAll("lightning-input-field")
      .forEach((element) => element.reportValidity());
    event.preventDefault(); // stop the form from submitting
    const fields = event.detail.fields;

    createCloneRecord({
      fieldSet: JSON.stringify(fields),
      oppId: this.relatedrecId,
      lineItemId: this.recId,
      bookingDate: fields.Product_Booking_Date__c
    })
      .then((result) => {
        //alert(result);
        console.log("Result Received");
        this.close(result);
        this.showerror = false;
        this.showspinner = false;
      })
      .catch((error) => {
        console.log("Exception Received : " + JSON.stringify(error.body.message));
        this.showerror = true;
        this.errormessage = error.body.message;
        this.showspinner = false;
      });
  }
}