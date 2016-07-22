trigger WFL_AfterLunchCreated on Lunch__c (after insert) {
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
        
        ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
    	messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        
        // add some text before the mention
        ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
        textSegment.text = 'Dear Gourmets,\n\n';
        textSegment.text += 'today\'s menu (' + lunch.Date__c.format() + ') is currently being cooked!\n';
		textSegment.text += 'We have the pleasure to serve you the following meal today:\n\n';
        
        if (lunch.Type__c == 'Special') {
            textSegment.text += '- Special Meal:\n';
            if (lunch.Special_Menu__c != null || lunch.Special_Menu__c != '')
	            textSegment.text += lunch.Special_Menu__c;
        } else {
            textSegment.text += '- Appetizer\n';
            textSegment.text += lunch.Appetizer__c;
            textSegment.text += '\n- Course\n';
            textSegment.text += lunch.Course__c;        
            textSegment.text += '\n- Dessert\n';
            textSegment.text += lunch.Desert__c;
        }
		textSegment.text += '\n';        
        messageInput.messageSegments.add(textSegment);
        
        // add the mention
        ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
        mentionSegment.id = groups.get(0).id;
        messageInput.messageSegments.add(mentionSegment);
        
        ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
        input.body = messageInput;
        input.feedElementType = ConnectApi.FeedElementType.FeedItem;
        input.subjectId = lunch.id;
        input.visibility = ConnectApi.FeedItemVisibilityType.AllUsers;
        
		ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(null, input, null);
        ConnectApi.Topics.assignTopicByName(null, feedElement.id, 'Gourmet');
        ConnectApi.Topics.assignTopicByName(null, feedElement.id, 'Today\'s Lunch Menu');       
    } catch (Exception e) {
        System.debug('WFL - An exception occured after the lunch has been created, m=' + e.getMessage());
    }
}