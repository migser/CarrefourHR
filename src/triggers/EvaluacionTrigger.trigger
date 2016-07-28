trigger EvaluacionTrigger on Evaluacion__c (after insert) {
  
  List<Respuesta__c> pregs =  new List<Respuesta__c>();
  List<Preferencia__c> prefs = new  List<Preferencia__c>();	

  for (Evaluacion__c e : Trigger.new) {	
	List<RespPlantilla__c> p_plantilla = [select Pregunta__c , Pregunta__r.Tipo__c
											from RespPlantilla__c 
											where Plantilla__c = :e.Plantilla__c];
	for (RespPlantilla__c rp : p_plantilla) {
		if (rp.Pregunta__r.Tipo__c == 'Pregunta') {
			pregs.add( new Respuesta__c(Evaluacion__c = e.id, Pregunta__c = rp.Pregunta__c, Valor__c='--'));
		} else {
			prefs.add ( new Preferencia__c(Evaluacion__c = e.id, Pregunta__c = rp.Pregunta__c));
		}
	}

  }

  insert pregs;
  insert prefs;
}