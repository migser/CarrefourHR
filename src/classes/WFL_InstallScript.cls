global class WFL_InstallScript implements InstallHandler {
    
    global void onInstall(InstallContext context) {
        if (context.previousVersion() == null) {
            // Verify it does not exist
            List<CollaborationGroup> myGroups = [SELECT Id,Name From CollaborationGroup WHERE CollaborationType='Public' AND Name = 'What\'s for Lunch'];
			if (myGroups != null && myGroups.size() > 0)
            {
                System.debug('WFL - Group already created, skipping creation');
                return;
            }
	
            // Create Chatter Group
            CollaborationGroup myGroup = new CollaborationGroup();
            myGroup.Name = 'What\'s for Lunch';
            myGroup.CollaborationType = 'Public';
            insert myGroup;
        }
    }
}