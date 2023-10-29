global class ScheduleJobApplicationBatch implements Schedulable {
    global void execute(SchedulableContext SC) {
        JobApplicationBatch batch = new JobApplicationBatch();
        Database.executeBatch(batch);
    }
}
//this will be schedule in hello apex for the 1st and 15th of every month to clean up records