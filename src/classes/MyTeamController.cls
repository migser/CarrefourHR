public with sharing class MyTeamController {
    @AuraEnabled
    public  static map<string,object> getHierarchy(string userid, boolean useContacts) { 
        if(userid == null || userid == '')
            userid = UserInfo.getUserId();
        User currentUser=getFocusUser(userid);
        map<string,object> JSONHierarchy = new map<string,object>();
        if(useContacts==false){
            JSONHierarchy.clear();
            JSONHierarchy.put('selectedUser', currentUser);
            JSONHierarchy.put('listReports', getReports(currentUser));
        }else if(useContacts==true && currentUser.ContactId!=null) {
            JSONHierarchy.clear();
            JSONHierarchy.put('selectedUser', currentUser);
            JSONHierarchy.put('listReports', getReportsToContacts(currentUser));
        }
        return JSONHierarchy;
    } 
    
    // ===========================
    // Get selected User
    // ===========================
    public static User getFocusUser(id currentFocusUserId) {
        User u = [SELECT Id, Name, ContactId, ReportsToContact__c, FirstName, LastName, UserRoleId, UserRole.Name, Title, ProfileId, ManagerId, Manager.Name, Manager.Email, Manager.Phone, Manager.Title, Manager.SmallPhotoUrl, FullPhotoUrl, SmallPhotoUrl, Phone, Email
                  FROM User 
                  WHERE Id = :currentFocusUserId];
        return u; 
    }

    // ===========================
    // Get Reports
    // ===========================
    public static list<User> getReports(User u) {
        return [SELECT Id, Name, FirstName, LastName, UserRoleId, UserRole.Name, Title, ProfileId, ManagerId, Manager.Name, FullPhotoUrl, SmallPhotoUrl, Phone, Email
                FROM User 
                WHERE ManagerId = :u.Id 
                AND isActive = true
                ORDER BY Name asc
                Limit 100];
    }
    // ===========================
    // Get ReportsTo Contacts
    // ===========================    
	public static list<User> getReportsToContacts(User u) {
        //ReportsToContact__c is a formula field on the User Object that looks up the Contact.ReportTo.Id (i.e the contcact Id of the person this contact reports to)
        System.debug('u.ContactId &&&&&&&&&&&&&&&& '+u.ContactId);
        return [SELECT Id, Name, FirstName, LastName, UserRoleId, UserRole.Name, Title, ProfileId, ManagerId, Manager.Name, FullPhotoUrl, SmallPhotoUrl, Phone, Email
                FROM User 
                WHERE ReportsToContact__c =: u.ContactId
          		AND isActive = true
          		ORDER BY Name asc
                Limit 100];
    }    
}