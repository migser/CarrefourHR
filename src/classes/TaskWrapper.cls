public class TaskWrapper{
    @AuraEnabled
    public Integer incompleteCount;
     
    @AuraEnabled
    public Integer completeCount;
    
    @AuraEnabled
    public String header;
    
    @AuraEnabled
    public Integer daysRemaining;
}