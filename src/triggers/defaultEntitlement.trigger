trigger defaultEntitlement on Case (after Insert) {
    /*
    If the Entitlement Name is not set then, check to see if the Contact on the Case has an active Entitlement
    and select the first one.
    */
    List<Case> cases = new List<Case>();
    List<Id> accountIds = new List<Id>();
    System.debug('account id is '+Trigger.new[0].AccountId);
    for (Case c : Trigger.new){
        if (c.EntitlementId == null && c.AccountId != null){
            //accountIds.add(c.AccountId);
            List <Entitlement> entl = [Select e.Id, e.AccountId From Entitlement e
                                                  Where e.AccountId = :c.AccountId 
                                                  And e.StartDate <= Today];
            cases = [Select Id, EntitlementId from Case where Id = :c.Id];
            if (entl.size()>0)
                 cases[0].EntitlementId  = entl[0].Id;
             
                            System.debug('adding case to list');
                            //System.debug(cases[0].EntitlementId);
             //cases.add(c);
        }
    }
    /*System.debug('account id '+accountIds.size());
    if(accountIds.isEmpty()==false){
       
        List <Entitlement> entl = [Select e.Id, e.AccountId From Entitlement e
                                                  Where e.AccountId in :accountIds 
                                                  And e.StartDate <= Today];
        if(entl.isEmpty()==false){
            for(Case c : Trigger.new){
                if(c.Id == null && c.AccountId != null){
                    for(Entitlement ec:entl){
                        if(ec.AccountId==c.AccountId ){
                            c.EntitlementId = ec.Id;
                            System.debug('adding case to list');
                            System.debug(c.EntitlementId);
                            cases.add(c);
                            break;
                        }
                    } // end for
                }
            } // end for
        }
    }*/ // end if(contactIds.isEmpty()==false)
    System.debug(cases.size());
    update cases;
    System.debug('update complete');
}