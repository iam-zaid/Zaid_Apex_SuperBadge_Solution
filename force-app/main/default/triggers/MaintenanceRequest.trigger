trigger MaintenanceRequest on Case (after update) {
    
    MaintenanceRequestHelper reqHelper = new MaintenanceRequestHelper();
    if(Trigger.isUpdate){
    	reqHelper.updateWorkOrders(Trigger.oldMap,Trigger.newMap);
    }
    // ToDo: Call MaintenanceRequestHelper.updateWorkOrders
}