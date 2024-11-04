import { LightningElement, api, track, wire } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import OPP_ID from "@salesforce/schema/Opportunity.Id";
import RECORD_TYPE from "@salesforce/schema/Opportunity.Pricebook2.Name";

const FIELDS = [OPP_ID, RECORD_TYPE];
const MANAGED_SERVICE = "Managed Service";
export default class ExternalLinksModal extends LightningElement {
  @api recordId;
  @track links = [];
  opportunityInfo;
  hasLinks = false;
  @wire(getRecord, {
    recordId: "$recordId",
    fields: FIELDS
  })
  wiredOppInfo({ error, data }) {
    if (data) {
      if (!data || !data.fields) {
        return;
      }
      this.opportunityInfo = data;
      const recordType =
        this.opportunityInfo.fields.Pricebook2.value.fields.Name.value;
      if (recordType === MANAGED_SERVICE) {
        // Links for managed service only
        this.links = [
          {
            id: 1,
            // URL: `http://dev13.alphonso.tv:4411/feasibility-studies?oppId=${encodeURIComponent(
            //   this.opportunityInfo.id
            // )}`,
            URL: `https://campaigns.alphonso.tv/feasibility-studies?oppId=${encodeURIComponent(
              this.opportunityInfo.id
            )}`,
            label: "Campaigns Feasibility"
          }
        ];
        this.hasLinks = true;
      }
    } else if (error) {
      console.error(error);
    }
  }
}