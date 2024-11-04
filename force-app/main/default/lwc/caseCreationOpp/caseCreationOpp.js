import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class CaseCreationOpp extends NavigationMixin(LightningElement) {
    @api recordId;

    @api invoke() {
        let temp = {
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Case',
                actionName: 'new'
            },
            state: {
                nooverride: '1',
                useRecordTypeCheck : '1',
                navigationLocation: 'RELATED_LIST',
                defaultFieldValues: "Opportunity__c=" +this.recordId
            }
        };
        this[NavigationMixin.Navigate](temp);
    }
}