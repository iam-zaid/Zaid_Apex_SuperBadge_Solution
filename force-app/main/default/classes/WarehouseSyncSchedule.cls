public class WarehouseSyncSchedule implements Schedulable {
    
    public void execute(SchedulableContext SC) {
        // Instantiate and enqueue your Queueable class for execution
        WarehouseCalloutService queueableInstance = new WarehouseCalloutService();
        System.enqueueJob(queueableInstance);
    }
}