import { LightningElement, track, api, wire } from "lwc";
import getProductdata from "@salesforce/apex/ShowOpportunityProductDataController.getOpportunityProductData";
import getOpportunityProductDataNonCacheable from "@salesforce/apex/ShowOpportunityProductDataController.getOpportunityProductDataNonCacheable";
import OpportunityProductReportId from "@salesforce/label/c.OpportunityProductReportId";
import getOpptyClosed from "@salesforce/apex/ShowOpportunityProductDataController.getOpptyClosed";
import deleteRecord from "@salesforce/apex/ShowOpportunityProductDataController.deleteRecord";
//import updateField from "@salesforce/apex/ShowOpportunityProductDataController.updateField";
import { refreshApex } from "@salesforce/apex";
import { RefreshEvent } from "lightning/refresh";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import Type__c from "@salesforce/schema/OpportunityLineItem.Type__c";
import PLACEMENT_TYPE_FIELD from "@salesforce/schema/OpportunityLineItem.Placement_Type__c";
import endDate from "@salesforce/schema/OpportunityLineItem.End_Date__c";
import stardate from "@salesforce/schema/OpportunityLineItem.Start_Date__c";
import bilingName from "@salesforce/schema/OpportunityLineItem.Product_Full_Name__c";
import placementcategory from "@salesforce/schema/OpportunityLineItem.Placement_Category__c";
import rate from "@salesforce/schema/OpportunityLineItem.Rate__c";
import IO_Impression_Goal from "@salesforce/schema/OpportunityLineItem.IO_Impression_Goal__c";
import Product_Family from "@salesforce/schema/OpportunityLineItem.Product_Family__c";
import RB_Extension_info__c from "@salesforce/schema/OpportunityLineItem.RB_Extension_Info__c";
import Max_Extension_Time__c from "@salesforce/schema/OpportunityLineItem.Max_Extension_Time__c";
import Country__c from "@salesforce/schema/OpportunityLineItem.Country__c";
import Device_Type__c from "@salesforce/schema/OpportunityLineItem.Device_Type__c";
import Audience_Targeting__c from "@salesforce/schema/OpportunityLineItem.Audience_Targeting__c";
import Audience_Segment_Details__c from "@salesforce/schema/OpportunityLineItem.Audience_Segment_Details__c";
import Frequency_Cap__c from "@salesforce/schema/OpportunityLineItem.Frequency_Cap__c";
import Day_Part__c from "@salesforce/schema/OpportunityLineItem.Day_Part__c";
import Product2Id from "@salesforce/schema/OpportunityLineItem.Product2Id";
import BETA_Program__c from "@salesforce/schema/OpportunityLineItem.BETA_Program__c";
import Original_Booking_Amount__c from "@salesforce/schema/OpportunityLineItem.Original_Booking_Amount__c";
import Rolling_Time_Zone__c from "@salesforce/schema/OpportunityLineItem.Rolling_Time_Zone__c";
import Product_Display_Name__c from "@salesforce/schema/OpportunityLineItem.IO_Product_Display_Name__c";
import Buy_Type__c from "@salesforce/schema/OpportunityLineItem.Buy_Type__c";
import PricebookEntryId from "@salesforce/schema/OpportunityLineItem.PricebookEntryId";
import Reason__c from "@salesforce/schema/OpportunityLineItem.Reason__c";
import Product_Booking_Date__c from "@salesforce/schema/OpportunityLineItem.Product_Booking_Date__c";

// OP fields
import Buy_Type from "@salesforce/schema/Operational_Placement__c.Rate__c";
import Start_Date__c from "@salesforce/schema/Operational_Placement__c.Start_Date__c";
import End_Date__c from "@salesforce/schema/Operational_Placement__c.End_Date__c";
import Placement_Display_Name__c from "@salesforce/schema/Operational_Placement__c.Placement_Display_Name__c";
import Original_Booking_Amount from "@salesforce/schema/Operational_Placement__c.Original_Booking_Amount__c";
import Total_Booking_Amount__c from "@salesforce/schema/Operational_Placement__c.Total_Booking_Amount__c";
import IO_Impression_Goal__c from "@salesforce/schema/Operational_Placement__c.IO_Impression_Goal__c";
import Audience_Segment_Details from "@salesforce/schema/Operational_Placement__c.Audience_Segment_Details__c";
import Audience_Targeting from "@salesforce/schema/Operational_Placement__c.Audience_Targeting__c";
import Frequency_Cap from "@salesforce/schema/Operational_Placement__c.Frequency_Cap__c";
import Native_WebOS_Units_App_Based_Exclusions__c from "@salesforce/schema/Operational_Placement__c.Native_WebOS_Units_App_Based_Exclusions__c";
import Day_Part from "@salesforce/schema/Operational_Placement__c.Daypart__c";
import ModalRecordEditForm from "c/modalRecordEditForm";
import cloneRecordEdit from "c/cloneRecordEdit";
import hasCustomPermission from "@salesforce/apex/ShowOpportunityProductDataController.hasNotEditButtonPermission";
import { getRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import ProfileName from '@salesforce/schema/User.Profile.Name';

export default class ShowOpportunityProductAndOperationalData extends NavigationMixin(
  LightningElement
) {
  @api flexipageRegionWidth = "CLASSIC";
  productdata = [];
  keyIndex = 0;
  keyIndex2 = 0;
  _recordId;
  userProfileName;
  noOfProduct;
  @track oppclosed = false;
  @api set recordId(value) {
    this._recordId = value;

    // do your thing right here with this.recordId / value
  }

  @wire(getRecord, { recordId: Id, fields: [ProfileName] })
    userDetails({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            if (data.fields.Profile.value != null) {
                this.userProfileName = data.fields.Profile.value.fields.Name.value;
            }
        }
    }

  get recordId() {
    return this._recordId;
  }

  reportId = OpportunityProductReportId;

  Fields = [
    Placement_Display_Name__c,
    Start_Date__c,
    End_Date__c,
    Buy_Type,
    Original_Booking_Amount,
    Total_Booking_Amount__c,
    IO_Impression_Goal__c,
    Audience_Segment_Details,
    Audience_Targeting,
    Frequency_Cap,
    Native_WebOS_Units_App_Based_Exclusions__c,
    Day_Part
  ];

  oPField = [
    Product_Family,
    bilingName,
    Product2Id,
    Product_Display_Name__c,
    PLACEMENT_TYPE_FIELD,
    placementcategory,
    Device_Type__c,
    Audience_Targeting__c,
    Type__c,
    Audience_Segment_Details__c,
    stardate,
    endDate,
    Country__c,
    Buy_Type__c,
    rate,
    Original_Booking_Amount__c,
    IO_Impression_Goal,
    Product_Booking_Date__c,
    Day_Part__c,
    Frequency_Cap__c,
    Rolling_Time_Zone__c,
    Reason__c,
    RB_Extension_info__c,
    Max_Extension_Time__c,
    BETA_Program__c
  ];

  /* @wire(getPicklistValues, { recordTypeId: "012000000000000AAA", fieldApiName: PRODUCT_TYPE_FIELD })
  productTypePicklistResults({ error, data }) {
    if (data) {
      this.product = data.values;
      this.error = undefined;
    } else if (error) {
      this.error = error;
      this.product = undefined;
    }
  }

   @wire(getPicklistValues, { recordTypeId: "012000000000000AAA", fieldApiName: PLACEMENT_TYPE_FIELD })
  placementTypePicklistResults({ error, data }) {
    if (data) {
      this.placementType = data.values;
      this.error = undefined;
    } else if (error) {
      this.error = error;
      this.placementType = undefined;
    }
  } */

  // placementType = [
  //   { label: 'ROS', value: 'ROS' },
  //   { label: 'Targeted RB', value: 'Targeted RB' },
  //   { label: 'Non-targeted RB', value: 'Non-targeted RB' },
  //   { label: 'Content Store RB', value: 'Content Store RB' },
  // ];

  // get product() {
  //   return [
  //     { label: 'LG CTV Native', value: 'LG CTV Native' },
  //     { label: 'LG CTV Content Network', value: 'LG CTV Content Network' },
  //     { label: 'LG CTV O&O', value: 'LG CTV O&O' },
  //     { label: 'Cross Device Display', value: 'Cross Device Display' },
  //     { label: 'Cross Device Video', value: 'Cross Device Video' },
  //     { label: 'Sponsored Search', value: 'Sponsored Search' },

  //   ];
  // }

  @track isSaveDisabled = false;
  @track isDeleteDisabled = false;

  @wire(hasCustomPermission)
  permissionCheck({ error, data }) {
    if (data) {
      console.error("data Permission: ", error);
      this.isSaveDisabled = data; // Disable button if permission is false
      this.isDeleteDisabled = data;
    } else if (error) {
      console.error("Error fetching permission: ", error);
      this.isSaveDisabled = false; // Handle error case
      this.isDeleteDisabled = false;
    }
  }

  @wire(getProductdata, { oppId: "$_recordId" }) getString1({ error, data }) {
    if (data) {
      console.log("wire method called");
      console.log("Data>>>>" + data);
      this.productdata = JSON.parse(data);
      this.noOfProduct = JSON.stringify(this.productdata.length);
      refreshApex(this.productdata);
    } else if (error) {
    }
  }

  connectedCallback() {
    getOpptyClosed({ oppId: this._recordId })
      .then((result) => {
        this.oppclosed = result;
        if (!this.isSaveDisabled) {
          this.isSaveDisabled = result;
        }

        console.log('User profile ' + this.userProfileName);
        if(this.userProfileName == 'System Administrator'){
          this.isDeleteDisabled = false;
        }else{
          if (!this.isDeleteDisabled) {
            this.isDeleteDisabled = result;
          }
        }
      })
      .catch((error) => {
        console.log("getting error while fetching OpptyClosed");
      });
  }

  showOrHideChildrenRows(event) {
    try {
      console.log(event);
      console.log(event.target);
      let rowId = event.target.dataset.rowid;
      console.log("rowId-->>" + rowId);
      let isExpanded = event.target.dataset.expanded;
      console.log("isExpanded-->>" + isExpanded);
      event.target.iconName = JSON.parse(isExpanded)
        ? "utility:chevronright"
        : "utility:chevrondown";
      console.log("event.target.iconName-->>" + event.target.iconName);
      event.target.dataset.expanded = JSON.stringify(!JSON.parse(isExpanded));
      console.log(
        "event.target.dataset.expanded-->>" + event.target.dataset.expanded
      );

      this.productdata = this.productdata.map((obj) => {
        console.log("obj.Id" + obj.Id);
        if (obj.Id == rowId && !JSON.parse(isExpanded)) {
          obj.rowStyle = "";
        }
        if (obj.Id == rowId && JSON.parse(isExpanded)) {
          obj.rowStyle = "slds-hide";
        }
        return obj;
      });
      console.log(this.orders);
    } catch (error) {
      console.log("error11-->>" + error);
    }
  }

  handleProductFamilyChange(event) {
    console.log("datasetId-->" + event.target.dataset.id);
    let value = event.target.value;
    this.productdata = this.productdata.map((obj) => {
      console.log("obj.Id" + obj.Id);
      if (obj.Id === event.target.dataset.id) {
        console.log("value" + obj.productFamily);
        console.log("Value-->>" + event.target.value);
        if (value == "Managed Service Impressions") {
          obj.isProductFamily = true;
        } else {
          obj.isProductFamily = false;
        }
      }

      // obj.rowStyle = "";
      return obj;
    });

    if (value != null) {
      updateField({
        fieldName: event.target.name,
        fieldValue: value,
        recordId: event.target.dataset.id
      })
        .then(() => {
          console.log("Record field updated successfully");
        })
        .catch((error) => {
          console.log(error);
          // Handle error
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Error",
              message: error.body.message,
              variant: "error"
            })
          );
        });
    }
  }

  // getUpdatedPlacementType() {
  //   return getPlacementType().filter(item => item.label !== 'ROS');
  // }

  handleInputChange(event) {
    console.log("Name-->" + event.target.name);
    console.log("Value-->>" + event.target.value);
    console.log("datasetId-->" + event.target.dataset.id);
    if (
      event.target.name == "Start_Date__c" ||
      event.target.name == "End_Date__c"
    ) {
      const selectedDate = new Date(event.target.value);
      const currentDate = new Date();

      if (selectedDate < currentDate) {
        event.target.setCustomValidity("Please select a future date.");
        return "error";
      } else {
        event.target.setCustomValidity("");
      }

      event.target.reportValidity();
    }

    // if (event.target.value != 'LG CTV Native') {

    //   this.placementType = this.placementType.filter(item => item.label === 'ROS');
    //   //item.placementType = 'ROS';

    // } else {
    //   this.placementType = [
    //     { label: 'ROS', value: 'ROS' },
    //     { label: 'Targeted RB', value: 'Targeted RB' },
    //     { label: 'Non-targeted RB', value: 'Non-targeted RB' },
    //     { label: 'Content Store RB', value: 'Content Store RB' },
    //   ];
    // }

    this.productdata = this.productdata.map((obj) => {
      console.log("obj.Id" + obj.Id);
      if (obj.Id === event.target.dataset.id) {
        if (
          event.target.value == "LG CTV Native" ||
          event.target.value == "Cross Device Display"
        ) {
          console.log("event.target.value>>>" + event.target.value);
          obj.MediaType = "Display";
        } else {
          obj.MediaType = "Video";
        }
        if (event.target.value !== "LG CTV Native") {
          obj.placementType = "ROS";
        }
      }
      return obj;
    });

    var finalValue;

    if (event.detail.selectedRecord)
      finalValue = event.detail.selectedRecord.Value;

    if (event.target.value) finalValue = event.target.value;

    console.log("finalValue-->" + finalValue);
    if (finalValue != null) {
      updateField({
        fieldName: event.target.name,
        fieldValue: finalValue,
        recordId: event.target.dataset.id
      })
        .then(() => {
          console.log("Record field updated successfully");
        })
        .catch((error) => {
          console.log(error);
          // Handle error
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Error",
              message: error.body.message,
              variant: "error"
            })
          );
        });
    }
  }

  confirmProductItemDelete(event) {
    this.tempId = event.target.dataset.id;
    if (confirm("Are you sure you want to delete this record?")) {
      deleteRecord({
        recordId: event.target.dataset.id,
        objectType: "OpportunityLineItem"
      })
        .then(() => {
          let temp = this.productdata.filter((item) => item.Id !== this.tempId);
          this.productdata = temp;
        })
        .catch((error) => {
          console.log("Error deleting record:", error);
          var strerr = error.body.message;
          /*if (strerr.includes("Delete")) {
            strerr =
              'Opportunity Products cannot be deleted if Opportunity is in "Waiting on Assets - Closed Won" or later stages.';
          }*/

          this.dispatchEvent(
            new ShowToastEvent({
              title: "Error",
              message: strerr,
              variant: "error"
            })
          );
        });
    }
  }
  confirmOpreationItemDelete(event) {
    let tempId = event.target.dataset.id;
    console.log("tempId" + tempId);
    if (confirm("Are you sure you want to delete this record?")) {
      deleteRecord({
        recordId: event.target.dataset.id,
        objectType: "Operational_Placement__c"
      })
        .then(() => {
          /*   this.productdata.some(item => {
               const childIndex = item.operationalPlacements.findIndex(child => child.Id === tempId);
               if (childIndex !== -1) {
                 console.log('>>>TTTT'+item.operationalPlacements);
                 item.operationalPlacements.splice(childIndex, 1);
                  console.log('>>>After Splice>>'+item.operationalPlacements);
               }
             }); */

          this.productdata = this.productdata.map((obj) => {
            console.log("obj.Id" + obj.Id);
            const childIndex = obj.operationalPlacements.findIndex(
              (child) => child.Id === tempId
            );
            if (childIndex !== -1) {
              obj.operationalPlacements.splice(childIndex, 1);
            }

            // obj.rowStyle = "";
            return obj;
          });
        })
        .catch((error) => {
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Error",
              message: error.body.message,
              variant: "error"
            })
          );
        });
    }
  }

  //To get the picklist values in container component
  fetchSelectedValues() {
    let selections = this.template.querySelector("c-mutli-select-picklist");
    console.log(selections);
    console.log("rowid" + selections.rowid);
  }
  async handleClone(event) {
    const itemId = event.target.dataset.id;

    const recordId = await cloneRecordEdit.open({
      size: "small",
      objectName: "OpportunityLineItem",
      Fields: this.oPField,
      titleheader: "Create Record",
      layoutName: "Opportunity Product Layout",
      recId: itemId,
      showEdit: false,
      relatedrecId: this.recordId
    });

    if (recordId != "canceled" && recordId != undefined) {
      await this.showSuccessToast(recordId);
    }

    /* insertClonedOrderItem({ lineitemId: itemId })
      .then(result => {
        setTimeout(() => {
          this.sortByName();
        }, 1000);

        getOpportunityProductDataNonCacheable({ oppId: this.recordId })
          .then(result => {
            console.log('Imperative method called');
            console.log('Data>>>>' + result);
            this.productdata = JSON.parse(result);
            this.dispatchEvent(new ShowToastEvent({
            title: 'Success',
            message: 'Your record is cloned ',
            variant: 'success'
          }));
          })
          .catch(error => {
            console.error('Error:', error);
          });

      })
      .catch(error => {
        console.error('Error cloning record:', error);
        // Handle error
        this.dispatchEvent(new ShowToastEvent({
          title: 'Error',
          message: error.body.message,
          variant: 'error'
        }));
      }); */
  }
  generateNewId() {
    return "id-" + Math.random().toString(36).substr(2, 9);
  }

  handler() {
    refreshApex(this.productdata);
    const field = event.target.dataset.field;
    const reverse = event.target.dataset.reverse === "true";

    this.productdata.sort(this.sortBy(field, reverse, null));
    // Toggle reverse attribute for next sort
    event.target.dataset.reverse = !reverse;
  }

  sortByName() {
    /* this.productdata = [...this.productdata].sort((a, b) => {
         const nameA = a.productFamily.toLowerCase();
         const nameB = b.productFamily.toLowerCase();
         if (nameA < nameB) return this.isAscending ? -1 : 1;
         if (nameA > nameB) return this.isAscending ? 1 : -1;
         return 0;
     });
     this.isAscending = !this.isAscending; // Toggle sorting order */

    getOpportunityProductDataNonCacheable({ oppId: this.recordId })
      .then((result) => {
        console.log("Imperative method called");
        console.log("Data>>>>" + result);
        this.productdata = JSON.parse(result);
        return refreshApex(this.productdata);
      })
      .catch((error) => {
        console.error("Error:", error);
      });
  }

  navigateToRecord(event) {
    const recordId = event.currentTarget.dataset.id;
    // alert('recordId**' + recordId);
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: recordId,
        actionName: "view"
      }
    });
    // window.location.href = '/' + recordId;
    //window.open('/' +recordId, '_blank');
  }

  async showPopup() {
    const recordId = await ModalRecordEditForm.open({
      size: "small",
      objectName: "OpportunityLineItem",
      Fields: this.oPField,
      titleheader: "Create Record",
      layoutName: "Opportunity Product Layout",
      relatedrecId: this.recordId,
      showEdit: false
    });

    if (recordId != "canceled" && recordId != undefined) {
      await this.showSuccessToast(recordId);
    }
  }

  async showPopup2(event) {
    let currentId = event.target.dataset.name;
    const recordId = await ModalRecordEditForm.open({
      size: "small",
      Fields: this.Fields,
      objectName: "Operational_Placement__c",
      titleheader: "Create Record",
      layoutName: "Operational Placement Layout",
      relatedrecId: currentId,
      showEdit: false
    });

    if (recordId != "canceled" && recordId != undefined) {
      await this.showSuccessToast(recordId);
    }
  }
  async editPopup(event) {
    let currentId = event.target.dataset.id;
    const recordId = await ModalRecordEditForm.open({
      size: "small",
      Fields: this.Fields,
      objectName: "OpportunityLineItem",
      titleheader: "Create Record",
      layoutName: "Opportunity Product Layout",
      recId: currentId,
      showEdit: true
    });

    if (recordId != "canceled" && recordId != undefined) {
      await this.showSuccessToast(recordId);
    }
  }

  async showSuccessToast(recordId) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: "Record is  created",
        message: "Record ID: " + recordId,
        variant: "success"
      })
    );

    getOpportunityProductDataNonCacheable({ oppId: this.recordId })
      .then((result) => {
        console.log("Imperative method called");
        console.log("Data>>>>" + result);
        this.productdata = JSON.parse(result);
      })
      .catch((error) => {
        console.error("Error:", error);
      });
  }

  handleRedirect() {
    /*  this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: 'https://lgads1--pocdev.sandbox.lightning.force.com/lightning/r/Report/00OVC000000SdKz2AK/view?queryScope=userFolders&fv0='+this.recordId
            }
        }); */

    window.open(
      "/lightning/r/Report/" +
        this.reportId +
        "/view?queryScope=userFolders&fv0=" +
        this.recordId,
      "_blank"
    );
  }
}