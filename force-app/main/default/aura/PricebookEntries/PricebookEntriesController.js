/**
 * Created by cxu on 8/02/2017.
 */
({
    showLookupMenu : function (cmp, event, helper) {
        var cmpTarget = cmp.find('search');
        $A.util.addClass(cmpTarget, 'slds-is-open');
    },
    hideLookupMenu : function (cmp, event, helper) {
      	var cmpTarget = cmp.find('search');
      	$A.util.removeClass(cmpTarget, 'slds-is-open');
    },
    removeProductSelection : function (cmp, event, helper) {
        var item = cmp.get("v.item");
        item.PricebookEntryId = null;
        cmp.set("v.item", item);
    },
    filterEntries : function (cmp, event, helper) {
        var search = cmp.get("v.searchString").toLowerCase();
        var entries = cmp.get("v.entries");
        if (search === '') {
            cmp.set("v.filteredEntries", entries);
        } else {
            var filteredEntries = [];
            entries.forEach(function(entry) {
                if (entry.Product2.Name.toLowerCase().includes(search) ||
                    entry.Product2.ProductCode.toLowerCase().includes(search)) {
                    filteredEntries.push(entry);
                }
            });
            cmp.set("v.filteredEntries", filteredEntries);
        }
    },
    initialise : function (cmp, event, helper) {
        var entries = cmp.get("v.entries");
        cmp.set("v.filteredEntries", entries);
    }
})