public with sharing class MaintenanceRequestHelper {
    
    public void updateWorkOrders(Map<Id,Case> oldMtRequest, Map<Id,Case> newMtRequest) {
       List<Case> maintReqstsToGenerate = new List<Case>();  // to store the new maintain requests to be generated 
       Map<Id,Equipment_Maintenance_Item__c> mapOfIdEquip = new Map<Id,Equipment_Maintenance_Item__c>();
       List<Equipment_Maintenance_Item__c> eqpMaint = new List<Equipment_Maintenance_Item__c>();
       List<Equipment_Maintenance_Item__c> tempEqpMaint = new List<Equipment_Maintenance_Item__c>();
       Map<Id,List<Equipment_Maintenance_Item__c>> relatedEquipMaintRecords = new Map<Id,List<Equipment_Maintenance_Item__c>>();
       List<Equipment_Maintenance_Item__c> newEqpMaintRecToInsert = new List<Equipment_Maintenance_Item__c>();
       Map<String,List<Equipment_Maintenance_Item__c>> mapCaseIdEqpMaintRecords = new Map<String,List<Equipment_Maintenance_Item__c>>();    // to store the map of equipment maintainence items and Case they are associated to. This will be  used to update the records with the new ids for the cases inserted.
        
       //getting the Equiment maintainence item related records to the current case
       Set<Id> oldCaseIds = newMtRequest.keySet(); //to store the ids from old maintainence requests for querying equipment maintainence records
       eqpMaint = [select name,Quantity__c, Equipment__c, Maintenance_Request__c,Equipment__r.Maintenance_Cycle__c from Equipment_Maintenance_Item__c where Maintenance_Request__c IN :oldCaseIds];
       for(Equipment_Maintenance_Item__c eqpmt:eqpMaint){
           Id tempCheck; 
           if(relatedEquipMaintRecords.containsKey(eqpmt.Maintenance_Request__c)){
                List<Equipment_Maintenance_Item__c> loopTempVar = new List<Equipment_Maintenance_Item__c>();
               	loopTempVar = relatedEquipMaintRecords.get(eqpmt.Maintenance_Request__c);
               	loopTempVar.add(eqpmt);  
               	relatedEquipMaintRecords.put(eqpmt.Maintenance_Request__c,loopTempVar);
           }
           else{
               	List<Equipment_Maintenance_Item__c> loopTempVar1 = new List<Equipment_Maintenance_Item__c>();
               	loopTempVar1.add(eqpmt);
               	relatedEquipMaintRecords.put(eqpmt.Maintenance_Request__c,loopTempVar1);
           }
            
        }
        
       // to iterate over updated maintainence requests using for loop and get the required data
       for(Case cse:newMtRequest.values()){
            Case tempCase = new Case();	// to store the instance of new case to be added to the list
           	Date maintCycle = Date.today();	// to populate the due date for maintainence cycle
           	Decimal daysToAdd =0;		// days to be added to current date in order to populate the final maintainence date
           	Integer i = 0;		// to check forst iteration of the equipment maintainence record loop
            if(cse.Status =='Closed' && (cse.Type =='Repair' || cse.Type =='Routine Maintenance')){
            	tempCase.Type ='Routine Maintenance';
            	tempCase.Subject ='New Routine maintainence request after servicing';
                tempCase.Date_Reported__c = Date.today();
                tempCase.Vehicle__c = cse.Vehicle__c;
                tempCase.CaseIdStore__c = cse.Id;
                List<Equipment_Maintenance_Item__c> newListEqpMaint = new List<Equipment_Maintenance_Item__c>();
                List<Equipment_Maintenance_Item__c> tempListForMap = new List<Equipment_Maintenance_Item__c>();
                newListEqpMaint = relatedEquipMaintRecords.get(cse.Id);
                for(Equipment_Maintenance_Item__c eqp: newListEqpMaint){
                    Equipment_Maintenance_Item__c tempEqp = new Equipment_Maintenance_Item__c();
                    tempEqp.Equipment__c = eqp.Equipment__c;
                    tempEqp.Maintenance_Request__c = eqp.Maintenance_Request__c;    // this will be updated after the new cases are inserted. with the ids of new cases.
                    newEqpMaintRecToInsert.add(tempEqp);
                    tempListForMap.add(tempEqp);
                    if(i == 0){
                        daysToAdd = eqp.Equipment__r.Maintenance_Cycle__c;
                    }else{
                        daysToAdd =daysToAdd > eqp.Equipment__r.Maintenance_Cycle__c?eqp.Equipment__r.Maintenance_Cycle__c:daysToAdd;
                    }
					i++;                    
                }
                mapCaseIdEqpMaintRecords.put(tempCase.CaseIdStore__c,tempListForMap); 
                maintCycle = maintCycle.addDays(Integer.valueOf(daysToAdd));	//adding maintainence cycle days to due date by typecasting dec to int
                tempCase.Date_Due__c = maintCycle;
                maintReqstsToGenerate.add(tempCase);
            }
            System.debug('@#@ line 64: maintReqstsToGenerate - '+maintReqstsToGenerate +' :: newEqpMaintRecToInsert - '+newEqpMaintRecToInsert);
        }
        if(maintReqstsToGenerate != NULL && newEqpMaintRecToInsert != NULL){

            // Database.SaveResult[] srList = Database.insert(newEqpMaintRecToInsert);     //using saveresult method to get the ids of newly inserted equipment maintainence records. This has to be mapped to newly generated maint requests
            Database.SaveResult[] srList = Database.insert(maintReqstsToGenerate);  //Inserting the case rather than equipment maintainence item.
            //getting the ids from the SaveReuslt mehtod  return type to store the case ids in the list
            List<Id> listOfIds = new List<Id>();
            for (Database.SaveResult sr : srList) {
                if (sr.success == true) {
                    listOfIds.add(sr.getId());
                }
            }
            System.debug('@#@Line 75: listOfIds'+listOfIds);
            List<Case> updtCases = new List<Case>([Select Id,CaseIdStore__c FROM Case where Id IN :listOfIds]);
            List<Equipment_Maintenance_Item__c> finalToBeInserted = new List<Equipment_Maintenance_Item__c>();
            for(Case csscope:updtCases){
                for(Equipment_Maintenance_Item__c emaint : mapCaseIdEqpMaintRecords.get(csscope.CaseIdStore__c)){
                    emaint.Maintenance_Request__c = csscope.Id; //updated with the new id
                    finalToBeInserted.add(emaint);
                }
            }
            insert finalToBeInserted;
        }
    }        
    
}