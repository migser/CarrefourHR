@isTest
private class pse_postCommentTriggerTest {
	
	public static pse_Idea__c idea;
	public static FeedItem myFeed;
	
	static void init() {
		idea = pse_testDataFactory.createTestIdea ();
		insert idea;
		
		myfeed = pse_testDataFactory.createTestFeed (idea.id); 
		insert myFeed;
	}
	
	@IsTest public static void testAddCommentTrigger() {
		
		Test.startTest();
		init();
								        
	
		pse_Idea__c idea1 = [SELECT pse_Number_of_Comments__c from pse_Idea__c where id = :idea.id LIMIT 1];
		
		//Now check that the number of comments has been incremented
		System.assertEquals(idea1.pse_Number_of_Comments__c,1);
		
		Test.stopTest();
	}
	
	@IsTest public static void testDeleteCommentTrigger() {
		
		Test.startTest();
		init();
		
		//delete post
		myfeed = [SELECT id from FeedItem where id = :myFeed.id LIMIT 1];
		
		try {
			delete myfeed;
		}
		catch (DmlException e) {
    		System.debug('An unexpected error has occurred: ' + e.getMessage());
		}
		
		pse_Idea__c idea1 = [SELECT pse_Number_of_Comments__c from pse_Idea__c where id = :idea.id LIMIT 1];
		
		//Now check that the number of comments has been decremented to 0
		System.assertEquals(idea1.pse_Number_of_Comments__c,0);
		
		Test.stopTest();
	}

}