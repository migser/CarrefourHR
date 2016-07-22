public with sharing class pse_testDataFactory {
	
	public static pse_Idea__c createTestIdea () {
		String title = String.valueof(System.Math.random());
		pse_Idea__c idea = new pse_Idea__c (pse_Title__c = title, 
        									pse_VotesUp__c =0,
        									pse_VotesDown__c =0,
        									pse_Number_of_Comments__c = 0,
        									pse_Status__c = 'Not Yet Reviewed');

        																		
        return idea;
	}
	
	public static FeedItem createTestFeed (String id) {

		FeedItem myFeed = new FeedItem(parentId = id,
									 Body ='test post'
									 );    									
        									
        return myFeed;
	}
	
	public static pse_Category__c createTestCategory () {

		pse_Category__c cat = new pse_Category__c (Name = 'Innovation Category Test', 
														  	pse_Description__c = 'Description test');
		  									
        									
        return cat;
	}	


	public static User createTestUser (String id) {

		User user;
		try {
			Profile p = [SELECT Id from Profile where Name = 'Standard User'];
		

		
			user = new User (Lastname = 'testLastName' + id,
	                         FirstName = 'testFirstName' + id,
	                         Title = 'QA',
	                         Department = 'Test Department',
	                         Email = 'test@gmail.com',
	                         Phone = '+33123456789',
	                         MobilePhone = '+33123456789',
	                         TimeZoneSidKey = 'Europe/Paris',
	                         LocaleSidKey = UserInfo.getLocale(),
	                         EmailEncodingKey = 'ISO-8859-1', 
	                         LanguageLocaleKey = 'fr',
	                         Username ='ra_test' + id + '@test.com',
	                         Alias= 'test' + id,
	                         CommunityNickname ='test' + id, 
	                         ProfileId = p.id
	                      );
		}
		catch (DmlException e) {
    		System.debug(e.getMessage());
		}   									
        									
        return user;
	}
	
	public static pse_Idea_Rules_Evaluation__c createTestRule (String id) {

		
		pse_Idea_Rules_Evaluation__c rule = new pse_Idea_Rules_Evaluation__c (pse_Points__c = 1, 
														  	pse_Innovation_Category__c = id); 
 
														  										        									
        return rule;
	}

}