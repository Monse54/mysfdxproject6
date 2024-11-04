({
	selectEntry: function (cmp, event, helper) {
		var entry = cmp.get("v.entry");
		var item = cmp.get("v.item");
        item.PricebookEntryId = entry.Id;
        item.PricebookEntry = entry;
        item.UnitPrice = entry.UnitPrice;
        cmp.set("v.item", item);
	}
})