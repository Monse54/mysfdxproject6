global class UpdatePMPEstimations implements Schedulable {
  global void execute(SchedulableContext ctx) {
    Date startDate = Date.newInstance(2021, 12, 1);
    Date endDate = Date.newInstance(2023, 12, 31);
    PMPEstimationController.updateEntries(startDate, endDate);
  }
}