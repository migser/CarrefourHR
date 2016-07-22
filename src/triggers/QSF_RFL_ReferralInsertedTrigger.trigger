trigger QSF_RFL_ReferralInsertedTrigger on QSF_RFL_Referral__c (after insert) {
    for (QSF_RFL_Referral__c rfl : Trigger.new) {
        //Share app with referrer
        QSF_RFL_ReferralProgramServices.shareApplicationWithReferrer(rfl);
        
        //Follow Application
        QSF_RFL_ReferralProgramServices.followApplication(rfl);
        
        //Thank referrer
        QSF_RFL_ReferralProgramServices.thankReferrer(rfl.Id);
    }
}