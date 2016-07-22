trigger QSF_RFL_ApplicationBeforeInsertTrigger on QSF_RFL_Application__c (before insert) {
    /* Changes owner to hiring manager */
    for (QSF_RFL_Application__c app : Trigger.new) {
        QSF_RFL_Position__c position = [SELECT Id, Hiring_Manager__c FROM QSF_RFL_Position__c WHERE Id = :app.Position__c];
        app.OwnerId = position.Hiring_Manager__c;
    }
}