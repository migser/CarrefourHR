public class QSF_RFL_NewReferralController {
    public QSF_RFL_Position__c position {get; set;}
    public QSF_RFL_Referral__c referral {get; set;}

    public List<SelectOption> relationships {get; set;}
    public List<SelectOption> attachmentTypes {get; set;}
    
    /* Attachment support */
    public QSF_RFL_Application_Attachment__c appAttachment {get; set;}
    public Attachment attachment {get; set;}
    public String currentReferralId {get; set;} //Used to reload state cause inputFile needs to reload the whole page
    
    public List<QSF_RFL_Application_Attachment__c> attachments {
        get {
            if (attachments == null) {
                if (referral != null) {
                    attachments = getAttachments(referral.Application__c);
                } else {
                    return new List<QSF_RFL_Application_Attachment__c>();
                }
            }
            
            return attachments;
        }
        
        set {attachments = value;}
    }
    /* End Attachment support */


    public class Position {
        public String sfid {get; set;}
        public String name {get; set;}
        public String city {get; set;}
        public String referralFee {get; set;}
        public String hiringManager {get; set;}
        public String createdDate {get; set;}
        public String deadline {get; set;}

        public Position(QSF_RFL_Position__c p) {
            sfid = p.Id;
            name = p.Name;
            city = p.City__c;
            referralFee = p.Referral_Fee__c + ' ' + UserInfo.getDefaultCurrency();
            hiringManager = p.Hiring_Manager__r.Name;
            createdDate = p.CreatedDate.format('d MMMM yyyy');
            deadline = getFormattedDate(p.Deadline__c);
        }
    }

    public QSF_RFL_NewReferralController() {
        String positionId = ApexPages.currentPage().getParameters().get('idPos');
        String referralId = ApexPages.currentPage().getParameters().get('idRef');

        if (referralId == null || referralId.length() == 0) {
            referralId = currentReferralId;
        }

        if (referralId != null && referralId.length() > 0) {
            List<QSF_RFL_Referral__c> referrals = [Select Id, Name, Application__c, Application__r.Position__c 
                                                    From QSF_RFL_Referral__c Where id = :referralId];
            if (referrals.size() > 0) {
                referral = referrals[0];
                positionId = referral.Application__r.Position__c;
            }
        }

        if (positionId != null && positionId.length() > 0) {
            List<QSF_RFL_Position__c> positions = [Select Id, Name From QSF_RFL_Position__c Where id = :positionId];
            if (positions.size() > 0) {
                position = positions[0];
            }
        }

        relationships = new List<SelectOption>();
        for(Schema.PicklistEntry e : QSF_RFL_Referral__c.Relationship__c.getDescribe().getPicklistValues()){
            relationships.add(new SelectOption(e.getValue(), e.getLabel()));
        }
        
        attachmentTypes = new List<SelectOption>();
        for(Schema.PicklistEntry e : QSF_RFL_Application_Attachment__c.Type__c.getDescribe().getPicklistValues()){
            attachmentTypes.add(new SelectOption(e.getValue(), e.getLabel()));
        }
        
        appAttachment = new QSF_RFL_Application_Attachment__c();
        attachment = new Attachment();
    }

    public void upload() {
        if (appAttachment.application__c != null && attachment.body != null && attachment.name != null) {
            /* Load referral and application (this is the first time when currentReferral is set and the 
              page will be reloaded after this action) */ 
            referral = [Select Id, Name, Application__c, Application__r.Position__c 
                                                    From QSF_RFL_Referral__c Where id = :currentReferralId LIMIT 1];

            position = [Select Id, Name From QSF_RFL_Position__c Where id = :referral.Application__r.Position__c LIMIT 1];
            
            appAttachment.Name = attachment.name;
            insert(appAttachment);
            attachment.parentId = appAttachment.Id;
            insert(attachment);

            appAttachment = new QSF_RFL_Application_Attachment__c();
            attachment = new Attachment();
            attachments = null;
        } else {
            throw new DMLException(appAttachment + ' ' + attachment);
        }
    }

    @RemoteAction 
    public static List<String> getCitiesForPositionsInGeo(String geo) {
        Set<String> cities = new Set<String>();
        for (QSF_RFL_Position__c p : [Select city__c From QSF_RFL_Position__c Where Geography__c =:geo And Status__c = 'Open' Order by city__c]) {
            cities.add(p.City__c);
        }
         
        return new List<String>(cities);
    }
    
    @RemoteAction 
    public static List<Position> getPositionsInCity(String city) {
        String query = 'Select Id, Name, City__c, Deadline__c, CreatedDate, Hiring_Manager__r.Name ';

        if (UserInfo.isMultiCurrencyOrganization()) {
            query += ', convertCurrency(Referral_Fee__c) ';
        } else {
            query += ', Referral_Fee__c ';
        }

        query += ' From QSF_RFL_Position__c  ';
        query += ' Where Status__c = \'Open\' ';
        
        if (city != 'All') {
            query += ' And City__c =:city ';
        }

        query += ' Order By Name ';

        List<QSF_RFL_Position__c> rflPositions = Database.query(query);

        List<Position> positions = new List<Position>();
        for (QSF_RFL_Position__c p : rflPositions) {
            positions.add(new Position(p));
        }

        return positions;
    }
    
    @RemoteAction 
    public static QSF_RFL_Position__c getPosition(String id) {
        return [Select Id, Name, City__c, Referral_Fee__c, Deadline__c, CreatedDate, Hiring_Manager__r.Name, Job_Description__c
                    From QSF_RFL_Position__c 
                    Where Id =:id];
    }
    
    @RemoteAction 
    public static Map<String, String> createReferral(Map<String, String> values) {
        String positionId = values.get('position');
        String name = values.get('name');
        String familyName = values.get('fName');
        String email = values.get('email');
        String phone = values.get('phone');
        String relation = values.get('relation');
        String recommend = values.get('recommend');
        String comments = values.get('comments');
        
        System.debug('Creating referral:');
        System.debug('\tpositionId: ' + positionId);
        System.debug('\tname: ' + name);
        System.debug('\tfamilyName: ' + familyName);
        System.debug('\temail: ' + email);
        System.debug('\tphone: ' + phone);
        System.debug('\trelation: ' + relation);
        System.debug('\trecommend: ' + recommend);
        System.debug('\tcomments: ' + comments);
        
        QSF_RFL_Position__c position = [Select Id, Name From QSF_RFL_Position__c Where Id =:positionId LIMIT 1];

        Contact contact = null;
        if (email != null && email.trim().length() > 0) {
            List<Contact> contacts = [Select Id, firstName, lastName, Email, Phone From Contact Where email =:email];
            if (contacts.size() > 0) {
                System.debug('Found contact for email ' + email);
                contact = contacts[0];
            }
        }

        if (phone != null && phone.trim().length() > 0) {
            if (contact != null) {
                contact.phone = phone;
                update(contact);
            } else {
                List<Contact> contacts = [Select Id, Email, Phone, firstName, lastName From Contact Where phone =:phone];
                if (contacts.size() > 0) {
                    System.debug('Found contact for phone ' + phone);
                    contact = contacts[0];
                }
            }
        }

        if (contact == null) {
            System.debug('Contact not found, creating it');
            contact = new Contact();
            contact.firstName = toProperCase(name);
            contact.lastName = toProperCase(familyName);
            contact.phone = phone;
            contact.email = email;

            insert contact;
            System.debug('Created contact ' + contact.id);
        }
        
        QSF_RFL_Application__c application = new QSF_RFL_Application__c();
        application.position__c = position.Id;
        application.contact__c = contact.Id;
        application.status__c = 'Waiting';
        insert (application);

        
        QSF_RFL_Referral__c referral = new QSF_RFL_Referral__c();
        referral.name = Contact.firstName + ' ' + Contact.lastName + ' (' + position.Name + ')';
        referral.referrer__c = UserInfo.getUserId();
        referral.application__c = application.Id;
        if (relation != null && relation.trim().length() > 0) {
            referral.relationship__c = relation;
        }
        
        if (recommend != null && recommend.equals('recommend')) {
            referral.recommendation__c = true;
        }
        
        if (comments != null && comments.trim().length() > 0) {
            referral.comments__c = comments;
        }

        insert(referral);

        return new Map<String, String>{'result' => 'OK', 'referralId' => referral.Id, 'applicationId' => application.Id};
    }

    @RemoteAction
    public static List<QSF_RFL_Application_Attachment__c> getAttachments(String applicationId) {
        return [SELECT Id, Name, Type__c, Description__c 
                FROM QSF_RFL_Application_Attachment__c 
                WHERE Application__c = :applicationId
                ORDER By Type__c, Name];
    }

    public static String getFormattedDate(Date dt) {
        return dt != null ? Datetime.newInstance(dt.year(), dt.month(), dt.day()).format('d MMMM yyyy') : 'Not Set';
    }

    public static String toProperCase(String value) {
        value = value.toLowerCase();
        List<String> pieces = new List<String>();
        for(String s : value.split(' ')) {
            s = s.capitalize();
            pieces.add(s);
        }

        return String.join(pieces, ' ');
    }
}