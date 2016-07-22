trigger WFL_LunchMeetupCreated on Lunch_Meetup__c (after insert) {
    try {
        //Lunch Meetup Created, need to create a new calendar event
        Lunch_Meetup__c lm = Trigger.new[0];
        
        Event event = new Event();
        
        event.IsPrivate = false;
        event.Location = lm.Address__c;
        event.OwnerId = lm.CreatedById;
        event.Subject = lm.Name;
        event.WhatId = lm.id;      
        event.StartDateTime = lm.Start_Date_Time__c;
        event.EndDateTime = lm.End_Date_Time__c;
        event.ReminderDateTime = lm.Start_Date_Time__c.addMinutes(-15);
        event.IsReminderSet = true;
        
        insert(event);
        
        //Add Lunch Meetup owner as a participant
        Lunch_Participant__c lp = new Lunch_Participant__c();
        lp.Employee__c = lm.CreatedById;
        lp.Lunch_Meetup__c = lm.Id;
        
        insert(lp);
        
    } catch (Exception e) {
        System.debug('WFL - An exception occured after the lunch meetup has been created, m=' + e.getMessage());
    }
}