trigger WFL_BeforeLunchCreated on Lunch__c (before insert) {
try {
        //Post to Chatter Group
        Lunch__c lunch = Trigger.new[0];
        
        System.debug('WFL - Lunch Created with Status=' + lunch.Status__c + ' - ' + lunch.id);
        
        List<CollaborationGroup> groups =
            [select id, Name from CollaborationGroup WHERE Name = 'What\'s for Lunch' LIMIT 1];
        if (groups == null || groups.size() == 0)
        {
            System.debug('WFL - What\'s for Lunch chatter group does not exist, cannot post message');
            return;
        }
        
        //Post only if lunch menu is approved
        if (lunch.Status__c != 'Lunch menu ready')
            return;
    
	    lunch.Menu_has_been_posted__c = true;    
    
    } catch (Exception e) {
        System.debug('WFL - An exception occured before the lunch has been created, m=' + e.getMessage());
    }
}