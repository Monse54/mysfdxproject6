import { LightningElement, track, wire,api } from 'lwc';
import fetchCaseFieldSetData from '@salesforce/apex/CaseListByFieldSetCtrl.fetchCaseFieldSetData';
import getFieldSet from '@salesforce/apex/CaseListByFieldSetCtrl.getFieldSet';
//import { getRecord } from 'lightning/uiRecordApi';

export default class CaseListByFieldSet extends LightningElement {
    @api recordId;
    @track data;
    @track columns;
    @track error;
    
    
    @wire(getFieldSet, { sObjectName: 'Case', fieldSetName: 'CaseListlwcFieldSet' })
    wiredFields({ error, data }) {
        if (data) {
            data = JSON.parse(data);
            console.log(data);
            let cols = [];
            let col;
            data.forEach(currentItem => {
                if(currentItem.name=='CaseNumber')
                {
                    col = { label: currentItem.label, fieldName: currentItem.name,type: 'url',typeAttributes: {label: { fieldName: 'Number' },target: '_blank'} };
                }
                else{
                    col = { label: currentItem.label, fieldName: currentItem.name };
                }
                cols.push(col);
            });
            this.columns = cols;
        } else if (error) {
            console.log(error);
            this.error = error;
            this.columns = undefined;
        }
    }

    @wire(fetchCaseFieldSetData, {OppID:'$recordId'})
    wiredAccounts({ error, data }) {
        if (data) {
            this.data = data.map(row=>{
                const CaseNumber = `/lightning/r/${row.Id}/view`;
                const Number = row.CaseNumber;
                return {...row , CaseNumber,Number};
                })
            console.log(this.data);
        } else if (error) {
            console.log(error);
            this.error = error;
            this.data = undefined;
        }
    }

    get isColumnsDataAvailable() {
        return this.data && this.columns;
    }

    
}