global class WFL_LunchMeetupListController {
    public List<LM> lunchMeetups {get; set;}
    
    public class LM {
        public String sfid {get; set;}
        public String name {get; set;}
        public String organiser  {get; set;}
        public String startDate  {get; set;}
        public String endDate  {get; set;}
        public String startTime  {get; set;}
        public String endTime  {get; set;}        
        public String location  {get; set;}
        public String nbParticipant  {get; set;}
        public String smallPhoto {get; set;}

        public LM(Lunch_Meetup__c lm, User u) {
            sfid = lm.Id;
            name = lm.Name;
			location = lm.Address__c;
            nbParticipant = String.valueOf(lm.Participants__c);
            organiser = u.Name;
            smallPhoto = u.SmallPhotoUrl;
            
            DateTime sdt = lm.Start_Date_Time__c;
            DateTime edt = lm.End_Date_Time__c;
            startDate = sdt != null ? sdt.format('d MMMM yyyy') : 'Not Set';
            startTime = sdt != null ? sdt.format('HH:mm') : 'Not Set';
            endTime = edt != null ? edt.format('HH:mm') : 'Not Set';
        }        
        
    }
    
    @RemoteAction
    global static Map<String, String> removeParticipant(String userId, String lunchMeetup) {
        try {
            List<Lunch_Participant__c> lps = [select id from Lunch_Participant__c
                                       where Lunch_Meetup__c =: lunchMeetup
                                       AND Employee__c =: userId];
            
            if (lps == null || lps.size() == 0)
	            return new Map<String, String>{'type' => 'KO', 'result' => 'KO', 'message' => 'You are not attending the lunch meetup, you cannot cancel your participation.'};    
                    
            Lunch_Participant__c lp = lps.get(0);
            delete(lp);
            
            return new Map<String, String>{'type' => 'OK', 'result' => 'OK', 'message' => 'You are not attending the lunch meetup anymore'};
        }
        catch (Exception ex) {
            System.debug('WFL - Error while removing Participant from Calendar Event, m=' + ex.getMessage());
            return new Map<String, String>{'type' => 'KO', 'result' => 'KO', 'message' => 'Error while removing Participant from Calendar Event, m=' + ex.getMessage()}; 
        }
    }
    
    @RemoteAction
    global static Map<String, String> addParticipant(String userId, String lunchMeetup) {
        try {System.debug('WFL - ' + userId + ' - ' + lunchMeetup);
             
             Event e = [select id, subject, StartDateTime, WhatId, OwnerId
                        from Event where WhatId =: lunchMeetup limit 1];
             
             EventRelation er = new EventRelation(EventId = e.Id, 
                                                  RelationId = userId);
             Database.DMLOptions dlo = new Database.DMLOptions();
             dlo.EmailHeader.triggerUserEmail  = true;
             dlo.EmailHeader.triggerOtherEmail  = true;
             dlo.EmailHeader.triggerAutoResponseEmail = false;
             Database.insert(er,dlo);
             
             //Verify if Participant already exists
             List<Lunch_Participant__c> lpT = [select id, name from Lunch_Participant__c
                                         where Employee__c =: userId AND Lunch_Meetup__c =: lunchMeetup];
             if (lpT != null && lpT.size() > 0)
             {
                 System.debug('WFL - Participant is already attending the lunch meetup');
             	 return new Map<String, String>{'type' => 'KO', 'result' => 'KO', 'message' => 'You are already attending this lunch meetup'};
             }
             
             //Create Participant
             Lunch_Participant__c lp = new Lunch_Participant__c();
             lp.Employee__c = userId;
             lp.Lunch_Meetup__c = lunchMeetup;
             insert(lp);
             
             return new Map<String, String>{'type' => 'OK', 'result' => 'OK', 'message' => 'Added'};
        }
        catch (Exception ex) {
            System.debug('WFL - Error while adding Participant to Calendar Event, m=' + ex.getMessage());
            return new Map<String, String>{'type' => 'KO', 'result' => 'KO', 'message' => 'Error while adding Participant to Calendar Event, m=' + ex.getMessage()};
        }
    }
    
    public WFL_LunchMeetupListController() { 
        List<Lunch_Meetup__c> lms = [select
                                     Id, Address__c, Name, Location__c, CreatedById, Participants__c,
                        			Start_Date_Time__c, End_Date_Time__c
                                     from Lunch_Meetup__c WHERE Start_Date_Time__c >= TODAY  
                                     ORDER BY Start_Date_Time__c DESC
                                     limit 50];
		
        lunchMeetups = new List<LM>();
        for (Lunch_Meetup__c lm : lms) {
            User u = [select id, Name, SmallPhotoUrl from User Where id =: lm.CreatedById limit 1];
            lunchMeetups.add(new LM(lm, u));
        }
    }
    
    public class LMParticipants {
        public String name {get; set;}
        public String smallPhotoUrl {get; set;}
        public String lunchMeetupId {get; set;}
        
        public LMParticipants(String pname, String url, String lmid) {
            name = pname;
            smallPhotoUrl = url;
            lunchMeetupId = lmid;
		}
    }
    
    @RemoteAction
    public static list<LMParticipants> getParticipants(String lunchMeetup) {
        List<Lunch_Participant__c> lps = [select id, Employee__c from Lunch_Participant__c
                                       where Lunch_Meetup__c =: lunchMeetup];
        
        List<LMParticipants> lmps = new List<LMParticipants>();
        
        for (Lunch_Participant__c lp : lps) {
            User u = [select id, Name, SmallPhotoUrl from User Where id =: lp.Employee__c limit 1];
            lmps.add(new LMParticipants(u.Name, u.SmallPhotoUrl, lunchMeetup));
        }
        
        return lmps;
    }
}