trigger ideaTrigger on pse_Idea__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    /*Trigger used to figure out who is (are) the approver(s) based on the number of positive votes the 
    idea has. 
    * Logic applies only if the Votes Up field has changed.
    */
    
    //Trigger only applies when the Votes Up field is changed (can only be incremented)


    	   
	if(Trigger.isBefore && Trigger.isUpdate) {
	    pse_ideaTriggerHandler handler = new pse_ideaTriggerHandler();
	    handler.routeApprovals(Trigger.oldMap, Trigger.newMap);
	
	}
	else if (Trigger.isAfter && Trigger.isUpdate) {
	    pse_ideaTriggerHandlerAfterAfter handlerAfter = new pse_ideaTriggerHandlerAfterAfter();
	    handlerAfter.routeApprovals(Trigger.oldMap, Trigger.newMap);		
	}
	
}