trigger QSF_RFL_PositionStatusChangedTrigger on QSF_RFL_Position__c (before update) {
    for (QSF_RFL_Position__c pNew : Trigger.new) {
        QSF_RFL_Position__c pOld = Trigger.oldMap.get(pNew.Id);
        if (pOld.status__c != pNew.status__c && pNew.status__c != 'Open') { //Position has been closed
            List<QSF_RFL_Application__c> apps = [Select Id, Status__c 
                                                 From QSF_RFL_Application__c 
                                                 Where Position__c = :pNew.Id And Status__c Not In ('Accepted', 'Rejected')];
            for (QSF_RFL_Application__c a : apps) {
                a.status__c = 'Rejected';
            }
            
            update(apps);
        }
    }
}