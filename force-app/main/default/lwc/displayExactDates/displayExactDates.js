import { LightningElement, track, api, wire } from 'lwc';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import START_DATE_FIELD from '@salesforce/schema/OpportunityLineItem.Start_Date__c';
import END_DATE_FIELD from '@salesforce/schema/OpportunityLineItem.End_Date__c';
import MAX_EXTENSION_TIME_FIELD from '@salesforce/schema/OpportunityLineItem.Max_Extension_Time__c';
import ID_FIELD from '@salesforce/schema/OpportunityLineItem.Id';
import getExactDateTime from "@salesforce/apex/ShowOpportunityProductDataController.getExactDateTime";

export default class DisplayExactDates extends LightningElement {
    @track startInputDate;
    @track endInputDate;
    @track maxInputDate;
    @api recordId;

    // Fetch the record data
    @wire(getRecord, { recordId: '$recordId', fields: [START_DATE_FIELD, END_DATE_FIELD, MAX_EXTENSION_TIME_FIELD] })
    wiredOpportunity({ error, data }) {
        if (data) {
            // Use Promises instead of await to handle the asynchronous Apex calls
            getExactDateTime({ dt: data.fields.Start_Date__c.value })
                .then((startdate) => {
                    this.startInputDate = startdate.toLocaleString('en-GB', { timeZone: 'GMT' });
                });
            getExactDateTime({ dt: data.fields.End_Date__c.value })
                .then((enddate) => {
                    this.endInputDate = enddate.toLocaleString('en-GB', { timeZone: 'GMT' });
                });
            getExactDateTime({ dt: data.fields.max_Extension_Time__c.value })
                .then((maxdate) => {
                    this.maxInputDate = maxdate.toLocaleString('en-GB', { timeZone: 'GMT' });
                });
        } else if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading record',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        }
    }

    handleStartDateChange(event) {
        this.startInputDate = event.target.value;
    }

    handleEndDateChange(event) {
        this.endInputDate = event.target.value;
    }

    handleMaxDateChange(event) {
        this.maxInputDate = event.target.value;
    }

    // Save the changes to the record
    saveChanges() {
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[START_DATE_FIELD.fieldApiName] = this.startInputDate;
        fields[END_DATE_FIELD.fieldApiName] = this.endInputDate;
        fields[MAX_EXTENSION_TIME_FIELD.fieldApiName] = this.maxInputDate;

        updateRecord({ fields })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Dates updated successfully',
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }
}