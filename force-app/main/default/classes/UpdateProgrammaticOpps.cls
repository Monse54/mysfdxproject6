global class UpdateProgrammaticOpps implements Schedulable {
  global void execute(SchedulableContext ctx) {
    UpdateProgrammaticOppsBatch batch = new UpdateProgrammaticOppsBatch();
    Id batchId = Database.executeBatch(batch, 1);
  }
}