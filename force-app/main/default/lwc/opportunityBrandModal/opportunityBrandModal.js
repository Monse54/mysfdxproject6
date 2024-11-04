import { LightningElement, api, wire, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getRecord } from "lightning/uiRecordApi";
import getBrands from "@salesforce/apex/BrandInfoLookupController.getBrands";
import updateOpportunityBrandInfo from "@salesforce/apex/BrandInfoLookupController.updateOpportunityBrandInfo";
import addBrandToCampaign from "@salesforce/apex/BrandInfoLookupController.addBrandToCampaign";
import addNewBrand from "@salesforce/apex/BrandInfoLookupController.addNewBrand";
import getBrandInfoFromName from "@salesforce/apex/BrandInfoLookupController.getBrandInfoFromName";
import sendSingleEmailWithoutTemplate from "@salesforce/apex/EmailUtility.sendSingleEmailWithoutTemplate";
import USER_ID from "@salesforce/user/Id";
import NAME_FIELD from "@salesforce/schema/User.Name";

const OPPTY_FIELDS = [
  "Opportunity.Brand_Id__c",
  "Opportunity.Brand_Name__c",
  "Opportunity.CreatedDate"
];

export default class OpportunityBrandModal extends LightningElement {
  @api recordId;
  opportunityInfo;
  userName;
  @track isConfirmDialogVisible = false;

  @wire(getRecord, {
    recordId: "$recordId",
    fields: OPPTY_FIELDS
  })
  wiredAccountInfo({ error, data }) {
    if (data) {
      if (!data || !data.fields) {
        return;
      }
      this.opportunityInfo = data;
    } else if (error) {
      console.error(error);
    }
  }

  // To get current users name
  @wire(getRecord, {
    recordId: USER_ID,
    fields: [NAME_FIELD]
  })
  wireuser({ error, data }) {
    if (error) {
      console.log(error);
      return;
    }
    if (!data || !data.fields) {
      return;
    }
    this.userName = data.fields.Name.value;
  }

  brandLabel = "Brand Name";
  brandPlaceholder = "Search Brands";
  iconName = "standard:account";
  recordsList;

  showBrandSpinner;
  selectedBrandRecord;
  showBrandDropdown;
  showBrandPill;

  isModalOpen = false;
  hasRendered = false;
  showLoadingSpinner = false;
  confirmMessage = "";

  async handleConfirmClick(event) {
    if (event.target && event.target.name === "updateOrCreateBrand") {
      if (this.searchString === "") {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error",
            message: "Please add a brand. Brand name cannot be empty.",
            variant: "error"
          })
        );
        return;
      }
      // Check if brand exists
      const allBrands = await getBrandInfoFromName({
        name: encodeURIComponent(this.searchString)
      });
      const matchingBrands = allBrands.filter((brand) => {
        return brand.brand === this.searchString;
      });

      if (matchingBrands.length > 0) {
        // Brand Exists update details
        this.selectedBrandRecord = {
          id: matchingBrands[0].brand_id,
          name: matchingBrands[0].brand
        };
        this.updateDetails();
      } else {
        // Confirm for creation
        this.confirmMessage = `The brand "${this.searchString}" does not exist in our system and would require approval which can take some time. If you click "Create" the brand will be submitted for approval. Meanwhile you can continue with the Opportunity`;
        this.isConfirmDialogVisible = true;
      }
    } else if (event.target && event.target.name === "confirmModal") {
      //when user clicks outside of the dialog area, the event is dispatched with detail value  as 1
      if (event.detail !== 1) {
        // if the user clicks confirm
        if (event.detail.status === "confirm") {
          await this.addNewBrandToOpp();
          this.isConfirmDialogVisible = false;
        } else if (event.detail.status === "cancel") {
          // If user clicks cancel reload the original value of brand
          this.updateValues();
          this.isConfirmDialogVisible = false;
        }
      }
    }
  }

  async addNewBrandToOpp() {
    try {
      this.showLoadingSpinner = true;
      // Add brand to db so that it can be approved
      const brandInfo = await addNewBrand({
        name: this.searchString,
        isValidated: 0,
        createdBy: this.userName,
        source: "campaigns"
      });

      if (!brandInfo || !brandInfo.status) {
        throw new Error(
          "Error while creating new Brand: " +
            (brandInfo != null ? brandInfo.message : "")
        );
      }

      // Add the brand to Opportunity and CM
      await this.updateBrandData(
        this.recordId,
        brandInfo.id,
        this.searchString
      );

      // Send email
      const toEmail = "brand-approval@lgads.tv";
      const ccEmail = "";
      const replyEmail = "";
      const mailSubject = `New brand "${this.searchString}" created from Salesforce`;
      const mailBody = `New brand <b>${this.searchString}</b> created. <br/> Created By: ${this.userName} <br/> Opportunity ID: ${this.recordId} <br/> <br/> Please validate it at https://adclipper-review.alphonso.tv/tools/custom-brand`;

      await sendSingleEmailWithoutTemplate({
        toEmail: toEmail,
        ccEmail: ccEmail,
        replyEmail: replyEmail,
        subject: mailSubject,
        body: mailBody,
        isHTML: true
      });
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Successful",
          message: "New Brand request successfull",
          variant: "success"
        })
      );
    } catch (error) {
      const errMsg = this.getMessageFromError(error);
      console.log(errMsg);
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error",
          message: errMsg,
          variant: "error"
        })
      );
    } finally {
      // Close the modal since user need not wait for the email to be sent
      this.showLoadingSpinner = false;
      this.isModalOpen = false;

      // eslint-disable-next-line no-eval
      eval("$A.get('e.force:refreshView').fire();");
    }
  }

  getMessageFromError(error) {
    if (error.message) {
      return error.message;
    }
    if (error.body && error.body.message) {
      return error.body.message;
    }
    console.log("Unkown Error", error);
    return "Some unknown error occured";
  }

  openModal() {
    this.updateValues();
  }

  closeModal() {
    this.isModalOpen = false;
  }

  updateValues() {
    this.selectedBrandRecord = {
      id: this.opportunityInfo.fields.Brand_Id__c.value,
      name: this.opportunityInfo.fields.Brand_Name__c.value
    };
    this.searchString = this.selectedBrandRecord.name;

    if (this.selectedBrandRecord.name) {
      this.showPill = true;
    } else {
      this.showPill = false;
    }

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
        // eslint-disable-next-line eqeqeq
        (brand) => brand.id == event.currentTarget.dataset.key
      );
      if (index !== -1) {
        this.selectedBrandRecord = this.recordsList[index];
        this.searchString = this.selectedBrandRecord.name;
        this.showBrandDropdown = false;
        this.showPill = true;
      }
    }
  }

  removeBrand() {
    this.showPill = false;
    this.selectedBrandRecord = {};
    this.searchString = "";
  }

  showBrandRecords() {
    if (this.recordsList && this.searchString) {
      this.showBrandDropdown = true;
    }
  }

  blurBrandEvent() {
    this.showBrandDropdown = false;
  }

  updateDetails() {
    this.showLoadingSpinner = true;

    return this.updateBrandData(
      this.recordId,
      this.selectedBrandRecord.id,
      this.selectedBrandRecord.name
    )
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
            message: this.getMessageFromError(err),
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
      searchString: encodeURIComponent(this.searchString)
    })
      .then((result) => {
        if (result && result.length > 0) {
          // ---------------------------- Dev
          // const tmp = result;
          // this.recordsList.splice(0, this.recordsList.length);
          // for (let i = 0; i < tmp.length; i++) {
          //   const brand = tmp[i];
          //   const mappedBrand = {
          //     id: brand.brand_id,
          //     name: brand.brand
          //   };
          //   this.recordsList.push(mappedBrand);
          // }
          // ----------------------------

          // prod
          this.recordsList = result;

          this.recordsList = this.recordsList.slice().sort(function (a, b) {
            const keyA = a.name.length,
              keyB = b.name.length;
            if (keyA < keyB) return -1;
            if (keyA > keyB) return 1;
            return 0;
          });
        } else {
          this.message = "No Records Found for '" + this.searchString + "'";
        }
      })
      .catch((error) => {
        this.message = error.message;
        console.log(error);
      })
      .finally(() => {
        this.spinner(itemLabel, false);
      });
  }

  async updateBrandData(oppId, brandId, brandName) {
    // Get old value in case we need to rollback
    const oldBrandId = this.opportunityInfo.fields.Brand_Id__c.value;
    const oldBrandName = this.opportunityInfo.fields.Brand_Name__c.value;
    try {
      // Update new value
      await updateOpportunityBrandInfo({
        oppId: oppId,
        brandId: brandId,
        brandName: brandName
      });
    } catch (error) {
      throw new Error(
        "Error while updating record, update failed: " +
          this.getMessageFromError(error)
      );
    }

    try {
      // Call add brand to campaign
      let encodedBrand = encodeURIComponent(brandName);
      // encodedBrand = encodedBrand.replace(/'/g, '%27')
      console.log("Going to add brand to CM", encodedBrand);
      const response = await addBrandToCampaign({
        oppId,
        brandId,
        brandName: encodedBrand
      });
      console.log("Response ", response);
      if (!response || !response.message.includes("successfully updated")) {
        let msg = "Update on CM failed";

        if (response && response.message) {
          msg += " with message" + response.message;
        }
        throw new Error(msg);
      }
    } catch (error) {
      // if campaign update fails rollback updates on SF
      try {
        // Update to old value
        await updateOpportunityBrandInfo({
          oppId: oppId,
          brandId: oldBrandId,
          brandName: oldBrandName
        });
      } catch (err) {
        throw new Error(
          "Error while rolling back, update failed: " +
            this.getMessageFromError(err)
        );
      }
      throw new Error(
        "Error while updating data on CM, Opportunity not updated: " +
          this.getMessageFromError(error)
      );
    }
  }
}