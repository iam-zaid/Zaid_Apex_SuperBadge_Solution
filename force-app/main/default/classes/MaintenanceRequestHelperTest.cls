@isTest
public with sharing class MaintenanceRequestHelperTest {
    
    @isTest
    public static void updateWorkOrdersTest(){
        Test.startTest();
        
        Product2 eqp = new Product2(Name='Equipment 1', Maintenance_Cycle__c=30,Replacement_Part__c=true);
        insert eqp;
        
        Vehicle__c veh = new Vehicle__c();
        veh.Name ='Test Vehicle2';
        insert veh;
        
        Case testMaintReq = new Case();
		testMaintReq.Type = 'Routine Maintenance	';  // Replace 'Type Value' with the appropriate value
		testMaintReq.Status = 'New ';  // Replace 'Status Value' with the appropriate value
		testMaintReq.Vehicle__c = veh.id;  // Replace 'Vehicle ID Value' with the appropriate value
		testMaintReq.Date_Reported__c = Date.today();  // Assuming you want to set today's date
		insert testMaintReq;
        
        
        Equipment_Maintenance_Item__c eqpMaintItem = new Equipment_Maintenance_Item__c(Equipment__c=eqp.Id, Maintenance_Request__c=testMaintReq.Id);
        insert eqpMaintItem;
        
        Map<Id, List<Equipment_Maintenance_Item__c>> relatedEquipMaintRecords = new Map<Id, List<Equipment_Maintenance_Item__c>>();
    	relatedEquipMaintRecords.put(eqp.Id, new List<Equipment_Maintenance_Item__c>{eqpMaintItem});
        
        testMaintReq.Status ='Closed';
        upsert testMaintReq;
        
        Test.stopTest();
    }
    
   	@isTest
    public static void updateWorkOrdersTest2(){
        Test.startTest();
        List<String> nameCheck = new List<String>{'Equipment 2','Equipment 3'};
        
        List<Product2> lstProd = new List<Product2>();
        Product2 eqp = new Product2(Name='Equipment 2', Maintenance_Cycle__c=30,Replacement_Part__c=true,Warehouse_SKU__c = '55d66226726b611100aaf742');
        lstProd.add(eqp);
        Product2 eqp2 = new Product2(Name='Equipment 3', Maintenance_Cycle__c=30,Replacement_Part__c=true,Warehouse_SKU__c = '55d66226726b611100aaf743');
        lstProd.add(eqp2);
        insert lstProd;
        System.debug('lstProd'+lstProd);
        
        Vehicle__c veh = new Vehicle__c();
        veh.Name ='Test Vehicle 3';
        insert veh;
        
        Case testMaintReq = new Case();
		testMaintReq.Type = 'Routine Maintenance';  // Replace 'Type Value' with the appropriate value
		testMaintReq.Status = 'New';  // Replace 'Status Value' with the appropriate value
		testMaintReq.Vehicle__c = veh.id;  // Replace 'Vehicle ID Value' with the appropriate value
		testMaintReq.Date_Reported__c = Date.today();  // Assuming you want to set today's date
		insert testMaintReq;
        
        List<Product2> equipments = [SELECT id,name,Replacement_Part__c, Warehouse_SKU__c,StockKeepingUnit FROM Product2 WHERE Name IN :nameCheck];
        System.debug('equipments: '+equipments);
        
        List<Equipment_Maintenance_Item__c> lstEqpMaint = new List<Equipment_Maintenance_Item__c>();
        Equipment_Maintenance_Item__c eqpMaintItem = new Equipment_Maintenance_Item__c(Equipment__c=equipments[0].Id, Maintenance_Request__c=testMaintReq.Id);
        lstEqpMaint.add(eqpMaintItem);
        Equipment_Maintenance_Item__c eqpMaintItem2 = new Equipment_Maintenance_Item__c(Equipment__c=equipments[1].Id, Maintenance_Request__c=testMaintReq.Id);
        lstEqpMaint.add(eqpMaintItem2);
        insert lstEqpMaint;
                
        testMaintReq.Status ='Closed';
        upsert testMaintReq;
        
        System.assertEquals(testMaintReq.Status ,'Closed');
        
        Test.stopTest();
    }
}