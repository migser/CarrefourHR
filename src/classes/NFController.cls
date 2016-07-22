public class NFController {

    private final Contact contact;

    public  NFController() {
    }

    public void deleteContats() {
        delete [SELECT id, Name, Data_load__c FROM Contact WHERE Data_load__c = true];
    }

}