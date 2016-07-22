public with sharing class pse_ideaTriggerHandlerAfterAfter {
 
    private static final String STAGE_NYR = 'Not Yet Reviewed';
    private static final String STAGE_UCC = 'Under Consideration by Committee';
    private static final String STAGE_BR = 'Rejected';
	private static final String STAGE_PM = 'Project Mode';
    private static String STEP1 = 'Committee Review';
    private String currentStep;
	private String c;
	private pse_Category__c cat;
	public static boolean isExecuting = false;
	
	public void routeApprovals(Map<Id, pse_Idea__c> oldIdeas, Map<Id, pse_Idea__c> newIdeas) {
        
        if(pse_ideaTriggerHandlerAfterAfter.isExecuting) {
        	//If trigger is already executing, leave in order to avoid recursion.
        	return;
        }
        isExecuting = true;
       
	
		for(Id ideaId : oldIdeas.keySet()) {
			pse_Idea__c old_idea = oldIdeas.get(ideaId);
			pse_Idea__c new_idea = newIdeas.get(ideaId);


	        if(new_idea.pse_Status__c == STAGE_UCC && old_idea.pse_Status__c == STAGE_NYR ) {
	        
	    		submitIdea(new_idea);
	    		
	    		//Create a record on the "Under Consideration" Object
				pse_Under_Consideration__c underConsideration = new pse_Under_Consideration__c(pse_under_review_since__c = Date.today());
				underConsideration.pse_idea__c = new_idea.id;
				
				
				try {
					insert underConsideration; 
				}
       			catch(DmlException e) {
   					System.debug(e.getStackTraceString());
				}

			} 

	        else {

	            //Do nothing
	        }
	
		}
		
	}
	
	public void submitIdea(pse_Idea__c a) {

		
		pse_Idea__c idea2 = new pse_Idea__c(Id = a.Id);
		idea2.pse_Status__c = STAGE_UCC;
		
		try {
			update idea2;
		}
		catch(DmlException e) {
   			System.debug(e.getStackTraceString());
		}

		
        // Create an approval request for the idea
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(idea2.Id);
        
        // Submit on behalf of a specific submitter 
        req1.setSubmitterId(idea2.OwnerId);
        
        // Submit the record to specific process and skip the criteria evaluation
        req1.setProcessDefinitionNameOrId('pse_Idea_Approval');
        req1.setSkipEntryCriteria(true);
        
        // Submit the approval request for the idea
        Approval.ProcessResult result = Approval.process(req1);
        
        // Verify the result
        System.assert(result.isSuccess());
		
	}
    


}