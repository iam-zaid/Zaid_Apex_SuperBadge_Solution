@isTest
global class WarehouseCalloutServiceMock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('[' +
                 '{"_id": "12345", "sku": "SKU123", "cost": 100.0, "replacement": false, "lifespan": 24, "quantity": 50, "maintenanceperiod": 30, "name": "Equipment 1"},' +
                 '{"_id": "67890", "sku": "SKU456", "cost": 150.0, "replacement": true, "lifespan": 36, "quantity": 30, "maintenanceperiod": 45, "name": "Equipment 2"},' +
                 '{"_id": "55d66226726b611100aaf743", "sku": "SKU789", "cost": 200.0, "replacement": false, "lifespan": 48, "quantity": 40, "maintenanceperiod": 60, "name": "Equipment 3"}' +
                 ']');

        response.setStatusCode(200);
        return response;
    }
}