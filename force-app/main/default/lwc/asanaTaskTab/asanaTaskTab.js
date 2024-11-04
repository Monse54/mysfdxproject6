import { LightningElement, api, track } from 'lwc';
import getCase from "@salesforce/apex/CasesController.getCase";
import getFeasibility from "@salesforce/apex/FeasibilityController.getFeasibility";
import getProgrammaticDealRequest from "@salesforce/apex/ProgrammaticDealRequestController.getProgrammaticDealRequest";

export default class asanaTaskTab extends LightningElement {

  @api objectApiName;
  @api recordId;
  @track cases;
  @track taskUpdates;
  @track comment;
  @track taskId;

  options = {
      headers: {
          Authorization: "Bearer 1/164440441056927:6d50fa612a7cf24a32ff0a24889c8452"
      }
  };

  postComment() { 
      const commentBox = this.template.querySelector("lightning-input");
      const url = `https://app.asana.com/api/1.0/tasks/${this.taskId}/stories`;

      fetch(url, {
          method: "POST",
          body: JSON.stringify({
              data: {
                html_text: `<body>${commentBox.value}</body>`
              }
          }),
          headers: this.options.headers
      })
      .then(() => {
        commentBox.value = "";
        return this.getAsanaComments(this.taskId);
      })
      .then(res => {
        this.taskUpdates = res;
      })
      .catch(err => {
        console.log('this is err', err);
      });
  }

  connectedCallback() {
      this.getRecord(this.recordId, this.objectApiName)
      .then((currentRecord) => {
          const url = currentRecord[0].Asana_URL__c;
          if (!url) {
            return [];
          }
          const taskId = url.split('/').pop();
          if (taskId.match(/^[0-9]+$/) == null) {
            throw 'INCORRECT_TASK_ID';
          }
          
          this.taskId = taskId;
          return this.getAsanaComments(this.taskId);
      })
      .then(res => {
          this.taskUpdates = res;
      })
      .catch((err) => {
          console.error('error here', err);
      });
  }

  getAsanaComments(taskId) {
    const url = `https://app.asana.com/api/1.0/tasks/${this.taskId}/stories?opt_fields=html_text,created_by.name,created_at,resource_subtype`;
    return fetch(url, this.options)
    .then(res => res.json())
    .then(res => {
      return res.data.filter(e => e.resource_subtype === 'comment_added');
    })
  }

  getRecord(id, object) {
    if (object === 'Case') {
      return getCase({recordId: id})
    } else if (object === 'Feasibilty__c') {
      return getFeasibility({recordId: id});
    } else if (object === 'Programmatic_Deal_Request__c') {
      return getProgrammaticDealRequest({ recordId: id });
    }
  }
}