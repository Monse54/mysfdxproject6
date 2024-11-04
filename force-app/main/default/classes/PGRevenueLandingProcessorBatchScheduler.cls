global class PGRevenueLandingProcessorBatchScheduler implements Schedulable{
    global void execute(SchedulableContext SC) {
        PGRevenueLandingProcessorBatch batchJob = new PGRevenueLandingProcessorBatch();
        Database.executeBatch(batchJob);
    }
}