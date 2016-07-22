trigger pse_postCommentTrigger on FeedItem (before delete, before insert) {
	/*This trigger is used to update the "Number of Comments" field (pse_Number_of_Comments__c) of an idea whenever 
	a user is sharing  post on the idea
	*/

	List<pse_Idea__c> idees = new List<pse_Idea__c>();
	pse_Idea__c idea;
	
	//Get the pse_Idea__c's record Id
    List <pse_Idea__c> ideas = [SELECT id,pse_Number_of_Comments__c FROM pse_Idea__c];
	Map<String, pse_Idea__c> ideasIdMap = new Map<String, pse_Idea__c>();
		
	for(pse_Idea__c id : ideas) {
		ideasIdMap.put(id.id, id);
	}
    	
    //Now check if the post has been made on an idea object
    List<FeedItem> feedItems = new List<FeedItem>();
    
    
	
    if(Trigger.isBefore && Trigger.isDelete) {
    	for (FeedItem f : Trigger.old) {
        	idea = ideasIdMap.get(f.parentId);
            if(idea != null) {
                idea.pse_Number_of_Comments__c -= 1; 
                idees.add(idea);
			} 
        }

    }
    
    else if (Trigger.isBefore && Trigger.isInsert) {
        for (FeedItem f : Trigger.new) {
        	idea = ideasIdMap.get(f.parentId);
            if(idea != null) {
                idea.pse_Number_of_Comments__c += 1; 
                idees.add(idea);

			} 
        }    
    }
    
    update idees;

}