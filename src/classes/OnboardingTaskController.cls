public class OnboardingTaskController {
    
    @AuraEnabled
    public static List<TaskWrapper> getOnBoardingTasks() {
        
        List<AggregateResult> tasks = [SELECT COUNT(Id) CompletedCount, RecordType.Name, Is_Complete__c FROM Task 
             WHERE RecordType.Name IN ('7 Day Onboarding','30 Day Onboarding','90 Day Onboarding') 
             GROUP BY RecordType.Name, Is_Complete__c];

        integer complete7 = 0;
        integer incomplete7 = 0;
        integer complete30 = 0;
        integer incomplete30 = 0;
        integer complete90 = 0;
        integer incomplete90 = 0;
        
        for(AggregateResult ts : tasks) {
            
            if(ts.get('Is_Complete__c') == true) {
                
                if(ts.get('Name') == '7 Day Onboarding') {
                    complete7 = (Integer)ts.get('CompletedCount');
                }
                if(ts.get('Name') == '30 Day Onboarding') {
                    complete30 = (Integer)ts.get('CompletedCount');
                }
                if(ts.get('Name') == '90 Day Onboarding') {
                    complete90 = (Integer)ts.get('CompletedCount');            
                } 
            }
            
            if(ts.get('Is_Complete__c') == false) {
                
                if(ts.get('Name') == '7 Day Onboarding') {
                    incomplete7 = (Integer)ts.get('CompletedCount');
                }
                if(ts.get('Name') == '30 Day Onboarding') {
                    incomplete30 = (Integer)ts.get('CompletedCount');            
                }
                if(ts.get('Name') == '90 Day Onboarding') {
                    incomplete90 = (Integer)ts.get('CompletedCount');            
                } 
            }    
        }
		
       	List<TaskWrapper> results = new List<TaskWrapper>(); 	
       
        TaskWrapper tasks7 = new TaskWrapper();
        tasks7.incompleteCount = incomplete7;
        tasks7.completeCount = complete7;
        tasks7.header = '7 Day Tasks';
        tasks7.daysRemaining = 4;
        results.add(tasks7);
        
        TaskWrapper tasks30 = new TaskWrapper();
        tasks30.incompleteCount = incomplete30;
        tasks30.completeCount = complete30;
        tasks30.header = '30 Day Tasks';
        tasks30.daysRemaining = 27;
        results.add(tasks30);
        
        TaskWrapper tasks90 = new TaskWrapper();
        tasks90.incompleteCount = incomplete90;
        tasks90.completeCount = complete90;
        tasks90.header = '90 Day Tasks';
        tasks90.daysRemaining = 87;
        results.add(tasks90);
        
        return results;
    }
    
    @AuraEnabled
    public static List<Task> getIncompleteTasks(String taskType) {
        
        return [SELECT Id, Subject FROM Task WHERE Task_Type__c = :taskType AND Status != 'Completed'];

    }
}