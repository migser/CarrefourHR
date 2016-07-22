public class WFL_NewLunchMeetup {
    public List<SelectOption> typeOfLunchMeetup {get; set;}
    
    public WFL_NewLunchMeetup() {
        typeOfLunchMeetup = new List<SelectOption>();
        for(Schema.PicklistEntry e : Lunch_Meetup__c.Type__c.getDescribe().getPicklistValues()){
            typeOfLunchMeetup.add(new SelectOption(e.getValue(), e.getLabel()));
        }
    }
    
    @RemoteAction 
    public static List<String> getDates() {
        try {
            // Getting the next 3 lunch date available
            List<Lunch__c> lunchs = [select id, name, Date__c, Status__c
                                     from Lunch__c
                                     where Date__c >= TODAY AND Status__c = 'Lunch menu ready' ORDER BY Date__c ASC limit 5];
            
            List<String> dates = new List<String>();
            Date current = Date.today();
            for (Lunch__c lunch : lunchs) {
                dates.add(lunch.Date__c.format());
            }
            return dates;
        } catch (Exception e) {
            System.debug('WFL - Cannot get Dates, m=' + e.getMessage());
            return null;
        }
    }
    
    @RemoteAction 
    public static Map<String, String> createLunchMeetup(Map<String, String> values) {
        try {
            String lunchDate = values.get('lunchDate');
            String lunch_name = values.get('lunch_name');
            String location = values.get('location');
            String startTime = values.get('startTime');
            String endTime = values.get('endTime');
            String typeOfLunch = values.get('typeOfLunch');
            System.debug('WFL - New Lunch Meetup - Parsing Selected Date ' + lunchDate);
            
            Date lDate = Date.parse(lunchDate);
            integer shour = Integer.valueOf(startTime.substring(0, 2));
            integer sminute = Integer.valueOf(startTime.substring(3, 5));
            integer ssecond = Integer.valueOf(startTime.substring(6, 8));
            
            integer ehour = Integer.valueOf(endTime.substring(0, 2));
            integer eminute = Integer.valueOf(endTime.substring(3, 5));
            integer esecond = Integer.valueOf(endTime.substring(6, 8));
            
            DateTime lSDateTime = DateTime.newInstance(lDate.year(), lDate.month(), lDate.day(),
                                                      shour, sminute, ssecond);
            DateTime lEDateTime = DateTime.newInstance(lDate.year(), lDate.month(), lDate.day(),
                                                      ehour, eminute, esecond);
            
            if (lEDateTime.getTime() - lSDateTime.getTime() <= 0)
            {
                System.debug('WFL - Lunch duration should be greater than 0 minute');
                return new Map<String, String>{'type' => 'KO', 'result' => 'KO', 'message' => 'Lunch duration should be greater than 0 minute'};
            }
            
            System.debug('WFL - StartTime:' + startTime.substring(0, 2) + ' - ' + shour + ' - ' + sminute + ' - ' + ssecond);
            System.debug('WFL - EndTime:' + endTime.substring(3, 5) + ' - ' + ehour + ' - ' + eminute + ' - ' + esecond);
            
            List<Lunch__c> lunchs = [Select id, Name, Date__c from Lunch__c Where Date__c = :lDate LIMIT 10];
            if (lunchs == null || lunchs.size() == 0)
            {
                System.debug('WFL - No related lunch while creating Lunch Meetup for date: ' + lunchDate);
                return new Map<String, String>{'type' => 'KO', 'result' => 'KO', 'message' => 'There is no lunch available for that date'};
            }
            System.debug('WFL - Lunch for selected Lunch Meetup: ' + lunchs.get(0).Date__c);
            
            Lunch_Meetup__c lm = new Lunch_Meetup__c();
            lm.Name = lunch_name;
            lm.Lunch__c = lunchs.get(0).Id;
            lm.Address__c = location;
            lm.Start_Date_Time__c = lSDateTime;
            lm.End_Date_Time__c = lEDateTime;
            lm.Type__c = typeOfLunch;
            
            insert(lm);
            
            return new Map<String, String>{'type' => 'OK', 'result' => 'OK', 'message' => 'OK', 'lunchId' => lunchs.get(0).Id};
                } catch (Exception e) {
                	System.debug('WFL - Cannot create lunch meetup, m=' + e.getMessage());
                    return new Map<String, String>{'type' => 'exception', 'result' => 'KO', 'message' => e.getMessage()};
                }
    }
}