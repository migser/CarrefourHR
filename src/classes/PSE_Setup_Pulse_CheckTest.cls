@isTest
private class PSE_Setup_Pulse_CheckTest {
	@isTest
    private static void testCreateSampleData() {
        PSE_Setup_Pulse_Check setupPulseCheck = new PSE_Setup_Pulse_Check();
        setupPulseCheck.createSampleData();
        
        Integer numOfProjects = [SELECT Count() FROM PSE_PulseCheck_Project__c];       
        System.assertEquals(setupPulseCheck.numOfProjects, numOfProjects, 'Incorrect number of Projects produced.');
        
        Integer numOfFeedbacks = [SELECT Count() FROM PSE_Employee_Feedback__c];
        System.assertEquals(setupPulseCheck.numOfFeedbacks, numOfFeedbacks, 'Incorrect number of Employee Feedbacks produced.');
        
        Integer numOfFeedbacksWithSendCopyToLineManager = [
            SELECT Count() FROM PSE_Employee_Feedback__c WHERE PSE_Send_copy_to_line_manager__c = true
        ];
        System.assertEquals(0, numOfFeedbacksWithSendCopyToLineManager, 
            'createSampleData() is setting "Send copy to line manager" true for at least one record');
                            
        Integer numOfFeedbacksWithSendCopyToProjectManager = [
            SELECT Count() FROM PSE_Employee_Feedback__c WHERE PSE_Send_copy_to_project_manager__c = true
        ];
        System.assertEquals(0, numOfFeedbacksWithSendCopyToProjectManager, 
            'createSampleData() is setting "Send copy to project manager" true for at least one record');
    }
    
    @isTest
    private static void testDeleteData() {
        PSE_Setup_Pulse_Check setupPulseCheck = new PSE_Setup_Pulse_Check();
        setupPulseCheck.createSampleData();
        setupPulseCheck.deleteData();
        Integer numOfProjects = [SELECT Count() FROM PSE_PulseCheck_Project__c];       
        System.assertEquals(0, numOfProjects, 'Some Projects were not deleted correctly.');
        
        Integer numOfFeedbacks = [SELECT Count() FROM PSE_Employee_Feedback__c];
        System.assertEquals(0, numOfFeedbacks, 'Some Employee Feedbacks were not deleted correctly.');        
    }
}