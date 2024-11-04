global class UpdateProductSchedules implements Schedulable {
  global void execute(SchedulableContext ctx) {
    UpdateProductSchedulesBatch schedulesBatch = new UpdateProductSchedulesBatch();
    Id batchId = Database.executeBatch(schedulesBatch, 15);
  }
}