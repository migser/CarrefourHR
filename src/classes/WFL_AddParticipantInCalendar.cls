global with sharing class WFL_AddParticipantInCalendar {
    
    webservice static String addParticipant(String userId, String lunchMeetup) {
        try {System.debug('WFL - ' + userId + ' - ' + lunchMeetup);
             
             Event e = [select id, subject, StartDateTime, WhatId, OwnerId
                        from Event where WhatId =: lunchMeetup limit 1];
             
             //Verify if Participant already exists
             List<Lunch_Participant__c> lpT = [select id, name from Lunch_Participant__c
                                         where Employee__c =: userId AND Lunch_Meetup__c =: lunchMeetup];
             if (lpT != null && lpT.size() > 0)
             {
                 System.debug('WFL - Participant is already attending the lunch meetup');
                 return 'You are already attending this lunch meetup';
             }
             
             EventRelation er = new EventRelation(EventId = e.Id, 
                                                  RelationId = userId);
             Database.DMLOptions dlo = new Database.DMLOptions();
             dlo.EmailHeader.triggerUserEmail  = true;
             dlo.EmailHeader.triggerOtherEmail  = true;
             dlo.EmailHeader.triggerAutoResponseEmail = false;
             Database.insert(er,dlo);
             
             //Create Participant
             Lunch_Participant__c lp = new Lunch_Participant__c();
             lp.Employee__c = userId;
             lp.Lunch_Meetup__c = lunchMeetup;
             insert(lp);
             
             return '';
            }
        catch (Exception ex) {
            System.debug('WFL - Error while adding Participant to Calendar Event, m=' + ex.getMessage());
            return 'Error while adding Participant to Calendar Event, m=' + ex.getMessage();
        }
    }
}