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
private class pse_ideaTriggerHandlerTest {

	public static pse_Idea__c idea;
	public static pse_Category__c cat;
	public static User user1;
	public static User user2;
	public static User user3;
	public static pse_Idea_Rules_Evaluation__c rule; 
	private static final String STAGE_NYR = 'Not Yet Reviewed';
    private static final String STAGE_UCC = 'Under Consideration by Committee';
    private static final String STAGE_BR = 'Rejected';
	private static final String STAGE_PM = 'Project Mode';
	
	static void initStep1() {
		idea = pse_testDataFactory.createTestIdea ();

		idea.pse_Status__c= 'Not Yet Reviewed';
		insert idea;

	}

	static void initUCCtoPM() {
		idea = pse_testDataFactory.createTestIdea ();
		idea.pse_Status__c= STAGE_UCC;
		
		cat = pse_testDataFactory.createTestCategory();
		
		insert idea;
		insert cat;
	}


	static void initSubmitIdea() {
		try {
			
			//First, create an idea
			idea = pse_testDataFactory.createTestIdea ();
			idea.pse_Status__c= STAGE_NYR;
			
			//then create a Category
			cat = pse_testDataFactory.createTestCategory();
			
			//Create a user that will approve/reject the idea
			user1 = pse_testDataFactory.createTestUser('1');
			
			//Set the PTO time for this user
			Date startDate = Date.today();
			startDate = startDate.addDays(-1);
			user1.pse_pto_start_date__c = startDate;
			
			Date endDate = Date.today();
			endDate = endDate.addDays(7);
			user1.pse_pto_end_date__c = endDate;
		
			
			//Create a another user that is the delegate approver of user1 when h's on vacation 
			user2 = pse_testDataFactory.createTestUser('2'); 
			
			//Create a user that owns the idea
			user3 = pse_testDataFactory.createTestUser('3');
				
			
			insert idea;
			insert cat;
			insert user1;
			insert user2;
			insert user3;

						
			
			//Now create a rule using the category created above and set the number of point to 1, like thenumber 
			//of votesUp so that the idea crate above can be considered automtically by the innoation committee.
			rule = pse_testDataFactory.createTestRule(cat.id);
			rule.pse_Approver_1__c = user1.id;
			insert rule;
		}
		catch (DmlException e) {
    		System.debug(e.getMessage());
		} 
				
	}
  			
   @IsTest 
    public static void step1Test() {
    	Test.startTest();
    	initStep1();
        idea.pse_VotesUp__c = 1;
        
        try {
        	update idea;
        }
        catch (DmlException e) {
    		System.debug(e.getMessage());
		} 
		
		pse_Idea__c idea1 = [SELECT pse_Approver_11__c, pse_Approver_22__c,pse_Approver_33__c 
							 from pse_Idea__c where id = :idea.id LIMIT 1];
		
		System.assertEquals(idea1.pse_Approver_11__c,null);
		System.assertEquals(idea1.pse_Approver_22__c,null);
		System.assertEquals(idea1.pse_Approver_33__c,null);
		
		Test.stopTest();
    }
  
  
    @IsTest 
    public static void UCCtoPMTest() {
    	Test.startTest();
    	initUCCtoPM();
        idea.pse_VotesUp__c = 1;
        idea.pse_Status__c= STAGE_PM;
        idea.pse_Category__c = cat.id;
        
        try {
        	update idea;
			
			pse_Projects__c project = [SELECT Name from pse_Projects__c where pse_Original_Idea__c =: idea.id];

			//test a project has been created
			System.assertEquals(project.Name,idea.pse_Title__c);
        }
        catch (DmlException e) {
    		System.debug(e.getMessage());
    		System.debug(e.getStackTraceString());
		} 
		

		
		Test.stopTest();
    }

    @IsTest 
    public static void submitIdeaTest() {
    	Test.startTest();
    	initSubmitIdea();
        idea.pse_VotesUp__c = 1;
        idea.pse_Category__c = cat.id;
        
        //set user2 as user1's delegate approver. 
		user1.DelegatedApproverId = user2.id;
		
		try {
			update user1;
        	update idea;
        	      
	        pse_Idea__c idea1 = [SELECT Id,pse_Status__c, pse_Approver_11__c, pse_Approver_22__c,pse_Approver_33__c 
								 from pse_Idea__c where id = :idea.id LIMIT 1];
								 
			pse_Under_Consideration__c underConsideration = [SELECT Id,pse_idea__c 
								 from pse_Under_Consideration__c where pse_idea__c = :idea1.id LIMIT 1];
							
			//test an Under Consideratin record has been created
			System.assertEquals(underConsideration.pse_idea__c,idea1.id);
								 
	        //test the status of idea has been changed to Under Consideration by Committee
	        System.assertEquals(idea1.pse_Status__c,'Under Consideration by Committee');
	        					 
	        //test that the approver is the delegate approver, user2 (approver, user1 is on PTO)
	        System.assertEquals(idea1.pse_Approver_11__c,user2.id);
			
			
    	}
		catch (DmlException e) {
    		System.debug(e.getMessage());
		}
		Test.stopTest();
    }  
    
    //Approval Process test already tested in submitIdeaTest() test methid above         
}