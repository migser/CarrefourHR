public class WFL_QuickStartController {
    
    public static final integer NB_DAYS_TO_CREATE = 180;
    
    @RemoteAction
    public static boolean createLunchMenus() {
        try {
            List<Lunch__c> lunchsToCreate = new List<Lunch__c>();
            Date currentDate = Date.today();
            for (integer i = 1; i <= NB_DAYS_TO_CREATE; i++) {
                Lunch__c lunch = new Lunch__c();
                lunch.Date__c = currentDate;
                // Set the First 2 to be approved
                if (i <= 2)
                    lunch.Status__c = 'Lunch menu ready';
                // First one gets a complete menu for example
                if (i == 1) {
                 	lunch.Appetizer__c = '- Tomato Salad';
                    lunch.Course__c = '- Deli Turkey & Cheese\n- Oven Baked Pizza';
                    lunch.Desert__c = '- Tiramisu';
                }
                lunchsToCreate.add(lunch);
                currentDate = currentDate.addDays(1);
            }
            List<Lunch__c> lunchs = [select id, Date__c from Lunch__c WHERE Date__c >= TODAY];
            for (Lunch__c lunch : lunchs) {
                integer lunchIndex = WFL_QuickStartController.getLunchIndex(lunchsToCreate, lunch.Date__c);
                if (lunchIndex != -1)
                    lunchsToCreate.remove(lunchIndex);
            }
            upsert(lunchsToCreate);
        } catch(Exception e) {
            System.debug('WFL - Cannot generate all lunch menus, m=' + e.getMessage());
            return false;
        }
        return true;
    }
    
    //TO IMPROVE - Not really optimized
    public static integer getLunchIndex(List<Lunch__c> lunchs, Date lunchDate) {
        integer lunchIndex = 0;
        for (Lunch__c lunch : lunchs) {
            if (lunch.Date__c == lunchDate)
                return lunchIndex;
            lunchIndex++;
        }
        return -1;
    }
    
    @RemoteAction
    public static boolean removeFutureLunchMenus() {
        try {
            List<Lunch__c> lunchsToDelete = new List<Lunch__c>();
            Date currentDate = Date.today();
            lunchsToDelete = [select id, Date__c from Lunch__c where Date__c > TODAY];
            if (lunchsToDelete != null)
                delete(lunchsToDelete);
        } catch(Exception e) {
            System.debug('WFL - Cannot remove all future lunch menus, m=' + e.getMessage());
            return false;
        }
        return true;
    }
    
    @RemoteAction
    public static boolean createChatterGroup() {
        try {
            List<CollaborationGroup> myGroups = [SELECT Id,Name From CollaborationGroup WHERE CollaborationType='Public' AND Name = 'What\'s for Lunch'];
			if (myGroups != null && myGroups.size() > 0)
            {
                System.debug('WFL - Group already created, skipping creation');
                return false;
            }
	
            // Create Chatter Group
            CollaborationGroup myGroup = new CollaborationGroup();
            myGroup.Name = 'What\'s for Lunch';
            myGroup.CollaborationType = 'Public';
            insert myGroup;
            
        } catch(Exception e) {
            System.debug('WFL - Cannot create Chatter Group, m=' + e.getMessage());
            return false;
        }
        return true;
    }
}