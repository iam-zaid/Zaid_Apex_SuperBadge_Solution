public class WarehouseCalloutService implements Queueable,Database.AllowsCallouts{

    // Implement the execute method required by the Queueable interface
    // @future(callout=true)
    public void execute(QueueableContext context) {
        //try{
            // Make the callout to the external warehouse inventory management service
            String endpoint = 'https://th-superbadge-apex.herokuapp.com/equipment?_ga=2.17905855.723470981.1703139932-629746297.1701849919'; // Replace with your actual endpoint
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod('GET');         
            // Perform the callout and handle the response
            Http http = new Http();
            HttpResponse response = http.send(request);
            
            // Check the response status and deserialize the JSON response
            if (response.getStatusCode() == 200) { // Replace 200 with the appropriate status code based on your external service
                String updated_json_response = response.getBody().replaceAll('\"_id\"', '\"id\"'); //replacing the _id from the response with id cause the structure for the c;lass takes into cosideration the id element.
                List<WarehouseInventoryItem> warehouseInventoryItems = (List<WarehouseInventoryItem>) JSON.deserialize(updated_json_response, List<WarehouseInventoryItem>.class); // // Deserialize the JSON response into an appropriate Apex class or structure
                updateSalesforceRecords(warehouseInventoryItems); // Update related records in Salesforce based on the received data
            } else {
                System.debug('Callout failed with status: ' + response.getStatusCode() + ' ' + response.getStatus());
            }
        /*}catch(exception e){
            System.debug('Exeption in making callout: '+e);
        }*/
    }
    
    // Method to update related records in Salesforce based on the received data from the external service
    private void updateSalesforceRecords(List<WarehouseInventoryItem> warehouseInventoryItems) {
        List<Product2> lstToBeUpsert = new List<Product2>();
        List<Product2> lstOfAllEquipmentRecs = [SELECT id,Warehouse_SKU__c, StockKeepingUnit, Cost__c, Replacement_Part__c,Lifespan_Months__c, QuantityUnitOfMeasure, Maintenance_Cycle__c, Name FROM Product2 ];
        Map<String, Product2> equipmentMap = new Map<String, Product2>();   //equipmentMap will contain only the records which have Warehouse_SKU__c. Makes it easy to compare existing records. 
        for (Product2 equipment : lstOfAllEquipmentRecs) {
            if (equipment.Warehouse_SKU__c != null) {
                equipmentMap.put(equipment.Warehouse_SKU__c, equipment);
            }
        }

        for(WarehouseInventoryItem warInvItem:warehouseInventoryItems){
            Product2 tempEqp = new Product2();
            if(equipmentMap.containsKey(warInvItem.id)){
                tempEqp = equipmentMap.get(warInvItem.id);
                tempEqp.StockKeepingUnit =warInvItem.sku;
                tempEqp.Cost__c =warInvItem.cost;
                tempEqp.Replacement_Part__c =warInvItem.replacement;
                tempEqp.Lifespan_Months__c =warInvItem.lifespan;
                tempEqp.Current_Inventory__c =Integer.valueOf(warInvItem.quantity);
                tempEqp.Maintenance_Cycle__c =warInvItem.maintenanceperiod;
                tempEqp.Name =warInvItem.name;
                lstToBeUpsert.add(tempEqp);
            }else{
                tempEqp.StockKeepingUnit =warInvItem.sku;
                tempEqp.Cost__c =warInvItem.cost;
                tempEqp.Replacement_Part__c =warInvItem.replacement;
                tempEqp.Lifespan_Months__c =warInvItem.lifespan;
                tempEqp.Current_Inventory__c =Integer.valueOf(warInvItem.quantity);
                tempEqp.Maintenance_Cycle__c =warInvItem.maintenanceperiod;
                tempEqp.Name =warInvItem.name;
                lstToBeUpsert.add(tempEqp);
            }
        }

        if(lstToBeUpsert != null && !lstToBeUpsert.isEmpty() && lstToBeUpsert.size() >0){
            //try{
                Database.UpsertResult[] srList = Database.upsert(lstToBeUpsert,true);
                System.debug('results of upsert operation: '+srList);
            /*}catch(exception e){
                System.debug('UPSERT FAILED WITH ERROR: '+e);
            }*/
        }
    }
}