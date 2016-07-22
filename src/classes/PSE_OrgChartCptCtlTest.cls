@isTest
public class PSE_OrgChartCptCtlTest {
    
    @testSetup static void setupData() {
        List<User> users = new List<User>();
        List<Profile> profiles = [select id from profile where  usertype = 'Standard' and userlicense.name = 'Salesforce'];
        for(Integer i=0 ; i<500 ; i++) {
            User u = new User();
            // have a go at a fairly random username using the UUID from profile
            u.username = 'user'+ i + '@'+profiles[0].id+'.com';
            u.email = 'user'+ i + '@'+profiles[0].id+'.com';
            u.lastname = 'user'+i;
            u.alias = 'u'+i;
            u.timezonesidkey = getTimezone();
            u.localesidkey = getLocale();
            u.emailencodingkey = getEmailEncoding();
            u.profileId = profiles.get(0).id;
            u.languagelocalekey = getLanguage();
            u.isActive = true;
            users.add(u);
        }
        insert users;       
    }
    
    /*
Test that the controller returns any number of results when passed 
null as the selected user. 
Does not look for load or any particular response. 
*/
    static testMethod void loadHierarchyNullUserTest() {
        
        Test.startTest();
        Map<String, Object> hierarchy = PSE_OrgChartCptCtl.getHierarchy(null);
        Test.stopTest();
        
        User selectedUser = (User)hierarchy.get('selectedUser');
        System.assert(hierarchy.size() > 0);
        System.assert(selectedUser.id == UserInfo.getUserId());
        
    }
    
    /*
Test that the controller returns any number of results when passed a User Id
as the selected user.
Does not look for load or any particular response;
*/
    static testMethod void loadHierarchyPopulatedUserTest() {
        
        User u = [select id from User limit 1];
        Test.startTest();
        Map<String, Object> hierarchy = PSE_OrgChartCptCtl.getHierarchy(u.id);
        Test.stopTest();
        
        System.assert(hierarchy.size() > 0);
        User selectedUser = (User)hierarchy.get('selectedUser');
        System.assert(hierarchy.size() > 0);
        System.assert(selectedUser.id == u.id);
        
    }
    
    /* Test Direct Reports (Up to 100 direct reports) */
    static testMethod void loadHierarchyDirectReportsTest() {
        
        List<User> users = [select id, managerId from user where username like 'user%' limit 201 ];
        
        // have a user with 100 direct reports
        for(Integer i=0; i <users.size() ; i++) {
            if(i>0) {
                users[i].managerId = users[0].id;
            }
        }
        update users;
        
        Test.startTest();
        Map<String, Object> hierarchy = PSE_OrgChartCptCtl.getHierarchy(users[0].id);
        Test.stopTest();
        
        List<User> reports = (List<User>)hierarchy.get('listReports');
        System.debug(LoggingLevel.INFO, '~~actual reports ['+reports.size()+']');
        System.assert(reports.size() == 100);
        
    }
    
    
    /* Test Management Chain (Up to 50 levels) */
    static testMethod void loadHierarchyManagersTest() {
        
        List<User> users = [select id, managerId from user where username like 'user%' limit 50 ];
        
        // have a user with 50 managers
        for(Integer i=0; i <users.size() ; i++) {
            if(i<users.size()-1) {
                users[i].managerId = users[i+1].id;
            }
        }
        update users;
        
        Test.startTest();
        Map<String, Object> hierarchy = PSE_OrgChartCptCtl.getHierarchy(users[0].id);
        Test.stopTest();
        
        List<User> managers = (List<User>)hierarchy.get('listManagers');
        System.debug(LoggingLevel.INFO, '~~actual managers ['+managers.size()+']');
        System.assert(managers.size() == 49);
        
    }
    
    /* Test User Search */
    static testMethod void testUserSearch() {
        test.startTest();
        list<user> searchUsers=PSE_OrgChartCptCtl.getUserSearch('user');
        test.stopTest();
        // All users begin with 'user' => function should return 500 users;
        System.debug(LoggingLevel.INFO, '~~actual users ['+searchUsers.size()+']');
    }
    
    static String getLocale () {
        List<String> locales = new List<String> {'ar','ca','ca_ES_EURO','ca_ES','zh','zh_CN','zh_HK','zh_TW','cs','cs_CZ','da_DK','nl','nl_BE','nl_NL','en_AU','en_CA','en_IE_EURO','en_IE','en_NZ',
            'en_ZA','en_GB','en_US','fi','fi_FI_EURO','fi_FI','fr','fr_BE','fr_CA','fr_FR_EURO','fr_FR','fr_LU','fr_CH','de','de_AT_EURO','de_AT','de_DE_EURO',
            'de_DE','de_LU_EURO','de_LU','de_CH','el_GR','iw','it','it_IT','it_CH','ja','ja_JP','ko','ko_KR','no','no_NO','pl','pt','pt_BR','pt_PT','ru','es',
            'es_AR','es_CO','es_MX','es_ES_EURO','es_ES','es_VE','sv','sv_SE','th','th_TH','tr'};
                
                return locales[0];
    }
    static String getLanguage() {
        List<String> languages = new List<String>{'en_US','de','es','fr','it','ja','sv','ko','zh_TW','zh_CN','pt_BR','nl_NL','th','fi','ru'};
            
            return languages[0];
    }
    static String getTimezone() {
        List<String> timezones = new List<String>{'Africa/Cairo','Africa/Johannesburg','Africa/Nairobi','America/Anchorage','America/Bogota','America/Buenos_Aires','America/Caracas',
            'America/Chicago','America/Denver','America/El_Salvador','America/Halifax','America/Indianapolis','America/Lima','America/Los_Angeles','America/Mexico_City',
            'America/New_York','America/Panama','America/Phoenix','America/Puerto_Rico','America/Sao_Paulo','America/St_Johns','America/Tijuana','Asia/Baghdad','Asia/Bangkok',
            'Asia/Calcutta','Asia/Colombo','Asia/Dacca','Asia/Dubai','Asia/Hong_Kong','Asia/Jakarta','Asia/Jerusalem','Asia/Kabul','Asia/Kamchatka','Asia/Karachi','Asia/Katmandu',
            'Asia/Kuala_Lumpur','Asia/Kuwait','Asia/Manila','Asia/Riyadh','Asia/Saigon','Asia/Seoul','Asia/Shanghai','Asia/Singapore','Asia/Taipei','Asia/Tashkent',
            'Asia/Tbilisi','Asia/Tehran','Asia/Tokyo','Asia/Yekaterinburg','Atlantic/Bermuda','Atlantic/Cape_Verde','Atlantic/South_Georgia','Australia','Australia/Lord_Howe',
            'Europe/Amsterdam','Europe/Athens', 'Europe/Berlin','Europe/Brussels','Europe/Bucharest','Europe/Dublin','Europe/Helsinki','Europe/Istanbul','Europe/Lisbon',
            'Europe/London','Europe/Minsk','Europe/Moscow','Europe/Paris','Europe/Prague','Europe/Rome','GMT','New South Wales','Northern Territory','Pacific/Chatham',
            'Pacific/Auckland','Pacific/Enderbury','Pacific/Fiji','Pacific/Guadalcanal','Pacific/Honolulu','Pacific/Niue','Pacific/Norfolk','Pacific/Pago_Pago',
            'Pacific/Tongatapu','Queensland','South Australia'};
                
                return timezones[0];
    }
    static String getEmailEncoding () {
        List<String> emailEncoding = new List<String> {'UTF-8','ISO-8859-1','Shift_JIS','ISO-2022-JP','EUC-JP','ks_c_5601-1987','Big5','GB2312'};
            
            return emailEncoding[0];
    }
    static String getCurrency() {
        List<String> c = new List<String> {'AUD','GBP','CAD','CNY','EUR','HKD','INR','JPY','CHF','USD'};
            
            return c[0];
    }
}