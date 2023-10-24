@isTest
private class JobApplicationBatch_Test {
    
    @isTest static void testJobAppBatch() {
        
        // Create test data
        List<Job_Application__c> applications = new List<Job_Application__c>();

        for (Integer i = 0; i < 10; i++) {
            applications.add(new Job_Application__c(
                Status__c = (i < 5) ? 'Applied' : 'Accepted', 
                Follow_up_Date__c = Date.today().addDays(-35), 
                Notes__c = 'Test note ' + i,
                Job_Title__c = 'Test SF Dev job ' + i
            ));
        }
        insert applications;
        
        // Check inserted records
        Integer actualAppCount = [SELECT count() FROM Job_Application__c];
        System.assertEquals(10, actualAppCount, 'All test records should be created.');
        
        // Execute Batch
        Test.startTest();
        JobApplicationBatch batch = new JobApplicationBatch();
        Id batchId = Database.executeBatch(batch);
        Test.stopTest();
        
        // Verify batch updates
        List<Job_Application__c> updatedApplications = [SELECT Id, Status__c, Notes__c FROM Job_Application__c WHERE Follow_up_Date__c <= :Date.today().addDays(-30) AND Status__c = 'Closed'];
        System.assertEquals(5, updatedApplications.size(), 'Only 5 job applications should have been closed.');
        for (Job_Application__c app : updatedApplications) {
            System.assertEquals('This job application was closed by an automated process.', app.Notes__c);
        }
    }  
}
