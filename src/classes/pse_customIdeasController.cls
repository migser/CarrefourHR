global class pse_customIdeasController {
    public pse_Idea__c idea;
    public String id;
    Integer vote;
    public static pse_Idea__c myIdea;
    public static pse_Vote__c v;
    public static boolean voteResult  { get; set; }    
    public String ideaId { get; set; }
    
    
    public pse_customIdeasController (ApexPages.StandardSetController stdController) {
        this.idea = (pse_Idea__c)stdController.getRecord();

    }
    
    
    public PageReference createIdea(){
        
       Schema.DescribeSObjectResult r;
       
       try{

           r = pse_Idea__c.SObjectType.getDescribe();

           
       }
       catch(Exception e){
         ApexPages.addMessages(e);
       }
       
       //Go to standard creation page for pse_Idea__c and rturn to VF page 
       //if cancel button is hit on the Stanard pse_Idea__c page
       return new PageReference('/' + r.getKeyPrefix() + '/e?retURL=/apex/pse_customIdeas');
      
    }
    
       

    @RemoteAction
     global static boolean voteHandler(String id, String flag) {
        voteResult = false;
        
        myIdea = [SELECT pse_VotesUp__c, pse_VotesDown__c  FROM pse_Idea__c
                   WHERE Id = :id];
  

        try {        
          //Check if user has already voted
          List <pse_Vote__c> votes = [SELECT id  FROM pse_Vote__c WHERE Idea__c = :id 
                                      AND pse_Voter__c = :UserInfo.getUserId()];
        

          if(votes.size() == 0 ) {
          	//the user did not vote yet, so let's allow him to vote and create a vote reord to make sure he won't be able 
          	//to vote on the same idea again
            //System.debug('customIdeas : RemoteAction : in incrementVote() : in ! (votes.size() > 0 : myIdea.pse_VotesUp__c = ' + myIdea.pse_VotesUp__c);
            
            v = new pse_Vote__c (pse_Has_Voted__c = true);
            v.pse_Voter__c = UserInfo.getUserId();
            v.Idea__c = id;
            
            if(flag == 'increment') {
              myIdea.pse_VotesUp__c += 1;
              v.pse_VoteUp__c = true;		
            }
            else {
              myIdea.pse_VotesDown__c -= 1;
              v.pse_VoteDown__c = true;            	
            }
            
            update myIdea;
            insert v;

            voteResult = true;
            
          }
          
        }
        catch(System.DMLException e) {
            ApexPages.addMessages(e);
        }
        
        return voteResult;
    }
    
    
    public String getDomain() {
        return System.Url.getSalesforceBaseURL().toExternalForm();
    } 
    
}