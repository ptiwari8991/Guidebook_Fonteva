({ 
    doInit : function(component, event, helper) {
        var action = component.get("c.getEvent");
        action.setParams({
            eventId: component.get("v.recordId")
        });
        helper.waiting(component, event, helper);
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.event", response.getReturnValue());
                var resp=component.get("v.event");
                
                console.log('response.getReturnValue()'+response.getReturnValue());
                console.log('response.getReturnValue resp()'+resp.Name);
                var guideId = component.get("v.event.FMV1_Guide_ID__c");
               component.set("v.guideName", resp.Name);
                if(guideId != null){
                    component.set("v.checkGuide", true);
                    var hidebutton = component.find("submit");
                    $A.util.removeClass(hidebutton, "toggle");
                    helper.doneWaiting(component, event, helper);
                }
                else{
                    var hideName = component.find("eventName");
                    $A.util.addClass(hideName, "name"); 
                    //helper.showSpinner(component, event, helper);
                    helper.guideBookCall(component, event, helper);
                }
                console.log(response.getReturnValue());
            }
            else if (response.getState() === "ERROR") {
                $A.log("Errors", response.getError());
            }
        });
        $A.enqueueAction(action); 
    },
    toggleGuidebook:function (cmp, event, helper){
        var checked= cmp.get("v.isChecked");     
        if(checked){
            console.log('inside guidebook');
            helper.waiting(cmp, event, helper); 
            helper.guideBookCall(cmp, event, helper);
        }
        else{ helper.clearRecords(cmp);}       
    },   
    getSelectedName: function (cmp, event,helper) {
       helper.enableSyncButton(cmp);
       var selectedRows = event.getParam('selectedRows');
        for (var i = 0; i < selectedRows.length; i++){
            cmp.set('v.guideId',selectedRows[i].FMV1_Guide_ID__c);
            cmp.set('v.guideName',selectedRows[i].Name);
            cmp.set('v.startDatetime',selectedRows[i].EventApi__Start_Date_Time__c);
            cmp.set('v.endDatetime',selectedRows[i].EventApi__End_Date_Time__c);
            cmp.set('v.guideDescription',selectedRows[i].FMV1_Guide_Description_HTML__c);
        }
    },
    syncData : function (cmp, event, helper){
        //helper.showSpinner(cmp, event, helper);
        helper.waiting(cmp, event, helper);
        helper.syncData(cmp, event, helper);
    },
    updateGuide :function (cmp, event, helper){
        helper.waiting(cmp, event, helper);
        var action = cmp.get("c.updateGuides");
        action.setParams({
            guideId :cmp.get("v.event.FMV1_Guide_ID__c")
        });
        action.setCallback(this, function(resp) { 
            if(resp.getState()=='SUCCESS'){
                console.log('inside guidebook update success');
            helper.doneWaiting(component, event, helper);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Success!",
                "message": "Sync is Completed."
            });
            toastEvent.fire();
            //window.setTimeout(function(){$A.get('e.force:refreshView').fire();},200);    
            }
           $A.get("e.force:refreshView").fire();
           var dismissActionPanel = $A.get("e.force:closeQuickAction");
           dismissActionPanel.fire();
        }); 
        
        
        $A.enqueueAction(action); 
    },
    cancelPopUp :function (cmp, event){
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();  
    },
        // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    },
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
    }
})