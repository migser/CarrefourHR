@isTest(seeAllData=true)
private class QSF_RFL_ReferralsAppTests {
    public static User hiringManager;
    public static List<QSF_RFL_Skill__c> skills;
    public static List<QSF_RFL_Required_Skill__c> requiredSkills;
    public static List<QSF_RFL_Position__c> positions;
    public static List<QSF_RFL_Application__c> applications;
    public static Contact contact;
    
    static void init(boolean createReferral) {
        hiringManager = new User();
        hiringManager.Username= 'fake@company.com';
        hiringManager.Email = 'fake@company.com';
        hiringManager.Lastname = 'mike';
        hiringManager.Alias = 'fakem';
        hiringManager.TimeZoneSidKey = 'GMT';
        hiringManager.LocaleSidKey = 'en_US';
        hiringManager.EmailEncodingKey = 'ISO-8859-1';
        hiringManager.LanguageLocaleKey = 'en_US';
        hiringManager.ProfileId = UserInfo.getProfileId();
        insert(hiringManager);
        
        contact = new Contact(Email = 'test@test.com', LastName = 'Tester');
        insert(contact);
        
        skills = new List<QSF_RFL_Skill__c>();
        requiredSkills = new List<QSF_RFL_Required_Skill__c>();
        positions = new List<QSF_RFL_Position__c>();
        applications = new List<QSF_RFL_Application__c>();
        
        QSF_RFL_Skill__c s1 = new QSF_RFL_Skill__c();
        s1.Name = '5 years experience';
        skills.add(s1);
        
        QSF_RFL_Skill__c s2 = new QSF_RFL_Skill__c();
        s2.Name = 'References Provided';
        skills.add(s2);
        
        insert(skills);     
        
        QSF_RFL_Position__c p1 = new QSF_RFL_Position__c();
        p1.Name = 'Madrid -- Human Resources Manager';
        p1.Budget__c = 60000;
        p1.City__c = 'Madrid';
        p1.Deadline__c = Date.today().addDays(180);
        p1.Geography__c = 'EMEA';
        p1.Hiring_Manager__c = hiringManager.Id;
        p1.Referral_Fee__c = 2000;
        p1.Status__c = 'Open';
        positions.add(p1);
        
        QSF_RFL_Position__c p2 = new QSF_RFL_Position__c();
        p2.Name = 'Lisbon -- Coorporate Finance Assistant';
        p2.Budget__c = 40000;
        p2.City__c = 'Lisbon';
        p2.Deadline__c = Date.today().addDays(180);
        p2.Geography__c = 'EMEA';
        p2.Hiring_Manager__c = hiringManager.Id;
        p2.Referral_Fee__c = 1000;
        p2.Status__c = 'Closed - Selected';
        positions.add(p2);
        
        insert(positions);
        
        QSF_RFL_Required_Skill__c rs1 = new QSF_RFL_Required_Skill__c();
        rs1.Position__c = p1.Id;
        rs1.Skill__c = s1.Id;
        requiredSkills.add(rs1);
        
        QSF_RFL_Required_Skill__c rs2 = new QSF_RFL_Required_Skill__c();
        rs2.Position__c = p1.Id;
        rs2.Skill__c = s2.Id;
        requiredSkills.add(rs2);
        
        insert(requiredSkills);
        
        if (createReferral) {
            QSF_RFL_Application__c app = new QSF_RFL_Application__c();
            app.Position__c = positions[0].id;
            app.Contact__c = contact.id;
            app.Status__c = 'Waiting';
            insert app;
            applications.add(app);

            QSF_RFL_Referral__c ref = new QSF_RFL_Referral__c();
            ref.Application__c = app.Id;
            ref.Name = 'Referral Test';
            ref.Relationship__c = 'Have Worked With Him';
            ref.Recommendation__c = true;
            ref.Referrer__c = UserInfo.getUserId();
            insert ref;
        }
    }
    
    static testMethod void testApplicationSelectedTrigger() {
        init(true);
        Test.startTest();
        applications[0].status__c = 'Accepted';
        update(applications[0]);
        QSF_RFL_Position__c position = [Select Id, Status__c From QSF_RFL_Position__c Where Id = :applications[0].Position__c];
        System.assert(position.Status__c == 'Closed - Selected');
        Test.stopTest();
    }

    /** Test with skills trigger **/
    static testMethod void testNewApplicationTrigger() {
        init(false);
        Test.startTest();
     
        QSF_RFL_Application__c app1 = new QSF_RFL_Application__c();
        app1.Position__c = positions[0].id;
        app1.Contact__c = contact.id;
        app1.Status__c = 'Waiting';

        insert app1;
        
        //Test 1: Inserted
        System.assert(app1.Id != null);
        
        //Test 2: Check candidate skills created
        List<QSF_RFL_Candidate_Skill__c> cSkills = [SELECT Id, Skill__c 
                                                    FROM QSF_RFL_Candidate_Skill__c
                                                    WHERE Application__c = :app1.id];

        System.assert(requiredSkills.size() == cSkills.size());
        
        Test.stopTest();
    }

    /** Test new Referral Controller **/
    public static testMethod void testNewReferralController() {
        init(false);
        Test.startTest();
        PageReference pageRef = Page.QSF_RFL_NewReferralPage;
        Test.setCurrentPage(pageRef);
        
        List<String> cities = QSF_RFL_NewReferralController.getCitiesForPositionsInGeo('EMEA');
        System.assert(cities.size() > 0);
        
        List<Object> ps = QSF_RFL_NewReferralController.getPositionsInCity('All');
        System.assert(ps.size() > 0);
        
        QSF_RFL_Position__c position = QSF_RFL_NewReferralController.getPosition(positions[0].id);
        System.assert(position.Name != null);

        Map<String, String> values = new Map<String, String>();
        values.put('position', positions[0].id);
        values.put('name', 'Daniel');
        values.put('fName', 'Tester');
        values.put('email', 'test2@test.com');
        values.put('phone', '+34917000000');
        values.put('relation', 'Have Worked With Him');
        values.put('recommend', 'true');
        values.put('comments', 'Test comments');
        
        Map<String, String> res = QSF_RFL_NewReferralController.createReferral(values);
        System.assert(res.get('result') == 'OK');
        String refId = res.get('referralId');
        String appId = res.get('applicationId');

        ApexPages.currentPage().getParameters().put('idRef', refId);
        QSF_RFL_NewReferralController controller = new QSF_RFL_NewReferralController();
        controller.currentReferralId = refId;
        
        controller.appAttachment.Application__c = appId;
        controller.appAttachment.Type__c = 'Other';
        controller.Attachment.Name = 'Unit Test Attachment';
        controller.Attachment.Body = Blob.valueOf('Unit Test Attachment Body');
        controller.upload();

        List<QSF_RFL_Application_Attachment__c> atts = QSF_RFL_NewReferralController.getAttachments(appId);
        System.assert(atts.size() == 1);
        
        Test.stopTest();
    }
    
    /** Test with skills trigger **/
    static testMethod void testReferralListController() {
        init(true);
        Test.startTest();
        PageReference pageRef = Page.QSF_RFL_ReferralListPage;
        Test.setCurrentPage(pageRef);
        QSF_RFL_ReferralListController contrl = new QSF_RFL_ReferralListController();
        
        Test.stopTest();
    }
}