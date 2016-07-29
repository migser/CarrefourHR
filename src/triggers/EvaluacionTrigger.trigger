trigger EvaluacionTrigger on Evaluacion__c (after insert) {
  
  List<Respuesta__c> pregs =  new List<Respuesta__c>();
  List<Preferencia__c> prefs = new  List<Preferencia__c>();	

  Map<ID,List<RespPlantilla__c>> evaluaciones = new Map<ID,List<RespPlantilla__c>>();

  List<Evaluacion__c> t1 = [select id, Plantilla__c from Evaluacion__c where id in :trigger.newMap.keySet()];
  List<ID> t2 = new List<Id>();

  for (Evaluacion__c e : t1 ) {
  	t2.add(e.Plantilla__c);
  }

  List<Plantilla__c> t3 = [select Id, (select Plantilla__c, Pregunta__c, Pregunta__r.Tipo__c 
  														from Plantilla__r
  														)
  										from Plantilla__c
  										where id in :t2];
  Map<Id,List<RespPlantilla__c>> t4 = new Map<Id,List<RespPlantilla__c>>();

  for (Plantilla__c p : t3) {
  	t4.put(p.Id, p.Plantilla__R);
  }

  for (Evaluacion__c e : t1) {
  	evaluaciones.put(e.Id, t4.get(e.Plantilla__c) );
  }

  for (Evaluacion__c e : Trigger.new) {	
	
	for (RespPlantilla__c rp : evaluaciones.get(e.Id)) {
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