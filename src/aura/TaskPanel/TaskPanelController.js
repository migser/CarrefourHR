({
    handleShowTaskClick : function(component) {
        
        component.set("v.hideTask", false);
        var action = component.get("c.getIncompleteTasks");

        action.setParams({
            taskType : component.get("v.task.header")
        });

        action.setCallback(this, function(actionResult) {
      		var taskList = actionResult.getReturnValue();
			console.log(taskList);
            component.set("v.incompleteTasks", taskList);
		});
        
        $A.enqueueAction(action);
    },
    
    navigateToTask : function(component, event, helper) {
        
        var id = event.target.getAttribute("data-data");
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": id,
          "slideDevName": "detail"
        });
        navEvt.fire();        
    }
})