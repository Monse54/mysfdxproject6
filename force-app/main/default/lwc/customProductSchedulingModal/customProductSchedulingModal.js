import { LightningElement, api, wire } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import createRevenueSchedules from "@salesforce/apex/CustomProductSchedulingController.createRevenueSchedules";
import updateSchedules from "@salesforce/apex/CustomProductSchedulingController.updateSchedules";
import OPP_STAGE from "@salesforce/schema/OpportunityLineItem.Opportunity.StageName";

const OPPORTUNITY_LINE_ITEM_FIELDS = [
  "OpportunityLineItem.Flight_Start_Date__c",
  "OpportunityLineItem.Flight_End_Date__c",
  "OpportunityLineItem.UnitPrice",
  "OpportunityLineItem.Days_in_Flight__c",
  OPP_STAGE
];
const CLOSED_WON = 'Closed Won';

export default class CustomProductSchedulingModal extends LightningElement {
  @api recordId;

  @wire(getRecord, {
    recordId: "$recordId",
    fields: OPPORTUNITY_LINE_ITEM_FIELDS
  })
  opportunityLineItem;

  startDate;
  endDate;
  revenue;
  installationPeriod = "Daily";
  scheduleType = "Divide";

  isModalOpen = false;
  hasRendered = false;
  showLoadingSpinner = false;

  openModal() {
    this.updateValues();
    this.isModalOpen = true;
    document.body.style.overflow = 'hidden';
  }

  closeModal() {
    this.isModalOpen = false;
    document.body.style.overflow = 'auto';
  }

  get installationPeriodOptions() {
    return [
      { label: "Daily", value: "Daily" },
      { label: "Weekly", value: "Weekly" },
      { label: "Monthly", value: "Monthly" },
      { label: "Quarterly", value: "Quarterly" },
      { label: "Yearly", value: "Yearly" }
    ];
  }

  get scheduleTypeOptions() {
    return [
      { label: "Divide Amount into multiple installments", value: "Divide" },
      { label: "Repeat Amount for each installment", value: "Repeat" }
    ];
  }

  updateValues() {
    this.startDate = this.opportunityLineItem.data.fields.Flight_Start_Date__c.value;
    this.endDate = this.opportunityLineItem.data.fields.Flight_End_Date__c.value;
    this.revenue = parseInt(
      this.opportunityLineItem.data.fields.UnitPrice.value,
      10
    );
  }

  handleChange(event) {
    const value = event.target.value;
    if (event.target.name === "StartDate") {
      this.startDate = value;
    } else if (event.target.name === "EndDate") {
      this.endDate = value;
    } else if (event.target.name === "Revenue") {
      this.revenue = value;
    } else if (event.target.name === "InstallationPeriod") {
      this.installationPeriod = value;
    } else if (event.target.name === "ScheduleType") {
      this.scheduleType = value;
    }
  }

  async submitDetails() {
    const oppStage = this.opportunityLineItem.data.fields.Opportunity.value.fields.StageName.value;
    const originalRevenue = parseInt(
      this.opportunityLineItem.data.fields.UnitPrice.value,
      10
    );
    
    if(oppStage == CLOSED_WON && this.revenue != originalRevenue){
      try{
        this.revenue = originalRevenue;
        await this.dispatchEvent(
          new ShowToastEvent({
            title: "Error creating schedules",
            message: "Can't change revenue since Opportunity is Closed Won",
            variant: "error"
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
      return;
    }
    this.showLoadingSpinner = true;
    return updateSchedules({
      opportunityLineItemId: this.recordId,
      startDate: this.startDate,
      endDate: this.endDate,
      revenue: this.revenue,
      installationPeriod: this.installationPeriod,
      scheduleType: this.scheduleType
    })
      .then(() => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: "Schedules Updated",
            variant: "success"
          })
        );

        // eslint-disable-next-line no-eval
        eval("$A.get('e.force:refreshView').fire();");
      })
      .catch((err) => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error creating schedules",
            message: err.body.message,
            variant: "error"
          })
        );
      })
      .finally(() => {
        this.showLoadingSpinner = false;
        this.closeModal();
      });
  }
}