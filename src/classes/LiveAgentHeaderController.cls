@isTest
public class LiveAgentHeaderController {
	@AuraEnabled
    public static LiveAgentHeader__c  getId() {
      	LiveAgentHeader__c  liveAgentId = [SELECT Name, Deployment_ID_1__c, Deployment_ID_2__c FROM LiveAgentHeader__c ][0];
        return liveAgentId;
  }
}