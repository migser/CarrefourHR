public class QSF_RFL_ReferralProgramServices {
    private static final String MENTION_TOKEN = '#mention#';
    
    public static void followApplication(QSF_RFL_Referral__c referral) {
		//ConnectApi.ChatterUsers.follow(null, 'me', referral.Id);
		ConnectApi.ChatterUsers.follow(null, 'me', referral.application__c);
    }

    public static void shareApplicationWithReferrer(QSF_RFL_Referral__c referral) {
        //Share
        QSF_RFL_Application__Share appShr  = new QSF_RFL_Application__Share();   
        appShr.ParentId = referral.Application__c;
        appShr.UserOrGroupId = referral.Referrer__c;
        appShr.AccessLevel = 'Read';
        appShr.RowCause = Schema.QSF_RFL_Application__Share.RowCause.Manual;
        insert appShr;        
    }
    
    public static void notifyHiringManager(String applicationId) {
		QSF_RFL_Application__c application = [SELECT Id, Name, Position__r.Name, Contact__r.Name, 
	                                                 Position__r.Hiring_Manager__c, Position__r.Hiring_Manager__r.Name
                                        	  FROM QSF_RFL_Application__c
                                        	  WHERE Id = :applicationId];
        
        if (application.Position__r.Hiring_Manager__c != null) {
            //Notify
            ConnectApi.MessageBodyInput body = new ConnectApi.MessageBodyInput();
            body.messageSegments = new List<ConnectApi.MessageSegmentInput>();
            
            ConnectApi.TextSegmentInput textSegment1 = new ConnectApi.TextSegmentInput();
            String text = 'Hi ' + application.Position__r.Hiring_Manager__r.Name + 
                                ',\nThere is a new application for the position ' + application.Position__r.Name + '.\n\n';
            textSegment1.text = text;
            body.messageSegments.add(textSegment1);
                                    
            ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput(); //The whole post
            feedItemInput.body = body;
            feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
            feedItemInput.subjectId = application.Position__r.Hiring_Manager__c;
    
            // add the link attachment
            ConnectApi.LinkCapabilityInput linkInput = new ConnectApi.LinkCapabilityInput();
            linkInput.urlName = 'Application: ' + application.Name;
            linkInput.url = '/' + application.Id;
            
            ConnectApi.FeedElementCapabilitiesInput capabilities = new ConnectApi.FeedElementCapabilitiesInput();
            feedItemInput.capabilities = capabilities;
            feedItemInput.capabilities.link = linkInput;
            
            ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput, null);
        }
    }
    
    public static void notifyReferrerOnSelection(String referralId) {
		QSF_RFL_Referral__c referral = [SELECT Id, Name, Referrer__c, Application__c, 
                                        	   Application__r.Position__r.Name, Application__r.Contact__r.Name, Application__r.Name
                                        FROM QSF_RFL_Referral__c
                                        WHERE Id = :referralId];
		
		String text = 'Congratulations ' + MENTION_TOKEN + ',\n' + referral.Application__r.Contact__r.Name + 
            		  ' has been selected for position ' + referral.Application__r.Position__r.Name;

        QSF_RFL_ReferralProgramServices.postToReferrer(referral, text);
    }

    public static void thankReferrer(String referralId) {
		QSF_RFL_Referral__c referral = [SELECT Id, Name, Referrer__c, Application__c, 
                                        	   Application__r.Position__r.Name, Application__r.Contact__r.Name, Application__r.Name
                                        FROM QSF_RFL_Referral__c
                                        WHERE Id = :referralId];
        
        String text = 'Thanks ' + MENTION_TOKEN + ' for referring ' + referral.Application__r.Contact__r.Name + ' for the ' + 
            				  referral.Application__r.Position__r.Name + ' position.\n\n We\'ll keep you updated!';

        QSF_RFL_ReferralProgramServices.postToReferrer(referral, text);
    }
    
    public static void postToReferrer(QSF_RFL_Referral__c referral, String text) {
		List<String> comps = text.split(MENTION_TOKEN);
        String prefix = comps[0];
        String suffix = comps[1];
        
        ConnectApi.MessageBodyInput body = new ConnectApi.MessageBodyInput();
        body.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        
        ConnectApi.TextSegmentInput textSegment1 = new ConnectApi.TextSegmentInput();
        textSegment1.text = prefix;
        body.messageSegments.add(textSegment1);

        ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
        mentionSegment.id = referral.Referrer__c;
        body.messageSegments.add(mentionSegment);
                
        ConnectApi.TextSegmentInput textSegment2 = new ConnectApi.TextSegmentInput();
        textSegment2.text = suffix;
        body.messageSegments.add(textSegment2);
                
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput(); //The whole post
        feedItemInput.body = body;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = referral.application__c;

        // add the link attachment
        ConnectApi.LinkCapabilityInput linkInput = new ConnectApi.LinkCapabilityInput();
        linkInput.urlName = 'Referral: ' + referral.Name;
        linkInput.url = '/' + referral.Id;
        
        ConnectApi.FeedElementCapabilitiesInput capabilities = new ConnectApi.FeedElementCapabilitiesInput();
		feedItemInput.capabilities = capabilities;
        feedItemInput.capabilities.link = linkInput;
        
        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput, null);
    }
    
}