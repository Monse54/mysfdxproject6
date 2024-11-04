import { LightningElement, api, track } from "lwc";
import getInsertionOrder from "@salesforce/apex/InsertionOrderLayoutController.getInsertionOrder";
import getLineItems from "@salesforce/apex/InsertionOrderLayoutController.getLineItems";

export default class InsertionOrderDetailsTab extends LightningElement {
  @api recordId;
  @track insertionOrderID;
  @track lineItems;

  connectedCallback() {
    getInsertionOrder({ opportunityId: this.recordId })
      .then((insertionOrder) => {
        this.insertionOrderID = insertionOrder && insertionOrder.Id;
        return getLineItems({ insertionOrderID: this.insertionOrderID });
      })
      .then((lineItems) => {
        this.lineItems = lineItems && lineItems.length ? lineItems : null;
      })
      .catch((err) => {
        console.error(err);
      });
  }
}