public class WFL_TodayController {
    
    public Lunch__c todaysLunch {get;set;}
    public String lunchDescription {get;set;}
    public List<String> lmOrganisers {get;set;}
    public String lunchPictureUrl {get;set;}
        
        public WFL_TodayController () {
            loadTodaysLunch();
        }
    
    private void loadTodaysLunch() {
        try {
            todaysLunch = [select id, name, Lunch_Meetups__c,
                           Appetizer__c, Course__c, Date__c,
                           Desert__c, Special_Menu__c, Status__c, Type__c, RecordTypeId
                           from Lunch__c WHERE Date__c = TODAY AND Status__c = 'Lunch menu ready' LIMIT 1 ];
            
            List<Attachment> pictureAttachments = [SELECT Id, Name, Body, ContentType FROM Attachment 
                 WHERE parentId = :todaysLunch.id ORDER BY CreatedDate DESC];
            
            if (pictureAttachments.size() > 0) {
                lunchPictureUrl = '/servlet/servlet.FileDownload?file=' + pictureAttachments[0].id;
            }
            
            List<Lunch_Meetup__c> lms = [select
                                     id, Name, Start_Date_Time__c, CreatedById, Lunch__c
                                     from Lunch_Meetup__c lm where Lunch__c = :todaysLunch.id
                                     ORDER BY Start_Date_Time__c DESC
                                     limit 10];

            lmOrganisers = new List<String>();
            for (Lunch_Meetup__c lm : lms) {
                System.debug('WFL - Querying Each Lunch Meetup for the Organizer, size=' + lms.size() + ' - lm=' + lm.Name);
                User u = [select id, Name, SmallPhotoUrl from User Where id =: lm.CreatedById limit 1];
                    lmOrganisers.add(u.SmallPhotoUrl);
            }
                
            if (todaysLunch == null)
                return;
            if (todaysLunch.Type__c == 'Special')
            {
                if (todaysLunch.Special_Menu__c != null)
                    lunchDescription = todaysLunch.Special_Menu__c;
            }
            else {
                lunchDescription = '';
                if (todaysLunch.Appetizer__c != null)
                    lunchDescription += '<b>Appetizer</b><br/>' + todaysLunch.Appetizer__c + '<br/>';
                if (todaysLunch.Course__c != null)
                    lunchDescription += '<b>Course</b><br/>' + todaysLunch.Course__c + '<br/>';
                if (todaysLunch.Desert__c != null)
                    lunchDescription += '<b>Dessert</b><br/>' + todaysLunch.Desert__c + '<br/>';
            }
            if (lunchDescription == '')
                lunchDescription = 'Details not yet available';
        } catch (Exception e) {
            System.debug('WFL - Cannot retrieve todays lunch, m=' + e.getMessage());
        }
    }
    
}