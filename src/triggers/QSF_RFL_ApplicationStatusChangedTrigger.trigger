trigger QSF_RFL_ApplicationStatusChangedTrigger on QSF_RFL_Application__c (after update) {
    for (QSF_RFL_Application__c newApp : Trigger.new) {
        QSF_RFL_Application__c oldApp = Trigger.oldMap.get(newApp.Id);
        if (oldApp.status__c != newApp.status__c && newApp.status__c == 'Accepted') { //Application accepted
            //Close position
            QSF_RFL_Position__c position = [Select Id, Status__c From QSF_RFL_Position__c Where ID =: newApp.Position__c];
            position.status__c = 'Closed - Selected';            
            update(position);
            
            //Notify Referrer(s)
            for (QSF_RFL_Referral__c referral : [Select Id From QSF_RFL_Referral__c Where Application__c = :newApp.Id]) {
	            QSF_RFL_ReferralProgramServices.notifyReferrerOnSelection(referral.Id);
            }
        }
    }
}