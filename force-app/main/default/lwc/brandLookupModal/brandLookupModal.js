import { LightningElement, api, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getRecord } from "lightning/uiRecordApi";
import getBrands from "@salesforce/apex/BrandInfoLookupController.getBrands";
import updateBrandInfo from "@salesforce/apex/BrandInfoLookupController.updateBrandInfo";

const ACCOUNT_FIELDS = [
  "Account.Brand_Id__c",
  "Account.Brand_Name__c",
  "Account.CreatedDate"
];

export default class BrandLookupModal extends LightningElement {
  @api recordId;
  accountInfo;
  newPopupTriggered = false;

  @wire(getRecord, {
    recordId: "$recordId",
    fields: ACCOUNT_FIELDS
  })
  wiredAccountInfo({ error, data }) {
    if (data) {
      if (!data || !data.fields) {
        return;
      }
      this.accountInfo = data;
      if (this.newPopupTriggered) {
        return;
      }
      this.newPopupTriggered = true;
      const currentTime = new Date().getTime();
      const createdTime = new Date(data.fields.CreatedDate.value).getTime();
      const numSeconds = (currentTime - createdTime) / 1000;

      // If the new Account record is created
      // i.e. created date in last 20 seconds
      if (numSeconds < 20) {
        this.openModal();
      }
    } else if (error) {
      console.error(error);
    }
  }

  brandLabel = "Brand Name";
  brandPlaceholder = "Search Brands";
  iconName = "standard:account";
  recordsList;

  showBrandSpinner;
  brandSearchString;
  selectedBrandRecord;
  showBrandDropdown;
  showBrandPill;

  isModalOpen = false;
  hasRendered = false;
  showLoadingSpinner = false;

  openModal() {
    this.updateValues();
  }

  closeModal() {
    this.isModalOpen = false;
  }

  updateValues() {
    this.selectedBrandRecord = {
      id: this.accountInfo.fields.Brand_Id__c.value,
      name: this.accountInfo.fields.Brand_Name__c.value
    };

    if (this.selectedBrandRecord.name) {
      this.showPill = true;
    } else {
      this.showPill = false;
    }

    this.brandSearchString = "";
    this.isModalOpen = true;
  }

  searchBrands(event) {
    this.searchString = event.target.value;
    const itemLabel = event.target.label;

    if (this.searchString) {
      clearTimeout(this.debounceTimeout);
      // eslint-disable-next-line @lwc/lwc/no-async-operation
      this.debounceTimeout = setTimeout(
        this.fetchData.bind(this, itemLabel),
        500
      );
    } else {
      this.dropdown(itemLabel, false);
    }
  }

  selectBrand(event) {
    if (event.currentTarget.dataset.key) {
      const index = this.recordsList.findIndex(
        (brand) => brand.id === parseInt(event.currentTarget.dataset.key, 10)
      );
      if (index !== -1) {
        this.selectedBrandRecord = this.recordsList[index];
        this.showBrandDropdown = false;
        this.showPill = true;
      }
    }
  }

  removeBrand() {
    this.showPill = false;
    this.selectedBrandRecord = {};
    this.brandSearchString = "";
  }

  showBrandRecords() {
    if (this.recordsList && this.brandSearchString) {
      this.showBrandDropdown = true;
    }
  }

  blurBrandEvent() {
    this.showBrandDropdown = false;
  }

  updateDetails() {
    this.showLoadingSpinner = true;

    return updateBrandInfo({
      accountId: this.recordId,
      brandId: this.selectedBrandRecord.id,
      brandName: this.selectedBrandRecord.name
    })
      .then(() => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: "Brands info updated sucessfully",
            variant: "success"
          })
        );
      })
      .catch((err) => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error updating brands info",
            message: err.body.message,
            variant: "error"
          })
        );
      })
      .finally(() => {
        this.showLoadingSpinner = false;
        this.isModalOpen = false;
        // eslint-disable-next-line no-eval
        eval("$A.get('e.force:refreshView').fire();");
      });
  }

  spinner(itemLabel, show = true) {
    if (itemLabel === "brand-field") {
      this.showBrandSpinner = show;
    }
  }

  dropdown(itemLabel, show = true) {
    if (itemLabel === "brand-field") {
      this.showBrandDropdown = show;
    }
  }

  fetchData(itemLabel) {
    this.spinner(itemLabel, true);
    this.dropdown(itemLabel, true);
    this.message = "";
    this.recordsList = [];

    return getBrands({
      searchString: this.searchString
    })
      .then((result) => {
        if (result && result.length > 0) {
          this.recordsList = result;
        } else {
          this.message = "No Records Found for '" + this.searchString + "'";
        }
      })
      .catch((error) => {
        this.message = error.message;
      })
      .finally(() => {
        this.spinner(itemLabel, false);
      });
  }
}