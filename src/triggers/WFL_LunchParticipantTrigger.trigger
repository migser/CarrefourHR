trigger WFL_LunchParticipantTrigger on Lunch_Participant__c (after delete) {
    try {
        Lunch_Participant__c lp = Trigger.old[0];
        Lunch_Meetup__c lm = [select id, CreatedById from Lunch_Meetup__c
                              WHERE id =: lp.Lunch_Meetup__c Limit 1];
        if (lm == null)
            System.debug('WFL - lm is null');
        
        List<Event> le = [select id, subject, location, StartDateTime, EndDateTime, WhatId, OwnerId
                          from Event
                          where 
                          WhatId =: lm.Id AND OwnerId =: lm.CreatedById
                         ];
        
        if (le == null || le.size() == 0)
            return;
        
        Event e = le.get(0);
        EventRelation er = [select id, EventId from EventRelation where EventId =: e.Id limit 1];
        delete (er);
        
    } catch (Exception e)
    {
        System.debug('WFL - Error while removing Lunch Participant, m=' + e.getMessage());
    }
}