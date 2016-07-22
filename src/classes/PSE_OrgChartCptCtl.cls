public with sharing class PSE_OrgChartCptCtl {
    @AuraEnabled
    public  static map<string,object> getHierarchy(string userid) { 
        if(userid == null || userid == '')
            userid = UserInfo.getUserId();
        User currentUser=getFocusUser(userid);
        
        map<string,object> JSONHierarchy = new map<string,object>();
        JSONHierarchy.put('selectedUser', currentUser);
        list<User> listManagers=getListMasters(new list<User>{currentUser});
        JSONHierarchy.put('listManagers', listManagers);        
        JSONHierarchy.put('listReports', getReports(currentUser));
        if (!listManagers.isEmpty()) // siblings
            JSONHierarchy.putAll(getSiblings(currentUser));
        return JSONHierarchy;
    } 
    
    // ===========================
    // Get selected User
    // ===========================
    public static User getFocusUser(id currentFocusUserId) {
        User u = [SELECT Id, Name, FirstName, LastName, UserRoleId, UserRole.Name, Title, ProfileId, ManagerId, Manager.Name, FullPhotoUrl, SmallPhotoUrl, Phone, Email
                  FROM User 
                  WHERE Id = :currentFocusUserId];
        return u; 
    }
    
    // ===========================
    // Get Siblings
    // ===========================
    public static map<string,object> getSiblings(User currentUser)  {
        map<string,object> JSONSiblings=new map<string, object>();
            list<User> listSiblings=[select id from User where ManagerId=:currentUser.ManagerId order by Name asc];
            if(listSiblings.size()>1) {
                for (integer i=0;i<listSiblings.size();i++) {
                    if (listSiblings[i].Id==currentUser.Id) {
                        if (i-1>=0)
                            JSONSiblings.put('prevSibling', listSiblings[i-1]); 
                        if (i+1<listSiblings.size())
                            JSONSiblings.put('nextSibling', listSiblings[i+1]);
                        break;
                    }
                }   
        }
        return JSONSiblings;
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
    // Get Managers
    // ===========================
    public static list<User> getListMasters(list<User> listUsers) {
        if(listUsers.isEmpty())
            return null;
        User u=listUsers[0];
        if (u.ManagerId!=null)  { 
            User manager=[SELECT Id, Name, FirstName, LastName, UserRoleId, UserRole.Name, Title, ProfileId, ManagerId, Manager.Name, FullPhotoUrl, SmallPhotoUrl, Phone, Email
                          FROM User WHERE Id = :u.ManagerId];
            listUsers.add(0,manager);
            return getListMasters(listUsers);
        }
        else {
            listUsers.remove(listUsers.size()-1); // remove current user
            return listUsers;
        }
    }
    
    // ===========================
    // GET USER SEARCH
    // ===========================
    @AuraEnabled
    public static list<User> getUserSearch(string inSearchStr) {
        system.debug('in the user search: ' + inSearchStr);
        return [FIND :inSearchStr IN ALL FIELDS RETURNING User(id,name,Title, ProfileId, ManagerId, Manager.Name, FullPhotoUrl, SmallPhotoUrl, Phone, Email)][0];        
    }
}