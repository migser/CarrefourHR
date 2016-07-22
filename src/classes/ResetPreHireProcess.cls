public class ResetPreHireProcess {

    public static void resetALLtheThings(){
        //mark the task back to not done
        list<task> tasks = [select id, status from task where id = '00T3600000BTIMREA5'];
        for (task t:tasks){
	        t.Status = 'Not Started';                       
        }
        update tasks;
        
        //delete that laptop request case
        list<case> cases = [select id from case where subject = 'Laptop Reqest' and contactId = '00336000005xIDw'];
        delete cases;
        
        //delete any chatter posts where Eric Jones is the user
        list<feeditem> fis = [select id from feeditem where createdbyid = '00536000001NAVp'];
     	delete fis;
    }
}