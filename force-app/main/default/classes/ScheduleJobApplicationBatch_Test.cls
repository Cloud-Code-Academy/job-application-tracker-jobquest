@isTest
private class ScheduleJobApplicationBatch_Test {

    private static List<Job_Application__c> createTestApplications(Integer count) {
        List<Job_Application__c> applications = new List<Job_Application__c>();
        
        for (Integer i = 0; i < count; i++) {
            applications.add(new Job_Application__c(
                Status__c = (i < 5) ? 'Applied' : 'Accepted', 
                Follow_up_Date__c = Date.today().addDays(-35), 
                Notes__c = 'Test note ' + i,
                Job_Title__c = 'Test SF Dev job ' + i
            ));
        }
        insert applications;
        return applications; // Return the created applications
    }

    @isTest static void ScheduleJobApplicationBatchTest() {
        createTestApplications(10);

        Test.startTest();
        String cron = '0 0 1,15 * * ?';  // This runs at midnight on the 1st and 15th of every month
        String jobName = 'TestScheduledJob';
        ScheduleJobApplicationBatch job = new ScheduleJobApplicationBatch();
        System.schedule(jobName, cron, job);
        Test.stopTest();

        CronTrigger[] scheduledJobs = [SELECT Id, CronExpression, State FROM CronTrigger WHERE CronExpression = :cron];
        System.assertEquals(1, scheduledJobs.size(), 'Expected one scheduled job with the given cron expression.');
        System.assertEquals('WAITING', scheduledJobs[0].State, 'Expected the job to be in WAITING state.');
    }
}





