@isTest(Seealldata=true) 
public class TestMyTeamController {
    static testMethod void test() {
    Test.startTest();
        MyTeamController myTeamCon = new MyTeamController();
        String userid;
        Account a = new Account(Name='Raj Account');
        insert a;
        Contact c = new Contact(firstname ='Raj', lastname='Rao', AccountId=a.id);
        insert c; 
        Boolean useContacts = false;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='myteamsuser1@testorg.com');
        insert u;
        //to avoid the error Static methods cannot be invoked through an object instance: call 
        //the method from the controller MyTeamController as opposed ot an instance which would be myTeamCon
        MyTeamController.getHierarchy(userid, useContacts);
        useContacts = true;
        //u.contactId = c.id;
        //update u;
        MyTeamController.getHierarchy(userid, useContacts);
        MyTeamController.getReportsToContacts(u);
    Test.stopTest();    
    }
}