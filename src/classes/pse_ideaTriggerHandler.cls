public with sharing class pse_ideaTriggerHandler {

    private static final String STAGE_NYR = 'Not Yet Reviewed';
    private static final String STAGE_UCC = 'Under Consideration by Committee';
    private static final String STAGE_BR = 'Rejected';
	private static final String STAGE_PM = 'Project Mode';
    private String currentStep;
	private String c;
	private pse_Category__c cat;
	
	public void routeApprovals(Map<Id, pse_Idea__c> oldIdeas, Map<Id, pse_Idea__c> newIdeas) {
        
		List<pse_Idea__c> ideas_to_route = new List <pse_Idea__c>();
		Set<String> criteria = new Set <String>();
	
		for(Id ideaId : oldIdeas.keySet()) {
			pse_Idea__c old_idea = oldIdeas.get(ideaId);
			pse_Idea__c new_idea = newIdeas.get(ideaId);
			
	
			//For now criteria to move to 'Under Consideration by Committee' status and assign aprrovers is
			//only based on the number of votes up.
			//In the next version, criticality, Innovation category, pain points will also be taken into account
	           
	        
	        if((new_idea.pse_Status__c == STAGE_NYR && old_idea.pse_Status__c == STAGE_NYR) 
	           && (old_idea.pse_VotesUp__c != new_idea.pse_VotesUp__c)) {
	    
				ideas_to_route.add(new_idea);
				criteria.add(new_idea.pse_Category__c + ':' + new_idea.pse_VotesUp__c);
				
					
	            //Reset the record's status and set approvers to null 
				new_idea.pse_Approver_11__c = null;
	            new_idea.pse_Approver_22__c = null;
	            new_idea.pse_Approver_33__c = null;
			} 
			//If status transitions from "Under Consideration by Committee" to "Project Mode", create
			//a new record in the Projects Object.
			else if (old_idea.pse_Status__c == STAGE_UCC && new_idea.pse_Status__c == STAGE_PM ) {

				pse_Projects__c project = new pse_Projects__c (Name = new_idea.pse_Title__c);
				project.pse_Original_Idea__c = new_idea.id;
				 
				
				try {
					insert project;	
				}
				catch (DmlException e) {
    				System.debug(e.getMessage());
    				System.debug(e.getStackTraceString());
				}
				
			}
	        else {
	            //do nothing if status is in anything but 'Under Consideration by Committee' 
	            //'Under Consideration by Committee' => no need to select approvers, this has already been done
	            //'Rejected' nothing to be done as the idea has been rejected
	            //'Project Mode' nothing to be done as the idea has already been approved
	        }
	
		}

		
		if(!ideas_to_route.isEmpty()) {
			// fetch the matching routes


			List<pse_Idea_Rules_Evaluation__c> routes = [SELECT pse_Pain_Point__c, 
															pse_Criteria__c, 
															pse_Points__c, 
															pse_Approver_1__c,
															pse_Approver_2__c,
															pse_Approver_3__c, 
															pse_Innovation_Category__c 															
														FROM pse_Idea_Rules_Evaluation__c 
														]; 

																														
			Map<String, pse_Idea_Rules_Evaluation__c> routesByCriteria = new Map<String, pse_Idea_Rules_Evaluation__c>();
	
			for(pse_Idea_Rules_Evaluation__c route : routes) {
				routesByCriteria.put(route.pse_Criteria__c, route); 
			}
	
	        //Update Approvers only if the number of votes for a given Innovation Category has reached the threshold set
	        //in the "Idea Rules Evaluation" 
			for(pse_Idea__c idea : ideas_to_route) {
				pse_Idea_Rules_Evaluation__c route = routesByCriteria.get(idea.pse_Category__c + ':' + idea.pse_VotesUp__c);				
	
				//we have a hit !
				if(null != route) {
					idea.pse_Approver_11__c = getApprover(route.pse_Approver_1__c);
					idea.pse_Approver_22__c = getApprover((null == route.pse_Approver_2__c) ? idea.pse_Approver_11__c : route.pse_Approver_2__c);
					idea.pse_Approver_33__c = getApprover((null == route.pse_Approver_3__c) ? idea.pse_Approver_22__c : route.pse_Approver_3__c);
					
					
					//Now update the status
					idea.pse_Status__c = STAGE_UCC;
								
					
				}
	
	            // Cannot leave any approver related-user field empty
				else {
					// prevent mistaken routes by resetting approvers if route cannot be found.
					idea.pse_Approver_11__c = null; 
	                idea.pse_Approver_22__c = null;
	                idea.pse_Approver_33__c = null;
				}
	
			}//end of for	
		}//end of if
		
	}
	
    
    public String getApprover(String primaryApproverId) {
    	String approverId = primaryApproverId;
        Date startDate;
        Date endDate;
        String delegatedApproverId;
        
        try {
        	User user = [SELECT DelegatedApproverId, pse_pto_start_date__c, pse_pto_end_date__c FROM USER WHERE Id = :primaryApproverId LIMIT 1];
            
            if(user.DelegatedApproverId != null && user.pse_pto_start_date__c != null && user.pse_pto_end_date__c != null) {
                
                startDate = Date.valueOf(user.pse_pto_start_date__c);
                endDate = Date.valueOf(user.pse_pto_end_date__c);
                delegatedApproverId = String.valueOf(user.DelegatedApproverId);
                
                if(startDate <= Date.today() || endDate >= Date.today()) {
                    approverId = delegatedApproverId;

                }    
        	}
        }
        
        catch(DmlException e) {
    		System.debug(e.getMessage());
    		System.debug(e.getStackTraceString());
		}
    
        return approverId;
    }
    
}