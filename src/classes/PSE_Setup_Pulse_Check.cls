public class PSE_Setup_Pulse_Check {
    public static PageReference listView(Schema.sObjectType destinationSObject) {
        Schema.DescribeSObjectResult destination = destinationSObject.getDescribe();
        PageReference pageRef = new PageReference('/' + destination.getKeyPrefix() );
        pageRef.setRedirect(true);
        return pageRef;
    }

    /*
    public static PageReference landingPage(Schema.sObjectType destinationSObject) {
        Schema.DescribeSObjectResult destination = destinationSObject.getDescribe();
        PageReference pageRef = new PageReference('/' + destination.getKeyPrefix() + '/o' );
        pageRef.setRedirect(true);
        return pageRef;
    }
    */

    public static Integer rand(Integer max) {
        return (Integer) (Math.random() * max);
    }
    public static Boolean randBoolean() {
        return (Math.random() > 0.5 ? true : false);
    }
    
    public Integer numOfProjects { get; set; }
    public Integer numOfFeedbacks { get; set; }

    private String[] projectNames;
    private String[] priorities;
    private String[] reqEff;

    public PSE_Setup_Pulse_Check() {
        numOfFeedbacks = 50;
        
        String projectNamesString = 'Project Cloud,Project X,Archimedes,Migration to Salesforce,SAP Upgrade,Upgrade to Oracle 12,Project Chrome,Apollo Program,Encryption Deployment,Quick Start Apps';
        projectNames = projectNamesString.split(',');
        numOfProjects = projectNames.size();
        
        priorities = 'High,Medium,Low'.split(',');
        reqEff = 'Technical equipment,Workspace environment,Team work,Manager\'s communication,Team\'s communication,Work load management)'.split(',');
    }

    public PageReference createSampleData() {
        System.debug('createSampleData() called.');

        RecordType rtProject = [
            SELECT Id,Name,DeveloperName 
            FROM RecordType 
            WHERE DeveloperName='PSE_Employee_Feedback_Project' 
            LIMIT 1][0];
        RecordType rtWork = [
            SELECT Id 
            FROM RecordType 
            WHERE DeveloperName='PSE_Employee_Feedback_Work' 
            LIMIT 1][0];

        System.debug('rtProject: ' + rtProject.Id);
        System.debug('rtWork: ' + rtWork.Id);

        PSE_PulseCheck_Project__c[] projects = new List<PSE_PulseCheck_Project__c>();
        User[] users = [SELECT Id, Name FROM User WHERE UserType='Standard' LIMIT 20];

        for(Integer i=0; i<numOfProjects; i++) {
            Integer userIndex = rand(users.size()); 
            User projectManager = users[userIndex];
            Integer priorityIndex = rand(priorities.size());
            String priority = priorities[priorityIndex];

            PSE_PulseCheck_Project__c p = new PSE_PulseCheck_Project__c(
                Name = projectNames[i],
                PSE_Is_Executive_sponsored__c = randBoolean(),
                PSE_Project_Manager__c = projectManager.Id,
                PSE_Project_Priority__c = priority,
                PSE_Start_Date__c = Date.today().addDays(-rand(100)),
                PSE_End_Date__c = Date.today().addDays(rand(100))
            );    
            projects.add(p);
        }
        insert projects;

        PSE_Employee_Feedback__c[] feedbacks = new List<PSE_Employee_Feedback__c>();

        for(Integer i=0; i<numOfFeedbacks; i++) {
            Integer userIndex = (Integer) (Math.random() * users.size()); 
            User employee = users[userIndex];
            
            PSE_Employee_Feedback__c feedback;
            if(Math.mod(i,2) == 0) {
                feedback = new PSE_Employee_Feedback__c(
                    RecordTypeId = rtProject.Id,
                    OwnerId = employee.Id,
                    PSE_Believe_budget__c = String.valueOf(rand(5)+1),
                    PSE_Believe_success__c = String.valueOf(rand(5)+1),
                    PSE_Believe_time__c = String.valueOf(rand(5)+1),
                    PSE_Current_Project__c = projects[Math.mod(i, projects.size())].Id,
                    PSE_Send_copy_to_line_manager__c = false,
                    PSE_Send_copy_to_project_manager__c = false,
                    PSE_What_could_we_have_done_better__c = 'Text',
                    PSE_What_should_we_change__c = 'Text',
                    PSE_What_went_well_this_week__c = 'Text'
                );
            }
            else {
                feedback = new PSE_Employee_Feedback__c(
                    RecordTypeId = rtWork.Id,
                    OwnerId = employee.Id,
                    PSE_Feel_expectations_realistic__c = String.valueOf(rand(5)+1),
                    PSE_Feel_positively_challenged__c = String.valueOf(rand(5)+1),
                    PSE_Feel_pressure__c = String.valueOf(rand(5)+1),
                    //PSE_Required_to_work_more_productively__c = 'multipicklist (Technical equipment, Workspace environment, Team work, Manager\'s communication, Team\'s communication, Work load management)',
                    PSE_Send_copy_to_line_manager__c = false,
                    PSE_Send_copy_to_project_manager__c = false,
                    PSE_What_could_we_have_done_better__c = 'Text',
                    PSE_What_should_we_change__c = 'Everything',
                    PSE_What_went_well_this_week__c = 'Nothing'
                );
            }
            feedbacks.add(feedback);
        }
        insert feedbacks;

        return listView(PSE_Employee_Feedback__c.sObjectType);
    }

    public PageReference deleteData() {
        for(PSE_Employee_Feedback__c[] feedbacks: [SELECT Id FROM PSE_Employee_Feedback__c]) {
            delete feedbacks;
        }
        for(PSE_PulseCheck_Project__c[] projects: [SELECT Id FROM PSE_PulseCheck_Project__c]) {
            delete projects;    
        }
        return listView(PSE_Employee_Feedback__c.sObjectType);
    }

}