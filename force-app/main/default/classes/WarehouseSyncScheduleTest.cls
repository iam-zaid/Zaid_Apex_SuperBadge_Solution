@isTest
private class WarehouseSyncScheduleTest {

    // Test method to cover positive scenario
    @isTest
    static void testWarehouseSyncSchedulePositive() {
        
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        Test.startTest();

        // Enqueue the schedulable class
        String jobId = System.schedule('Test Warehouse Sync Job',
                                        '0 0 23 * * ?', // This will run the job at 11 PM daily
                                        new WarehouseSyncSchedule());

        // Verify the job ID is not null, indicating it has been successfully scheduled
        System.assertNotEquals(null, jobId);

        Test.stopTest();

        // Add assertions or further verifications if needed
        // For example, you could query AsyncApexJob to ensure the job is scheduled
    }
}