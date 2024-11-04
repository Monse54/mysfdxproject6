/**
 * Created by cxu on 8/02/2017.
 */
({
    togglePopover : function (cmp, event, helper) {
        var editMode = cmp.get("v.editMode");
        var cmpTarget = cmp.find('popover');
        if (editMode) {
      	    $A.util.toggleClass(cmpTarget, 'hide');
      	} else {
      	    $A.util.addClass(cmpTarget, 'hide');
       }
    },
    removeItem : function (cmp, event, helper) {
        var appEvent = $A.get("e.c:RemoveLineItem");
        appEvent.setParams({
            "item" : cmp.get("v.item") });
        appEvent.fire();
    }
})