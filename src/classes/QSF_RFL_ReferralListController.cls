public class QSF_RFL_ReferralListController {
    public List<Referral> referrals {get; set;}

    public class Referral {
        public String sfid {get; set;}
        public String name {get; set;}
        public String contactName  {get; set;}
        public String applicationStatus {get; set;}
        public String positionName {get; set;}
        public String positionHiringManager {get; set;}
        public String positionStatus {get; set;}
        public String positionReferralFee {get; set;}
        public String positionDeadline {get; set;}

        public Referral(QSF_RFL_Referral__c r) {
            sfid = r.Id;
            name = r.Name;
            contactName = r.Application__r.Contact__r.Name;
            applicationStatus = r.Application__r.Status__c;
            positionName = r.Application__r.Position__r.Name;
            positionHiringManager = r.Application__r.Position__r.Hiring_Manager__r.Name;
            positionStatus = r.Application__r.Position__r.Status__c;
            positionReferralFee = r.Application__r.Position__r.Referral_Fee__c + ' ' + UserInfo.getDefaultCurrency();
            
            Date dt = r.Application__r.Position__r.Deadline__c;
            positionDeadline = dt != null ? Datetime.newInstance(dt.year(), dt.month(), dt.day()).format('d MMMM yyyy') : 'Not Set';
        }

    }

    public QSF_RFL_ReferralListController() {
        String query = 'Select Id, Name, ' + 
                              'Application__r.Contact__r.Name, ' + 
                              'Application__r.Status__c, ' +  //Waiting, Process Started, Accepted, Rejected
                              'Application__r.Position__r.Name, ' + 
                              'Application__r.Position__r.Hiring_Manager__r.Name, ' + 
                              'Application__r.Position__r.Status__c, ' + //Not Started, Started, Candidate Selected, Completed, Cancelled
                              'Application__r.Position__r.Deadline__c ';
        
        if (UserInfo.isMultiCurrencyOrganization()) {
            query += ', convertCurrency(Application__r.Position__r.Referral_Fee__c) ';
        } else {
            query += ', Application__r.Position__r.Referral_Fee__c ';
        }

        query += ' FROM QSF_RFL_Referral__c ';
        query += ' WHERE Referrer__c = \'' + UserInfo.getUserId() + '\'';

        List<QSF_RFL_Referral__c> sfdcReferrals  = Database.query(query);

        referrals = new List<Referral>();
        for (QSF_RFL_Referral__c r : sfdcReferrals) {
            referrals.add(new Referral(r));
        }
    }
}