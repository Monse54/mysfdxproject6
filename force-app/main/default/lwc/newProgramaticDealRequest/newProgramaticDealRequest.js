import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import { getRecord } from "lightning/uiRecordApi";
import OPP_ID from "@salesforce/schema/OpportunityLineItem.Opportunity.Id";
import OLI_ID from "@salesforce/schema/OpportunityLineItem.Id";
import OPP_STAGE from "@salesforce/schema/OpportunityLineItem.Opportunity.StageName";
import OPP_RECORD_TYPE from "@salesforce/schema/OpportunityLineItem.Opportunity.Pricebook2.Name";

const FIELDS = [OLI_ID, OPP_ID, OPP_STAGE, OPP_RECORD_TYPE];
const CLOSED_WON = 'Closed Won';
const SELF_SERVICE_RECORD_TYPE = 'Self Service';
export default class NewProgramaticDealRequest extends NavigationMixin(
    LightningElement
) {
    
    @api recordId;
    pageData;
    isVisible; 

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
            console.log('Got ', this.pageData);
            this.isVisible = true;
            const oppRecordType = this.pageData.fields.Opportunity.value.fields.Pricebook2.value.fields.Name.value;
            console.log('record ', oppRecordType);
            if(oppRecordType !== SELF_SERVICE_RECORD_TYPE){
                this.isVisible = false;
                console.log('set ', oppRecordType);
            }
        } else if (error) {
            console.error(error);
        }
    }


    getMessageFromError(error) {
        if(error.message){
            return error.message;
        }
        if(error.body && error.body.message){
            return error.body.message;
        }
        return 'Some unkown error occured';
    }

    async clickEvent(evt) {
        const oliId = this.pageData.fields.Id.value;
        const oppId = this.pageData.fields.Opportunity.value.fields.Id.value;
        const oppStage = this.pageData.fields.Opportunity.value.fields.StageName.value;
        
        
        if(oppStage != CLOSED_WON){
            try{
                await this.dispatchEvent(
                    new ShowToastEvent({
                    title: "Note",
                    message: "Can't create New Programatic Deal request until Opportunity is 'Closed Won'.",
                    variant: "Error"
                    })
                );
            } catch (error) {
                await this.dispatchEvent(
                    new ShowToastEvent({
                    title: "Error",
                    message: this.getMessageFromError(error),
                    variant: "Error"
                    })
                );
            }
        }
        else {

            evt.preventDefault();
            evt.stopPropagation();
            const defaultValues = encodeDefaultFieldValues({
                Opportunity_Product__c: oliId,
                c__useRecordTypeCheck:'1',
                c__navigationLocation:'RELATED_LIST',
                c__nooverride:'1',
            });
            // Navigate to the Account home page
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'Programmatic_Deal_Request__c',
                    actionName: 'new',
                },
                state: {
                    defaultFieldValues: defaultValues
                }
            });
        }
    }
}