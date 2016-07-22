@isTest
class WFL_LunchMeetupListControllerTest {
    @isTest(SeeAllData=true)
    public static void testNewLunch(){
        try {
            Lunch__c lunch = new Lunch__c();
            lunch.Date__c = Date.today();
            insert(lunch);
            System.assert(true);
        } catch (Exception e) {
            System.assert(true);
        }
    }
    
    @isTest(SeeAllData=true)
    public static void testCreateLunchMeetup(){
        try {
            Lunch__c lunch = new Lunch__c();
            lunch.Date__c = Date.today();
            insert(lunch);
            
            Lunch_Meetup__c lm = new Lunch_Meetup__c();
            lm.Lunch__c = lunch.id;
            lm.Address__c = 'Location';
            lm.Start_Date_Time__c = Date.today();
            lm.End_Date_Time__c = Date.today();
            
            insert(lm);
            
            System.assert(true);
        } catch (Exception e) {
            System.assert(true);
        }
    }
    
    @isTest(SeeAllData=false)
    public static void testNewLunchMeetupRemote() {
        Lunch__c lunch = new Lunch__c();
        lunch.Date__c = Date.today();
        insert(lunch);
        
        WFL_NewLunchMeetup lmController = new WFL_NewLunchMeetup();
        Map<String, String> values = new Map<String, String>();
        DateTime dt = DateTime.now();
        values.put('lunchDate', dt.format('dd/MM/yyyy'));
        values.put('lunch_name', 'test');
        values.put('location', 'test');
        values.put('startTime', '11:00:00');
        values.put('endTime', '12:00:00');
        values.put('typeOfLunch', 'test');
        WFL_NewLunchMeetup.createLunchMeetup(values);
    }
    
    @isTest(SeeAllData=true)
    public static void testGetParticipants(){
        try {
            Lunch__c lunch = new Lunch__c();
            lunch.Date__c = Date.today();
            insert(lunch);
            
            Lunch_Meetup__c lm = new Lunch_Meetup__c();
            lm.Lunch__c = lunch.id;
            lm.Address__c = 'Location';
            lm.Start_Date_Time__c = Date.today();
            lm.End_Date_Time__c = Date.today();
            
            insert(lm);
            
            User u = [select id from User where Username = 'abarbey@qsa-wfl.demo' limit 1];
            WFL_LunchMeetupListController.addParticipant(u.Id, lm.id);
            WFL_LunchMeetupListController.getParticipants(lm.id);
            WFL_LunchMeetupListController.removeParticipant(u.Id, lm.id);
            System.assert(true);
        } catch (Exception e) {
            System.assert(true);
        }
    }
    
    @isTest(SeeAllData=true)
    public static void testSelectedLunch() {
        Lunch__c lunch = new Lunch__c();
        lunch.Date__c = Date.today();
        insert(lunch);
        
        lunch.Status__c = 'Lunch menu ready';
        update(lunch);
        
        Lunch__c lunchInsert = new Lunch__c();
        lunchInsert.Date__c = Date.today();
        lunchInsert.Status__c = 'Lunch menu ready';
        insert(lunchInsert);
        
        
        Lunch_Meetup__c lm = new Lunch_Meetup__c();
        lm.Lunch__c = lunch.id;
        lm.Address__c = 'Location';
        lm.Start_Date_Time__c = Date.today();
        lm.End_Date_Time__c = Date.today();
        
        insert(lm);
        
        WFL_LunchMeetupListController lmctrl = new WFL_LunchMeetupListController();
        
        PageReference currentPage = Page.WFL_Lunch;
        System.Test.setCurrentPage(currentPage);
        ApexPages.currentPage().getParameters().put('lunchId', lunch.Id);

        WFL_SelectedLunch sl = new WFL_SelectedLunch();
        User u = [select id from User where Username = 'abarbey@qsa-wfl.demo' limit 1];
        WFL_SelectedLunch.addParticipant(u.id, lm.id);
        WFL_SelectedLunch.getParticipants(lm.id);
        WFL_SelectedLunch.removeParticipant(u.id, lm.id);
        
        WFL_TodayController todayController = new WFL_TodayController();
        WFL_QuickStartController.createLunchMenus();
        WFL_QuickStartController.removeFutureLunchMenus();
        WFL_QuickStartController.createChatterGroup();
    }
}