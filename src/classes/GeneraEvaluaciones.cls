public with sharing class GeneraEvaluaciones {
	public static void Datos() {
		Id plantilla = 'a0i50000008uiRbAAI'; 
		Id aprobador = '00550000005yqnMAAQ';
		Date inicio1 = Date.newInstance(2015, 01, 01);
		Date inicio2 = Date.newInstance(2015, 04, 01);
		Date inicio3 = Date.newInstance(2015, 07, 01);
		Date inicio4 = Date.newInstance(2015, 10, 01);

		Date fin1 = Date.newInstance(2015, 03, 31);
		Date fin2 = Date.newInstance(2015, 06, 30);
		Date fin3 = Date.newInstance(2015, 09, 30);
		Date fin4 = Date.newInstance(2015, 12, 31);

		List<Date> inicio = new List<Date>();
		inicio.add(inicio1);
		inicio.add(inicio2);
		inicio.add(inicio3);
		inicio.add(inicio4);
		List<Date> fin = new List<Date>();
		fin.add(fin1);
		fin.add(fin2);
		fin.add(fin3);
		fin.add(fin4);

		List<ID> empleados = new List<ID>();
		empleados.add('0035000002i3SpDAAU');
		empleados.add('0035000002i3SpEAAU');
		empleados.add('0035000002i3SpIAAU');
		empleados.add('0035000002i3SpJAAU');
		empleados.add('0035000002i3SpSAAU');

		List<Evaluacion__c> eval = new List<Evaluacion__c>();
		for (ID e : empleados) {
			for (Integer i =0;i<4;i++) {
				eval.add(new Evaluacion__c(Empleado__c = e, Aprobador__c = aprobador, 
											Plantilla__c=plantilla, Inicio__c = inicio.get(i), Fin__c = fin.get(i), Estado__c='Aprobado'));	
			}
		}
		insert eval;

		List<ID> eval_id = new List<ID>();
		for (Evaluacion__c e : eval) {
			eval_id.add(e.id);
		}

		List<Respuesta__c> resp = [Select id, name, valor__c from Respuesta__c where evaluacion__c in :eval_id ];
		List<Preferencia__c> pref = [Select id, name, respuesta__c from Preferencia__c where evaluacion__c in :eval_id ];

		for (Respuesta__c r : resp) {

			r.Valor__c = string.valueof(MAth.Mod(Math.ceil(Math.random()*10).intValue(),5)+1);
		}

		for (Preferencia__c p : pref) {

			if (MAth.Mod(Math.ceil(Math.random()*10).intValue(),2)==0) {
				p.Respuesta__c=true;
			} else {
				p.Respuesta__c=false;
			}
		}

		update resp;
		update pref;

	}


}