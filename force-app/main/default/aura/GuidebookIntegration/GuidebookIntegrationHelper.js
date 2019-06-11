({
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
    },
    guideBookCall : function(cmp, event, helper) { 
        var hidebutton = cmp.find("submit");
        $A.util.addClass(hidebutton, "toggle");
        cmp.set('v.columns', [
          //  {label: 'Guide Id', fieldName: 'FMV1_Guide_ID__c', type: 'number'},
            {label: 'Guide Name', fieldName: 'Name', type: 'text'},
            {label: 'Description', fieldName: 'FMV1_Guide_Description_HTML__c', type: 'Text',title:'FMV1_Guide_Description_HTML__c'},
            {label: 'Start Time', fieldName: 'EventApi__Start_Date_Time__c', type: 'Text'},
            {label: 'End Time', fieldName: 'EventApi__End_Date_Time__c', type: 'Text'}
        ]);
        
        var action = cmp.get("c.getGuides");
        action.setParams({
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var responsevalue =  response.getReturnValue();
                cmp.set('v.records',responsevalue);
                helper.doneWaiting(cmp, event, helper);  
            }
            
        });        
        $A.enqueueAction(action);
        
    },
    clearRecords :function (cmp){
       // var hidebutton = cmp.find("submit");
       // $A.util.removeClass(hidebutton, "toggle");
        cmp.set('v.records', null);
        
    },
    syncData :function (cmp, event, helper){
        var action = cmp.get("c.SyncData");
        action.setParams({
            eventId: cmp.get("v.recordId"),
            guideId :cmp.get("v.guideId"),
            Name :cmp.get("v.guideName"),
            description :cmp.get("v.guideDescription"),
            startDate :cmp.get("v.startDatetime"),
            endDate :cmp.get("v.endDatetime")
        });
        action.setCallback(this, function(resp) { 
            //$A.get('e.force:refreshView').fire();
            if(resp.getState()=='SUCCESS'){
            helper.doneWaiting(cmp, event, helper);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type":'success',
                "title": "Success!",
                "message": "Sync is Completed."
            });
            toastEvent.fire();
                
            }
           $A.get("e.force:refreshView").fire();
           var dismissActionPanel = $A.get("e.force:closeQuickAction");
           dismissActionPanel.fire();
        }); 
        
        $A.enqueueAction(action); 
    },
    syncOtherEntities :function (cmp, event, helper){
        var action = cmp.get("c.incrementalMethod");
        action.setParams({
            
            guideId :cmp.get("v.guideId")
            
        });
        action.setCallback(this, function(response) {  
            var state = response.getState();
            if (state === "SUCCESS") {
                $A.get('e.force:refreshView').fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The record has been updated successfully."
                });
                toastEvent.fire();
            }
            
        }); 
        $A.enqueueAction(action); 
    },
    waiting: function(component, event, helper) {
        console.log('Inside wait');
        // debugger;
        $A.util.addClass(component.find("divSpinner").getElement(), "show");
        $A.util.removeClass(component.find("divSpinner").getElement(), "hide");
        window.setTimeout(function (){document.getElementById('divSpinner').style.display='block';},200);
    },    
    doneWaiting: function(component, event, helper) {
        console.log('Inside done wait');
        $A.util.addClass(component.find("divSpinner").getElement(), "hide");
        $A.util.removeClass(component.find("divSpinner").getElement(), "show");
        document.getElementById('divSpinner').style.display='none';
    },
    enableSyncButton : function (component){
       // debugger;
        var cmpTarget = component.find('btnGuideSync');
        cmpTarget.set("v.disabled",false);
    }
})