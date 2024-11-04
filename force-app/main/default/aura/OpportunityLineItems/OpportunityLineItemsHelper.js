({
	validateItem : function(item) {
		return (item.PricebookEntryId != null);
	},
    showSpinner : function (cmp) {
        var spinner = cmp.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    hideSpinner : function (cmp) {
        var spinner = cmp.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    }
})