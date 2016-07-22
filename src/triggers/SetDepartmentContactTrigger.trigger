trigger SetDepartmentContactTrigger on Contact (before insert) {
  
    for(Contact c : Trigger.New){
        Account a = [SELECT Id,Name FROM Account WHERE Name = 'Candidates' LIMIT 1];
        if(c.Data_load__c == true){
            c.accountId = a.Id;
        }
    }
}