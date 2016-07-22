trigger setEricJonesAsApplicant on HR_Job_Application__c (before insert) {

    Id ericId = [SELECT Id FROM Contact WHERE Name = 'Eric Jones' LIMIT 1].Id;

    for(HR_Job_Application__c app : Trigger.New) {
    
        app.Employee__c = ericId;
        
    }

}