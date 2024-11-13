import { api,track } from 'lwc';
import LightningModal from 'lightning/modal';
import getPricebook from '@salesforce/apex/ShowOpportunityProductDataController.getPricebook';
import getExactDateTime from "@salesforce/apex/ShowOpportunityProductDataController.getExactDateTime";
export default class ModalRecordEditForm extends LightningModal {
  @api Fields;
  @api objectName;
  @api titleheader;
  @api layoutName;
  @api relatedrecId;
  @api recId;
  @track productid;
  @api showEdit;
  showmodal = true;
  showspinner = false;
  hasError = false;
  errorMessage = '';
  errors; 
  pricebookId;
  @track startInputDate;
  @track endInputDate;
  @track maxInputDate;

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
        // Get a reference to the input element
        const inputField = this.template.querySelector('#combobox-input-1001');
        // Check if the element exists (to avoid errors)
        if (inputField) {
            // Hide the input field
            inputField.style.display = 'none';
        }

        this.Fields = JSON.parse((JSON.stringify(this.Fields)).replace("Product2Id","Product__c"));
    }
  closePopupSuccess(event) {
    this.close(event.detail.id);
  }

  closePopup(){
    this.close('canceled');
    
  }
   handleError(event) {
        // Handle error logic here
        this.hasError = true;
        this.errorMessage = event.detail.output.errors[0].message;
    }

   handleSubmit(event) {
        event.preventDefault(); // stop the form from submitting
        const fields = event.detail.fields;
        this.productid = fields.Product__c;
        fields.Start_Date__c = this.startInputDate;
        fields.End_Date__c = this.endInputDate;
        fields.Max_Extension_Time__c = this.maxInputDate;
        fields.Product2Id = this.productid; 
        //alert('this.productid fields.Product2Id'+fields.Product2Id);
        if(this.objectName == 'OpportunityLineItem'){
           this.showspinner = true;
           getPricebook({ oppId: this.relatedrecId , proId: fields.Product2Id })
          .then(result => {
            this.pricebookId = result;
            fields.Id = null;
            fields.OpportunityId = this.relatedrecId; 
            fields.PricebookEntryId =  this.pricebookId;
            this.template.querySelector('lightning-record-form').submit(fields);
            this.showspinner = false;
          })
          .catch(error => {
            console.error('Error:', error);
            this.showspinner = false;
            this.hasError = true;
            this.errorMessage = 'Product field is Mandatory and you can select only Active Products';
          });
        }else{
          fields.Opportunity_Product__c = this.relatedrecId;
           this.template.querySelector('lightning-record-form').submit(fields);
        }
       
    }
}