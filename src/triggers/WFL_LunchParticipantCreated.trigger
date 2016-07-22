trigger WFL_LunchParticipantCreated on Lunch_Participant__c (after insert) {
    try {
        Lunch_Participant__c lp = Trigger.new[0];
        
        Event e = [select id, subject, StartDateTime, WhatId, OwnerId
                   	from Event where WhatId =: lp.Lunch_Meetup__c limit 1];
        
        EventRelation er = new EventRelation(EventId = e.Id, 
                                             RelationId = lp.Employee__c);
        Database.DMLOptions dlo = new Database.DMLOptions();
        dlo.EmailHeader.triggerUserEmail  = true;
        dlo.EmailHeader.triggerOtherEmail  = true;
        dlo.EmailHeader.triggerAutoResponseEmail = false;
        Database.insert(er,dlo);

    } catch(Exception ex) {
        System.debug('WFL - An exception occured after the lunch participant has been created, m=' + ex.getMessage());
    }
}