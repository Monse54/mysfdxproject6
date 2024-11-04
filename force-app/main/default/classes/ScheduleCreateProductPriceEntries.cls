global class ScheduleCreateProductPriceEntries implements Schedulable {
  global void execute(SchedulableContext ctx) {
    CreateProductPriceEntriesBatch schedulesBatch = new CreateProductPriceEntriesBatch();
    Id batchId = Database.executeBatch(schedulesBatch, 1);
  }
}