global class PGBillingLandingProcessorBatchScheduler implements Schedulable{
    global void execute(SchedulableContext SC) {
        PGBillingLandingProcessorBatch batchJob = new PGBillingLandingProcessorBatch();
        Database.executeBatch(batchJob);
    }
}