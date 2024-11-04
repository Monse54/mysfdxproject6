/**
 * Created by cxu on 7/02/2017.
 */
({
    doInit : function(cmp, event, helper) {
        helper.getOpportunity(cmp);
        helper.getPricebooks(cmp);
    },
    updatePricebook : function (cmp, event, helper) {
        var opportunity = cmp.get("v.opportunity");
        var pricebookId = cmp.get("v.pricebookId");
        opportunity.Pricebook2Id = pricebookId;
        opportunity.sobjectType = 'Opportunity';
        console.log(opportunity);

        var action = cmp.get("c.updateOpportunity");
        action.setParams ({
            opportunity : opportunity,
            pricebookId : pricebookId
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var error = response.getReturnValue();
                console.log(error);

                $A.get('e.force:refreshView').fire();
                //cmp.set("v.opportunity", opportunity);
                helper.getOpportunity(cmp);
            }
            else if (state === "INCOMPLETE") {
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " +
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    },
    onPricebookChange : function (cmp, event, helper) {
        var pricebookId = cmp.find("pricebookId").get("v.value");
        console.log(pricebookId);
        cmp.set("v.pricebookId", pricebookId);
    },
    disableEditMode : function (cmp) {
        cmp.set("v.editMode", false);
    },
    enableEditMode : function (cmp) {
        cmp.set("v.editMode", true);
    }
})