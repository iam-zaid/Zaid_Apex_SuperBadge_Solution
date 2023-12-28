@isTest
private class WarehouseCalloutServiceTest {
    @isTest static void warehouseCallServiceTest() {
        List<Product2> lstProd = new List<Product2>();
        Product2 eqp2 = new Product2(Name='Equipment 3', Maintenance_Cycle__c=30,Replacement_Part__c=true,Warehouse_SKU__c = '55d66226726b611100aaf743');
        lstProd.add(eqp2);
        insert lstProd;
        System.debug('lstProd'+lstProd);
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());

        // Queue the job
        Test.startTest();
        System.enqueueJob(new WarehouseCalloutService());
        Test.stopTest();

        // Validate the results if necessary, for example, query records and assert
        List<Product2> products = [SELECT id, StockKeepingUnit, Cost__c, Replacement_Part__c, Lifespan_Months__c, Current_Inventory__c, Maintenance_Cycle__c, Name FROM Product2];
        System.debug('products: '+products);
        /*System.assertEquals(3, products.size());
        Product2 product = products[0];
        System.assertEquals('SKU123', product.StockKeepingUnit);
        System.assertEquals(100.0, product.Cost__c);
        System.assertEquals(false, product.Replacement_Part__c);
        System.assertEquals(24, product.Lifespan_Months__c);
        System.assertEquals(50, product.Current_Inventory__c);
        System.assertEquals(30, product.Maintenance_Cycle__c);
        System.assertEquals('Equipment 1', product.Name);*/
    }
    
    @isTest static void warehouseCallServiceExcpetionTest() {
        List<Product2> lstProd = new List<Product2>();
        Product2 eqp2 = new Product2(Name='Equipment 3', Maintenance_Cycle__c=30,Replacement_Part__c=true,Warehouse_SKU__c = '55d66226726b611100aaf743');
        lstProd.add(eqp2);
        insert lstProd;
        System.debug('lstProd'+lstProd);
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutMock2());

        // Queue the job
        Test.startTest();
        System.enqueueJob(new WarehouseCalloutService());
        Test.stopTest();

        // Validate the results if necessary, for example, query records and assert
        List<Product2> products = [SELECT id, StockKeepingUnit, Cost__c, Replacement_Part__c, Lifespan_Months__c, Current_Inventory__c, Maintenance_Cycle__c, Name FROM Product2];
        System.debug('products: '+products);
        /*System.assertEquals(3, products.size());
        Product2 product = products[0];
        System.assertEquals('SKU123', product.StockKeepingUnit);
        System.assertEquals(100.0, product.Cost__c);
        System.assertEquals(false, product.Replacement_Part__c);
        System.assertEquals(24, product.Lifespan_Months__c);
        System.assertEquals(50, product.Current_Inventory__c);
        System.assertEquals(30, product.Maintenance_Cycle__c);
        System.assertEquals('Equipment 1', product.Name);*/
    }
}