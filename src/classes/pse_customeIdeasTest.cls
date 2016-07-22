/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class pse_customeIdeasTest {


    public static ApexPages.StandardSetController setCon;
    public static pse_customIdeasController controller;
    public static pse_Idea__c idea;
    
    static void init() {
    	
    	if (controller == null) {
	    	setCon = new ApexPages.StandardSetController(Database.getQueryLocator( 
	                    [SELECT pse_Title__c, 
	        					pse_Number_of_Comments__c,pse_VotesUp__c,pse_VotesDown__c,pse_Status__c,
	        					pse_Submitted_By__c, pse_Idea_Age__c  
	        					FROM pse_Idea__c FOR REFERENCE]));
	        					
	        controller = new pse_customIdeasController(setCon);
    	}
    	
        idea = pse_testDataFactory.createTestIdea ();
        
        try {
        	insert idea;
        }
		catch (DmlException e) {
    		System.debug(e.getMessage());
		}
    }


	@IsTest
    public static void testCreateIdeaController() {
    	Test.startTest();
    	init(); 
    	controller.createIdea();
    	Test.stopTest();
    }
    
    @IsTest
    public static void testDomainController() {
   		Test.startTest();
    	init();    
       
        String baseURL = controller.getDomain(); 
        //System.assertEquals('https://eu5.salesforce.com',baseURL);
        System.assertEquals(System.Url.getSalesforceBaseURL().toExternalForm(),baseURL);
        Test.stopTest();
    }
    
    @IsTest public static void testInrementVoteController() {
    	Test.startTest();
    	init();
    	
        boolean isIncrementResult = pse_customIdeasController.voteHandler(idea.id,'increment');

        
        pse_Idea__c idea1 = [SELECT pse_VotesUp__c from pse_Idea__c where id = :idea.id LIMIT 1];
        
        System.assertEquals(idea1.pse_VotesUp__c,1);        
   		Test.stopTest();
    } 
    
    @IsTest public static void testIncrementVoteTwiceController() {
    	Test.startTest();
    	init();
    	
        boolean isIncrementResult = pse_customIdeasController.voteHandler(idea.id,'increment');

        pse_Idea__c idea1 = [SELECT pse_VotesUp__c from pse_Idea__c where id = :idea.id LIMIT 1];
        
        System.assertEquals(idea1.pse_VotesUp__c,1); 
        
        //Now ry to vote again for the same idea with a vote down, it should not work because we have already
        //voted with a vote up just before (can't voe twice.
        
        boolean isDecrementResult = pse_customIdeasController.voteHandler(idea.id,'increment');
        //Number of votesUp should still be equal to 1, not 2.
        System.assertEquals(idea1.pse_VotesUp__c,1);        
   		Test.stopTest();
    }
    
    @IsTest public static void testDecrementVoteController() {
    	Test.startTest();
    	init();
    	
        boolean isDecrementResult = pse_customIdeasController.voteHandler(idea.id,'decrement');

        pse_Idea__c idea1 = [SELECT pse_VotesDown__c from pse_Idea__c where id = :idea.id LIMIT 1];
        
        System.assertEquals(idea1.pse_VotesDown__c,-1);        
   		Test.stopTest();
    }    
           
}