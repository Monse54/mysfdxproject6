import { LightningElement, api, track } from 'lwc';
import getCase from "@salesforce/apex/CasesController.getCase";

export default class CaseTaskTab extends LightningElement {
    @api recordId;
    @track cases;
    @track taskUpdates;
    @track comment;
    @track taskId;

    options = {
        headers: {
            Authorization: "Bearer 1/164440441056927:268c3549d61c70a56f194ee403195f6a"
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
        getCase({ caseId: this.recordId })
        .then((caseRecord) => {
            const url = caseRecord[0].Asana_URL__c;
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
      const url = `https://app.asana.com/api/1.0/tasks/${this.taskId}/stories`;
      return fetch(url, this.options)
      .then(res => res.json())
      .then(res => {
        return res.data.filter(e => e.resource_subtype === 'comment_added');
      })
    }
}