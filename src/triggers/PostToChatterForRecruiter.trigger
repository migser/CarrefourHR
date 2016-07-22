trigger PostToChatterForRecruiter on HR_Job__c (after insert) {

    Id recruiter = [SELECT Id FROM User WHERE LastName = 'Garcia' LIMIT 1].Id;
    Id HRAccount = [SELECT Id FROM User WHERE LastName = 'HR' LIMIT 1].Id;
    List<EntitySubscription> follows = new List<EntitySubscription>();
    List<FeedItem> posts = new List<FeedItem>();
    
    for(HR_Job__c job : Trigger.New) {
    	EntitySubscription follow = new EntitySubscription (
                                 parentId = job.Id,
                                 subscriberid = recruiter);
        follows.add(follow);

        FeedItem post = new FeedItem();
        post.ParentId = job.Id;
        post.Body = 'A new job requistion has been opened and assigned to you.';
        post.CreatedById = HRAccount;
        posts.add(post);
        
    }
    
	insert follows;
    insert posts;
    
    List<HR_Job__c> jobs = [SELECT OwnerId FROM HR_Job__c];
    
    for(HR_Job__c job : jobs) {
        job.OwnerId = HRAccount;
    }
    
    update jobs;
}