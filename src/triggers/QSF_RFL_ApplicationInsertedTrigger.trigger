trigger QSF_RFL_ApplicationInsertedTrigger on QSF_RFL_Application__c (after insert) {
    /* Adds position required skills to application skills check list */
    List<QSF_RFL_Candidate_Skill__c> candidateSkills = new List<QSF_RFL_Candidate_Skill__c>();
    
    for (QSF_RFL_Application__c app : Trigger.new) {
        List<QSF_RFL_Required_Skill__c> reqSkills = [SELECT Id, Position__r.Hiring_Manager__c
                                                     FROM QSF_RFL_Required_Skill__c 
                                                     WHERE position__c = :app.Position__c];
                                                     
        for (QSF_RFL_Required_Skill__c rSkill : reqSkills) {
            QSF_RFL_Candidate_Skill__c cSkill = new QSF_RFL_Candidate_Skill__c();
            cSkill.OwnerId = rSkill.Position__r.Hiring_Manager__c;
            cSkill.Application__c = app.id;
            cSkill.Required_Skill__c = rSkill.Id;
            candidateSkills.add(cSkill);
        }
        
        //Notify hiring manager
        QSF_RFL_ReferralProgramServices.notifyHiringManager(app.Id);
    }

    insert (candidateSkills);
}