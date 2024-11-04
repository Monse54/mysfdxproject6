/**
 * Created by cxu on 7/02/2017.
 */
({
    getOpportunity : function (cmp) {
        var action = cmp.get("c.getOpportunity");
        action.setParam("recordId", cmp.get("v.recordId"));

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var opportunity = response.getReturnValue();
                cmp.set("v.opportunity", opportunity);

                if (opportunity.OpportunityLineItems == null || opportunity.OpportunityLineItems == undefined) {
                    opportunity.OpportunityLineItems = [];
                	cmp.set("v.opportunity.OpportunityLineItems", opportunity.OpportunityLineItems);
                }
                this.getPricebookEntries(cmp);
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
    getPricebooks : function (cmp) {
         var action = cmp.get("c.getPricebooks");

         action.setCallback(this, function(response) {
             var state = response.getState();
             if (state === "SUCCESS") {
                 var pricebooks = response.getReturnValue();
                 cmp.set("v.pricebooks", pricebooks);
                 if (pricebooks.length > 0) {
                    cmp.set("v.pricebookId", pricebooks[0].Id);
                 }
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
     getPricebookEntries : function (cmp) {
         var pricebookId = cmp.get("v.opportunity").Pricebook2Id;

        var action = cmp.get("c.getPricebookEntries");
        action.setParam("pricebookId", pricebookId);

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var entries = response.getReturnValue();
                cmp.set("v.pricebookEntries", entries);
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
     }
})